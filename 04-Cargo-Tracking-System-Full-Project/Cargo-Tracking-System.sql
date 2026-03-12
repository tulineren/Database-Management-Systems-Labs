-- PROJE: Kargo Takip Sistemi Veri Tabani Tasarimi
-- ER Diyagramina uygun olarak 4 ana tablo (Subeler, Musteriler, Kargolar, KargoHareketleri) üzerinde kurgulanmistir.

-- BÖLÜM 1: Stored Procedures ile musteri ekleme ve durum guncelleme gibi operasyonel sureclerin yonetimi.
-- BÖLÜM 2: Karmasik sorgulari basitlestiren ve sube yogunluk raporlari sunan View yapilari.
-- BÖLÜM 3: Veri guvenligi (silme engeli) ve otomasyon (otomatik hareket kaydi) saglayan Trigger'lar.
-- BÖLÜM 4: KDV hesaplama ve istatistiksel analiz yapan kullanici tanimli fonksiyonlar (UDF).

USE master;
GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'KargoTakipDB')
BEGIN
    DROP DATABASE KargoTakipDB;
END
GO

-- 1. VERI TABANI OLUSTURMA
CREATE DATABASE KargoTakipDB;
GO

USE KargoTakipDB;
GO

-- TABLO 1: SUBELER
CREATE TABLE Subeler (
    SubeID INT PRIMARY KEY IDENTITY(1,1),
    SubeAdi NVARCHAR(50),
    Sehir NVARCHAR(50)
);
GO

-- TABLO 2: MUSTERILER
CREATE TABLE Musteriler (
    MusteriID INT PRIMARY KEY IDENTITY(1,1),
    AdSoyad NVARCHAR(100),
    Telefon NVARCHAR(15),
    Adres NVARCHAR(255),
    KayitTarihi DATETIME DEFAULT GETDATE()
);
GO

-- TABLO 3: KARGOLAR
CREATE TABLE Kargolar (
    KargoID INT PRIMARY KEY IDENTITY(1,1),
    GondericiID INT,
    AliciID INT,
    CikisSubeID INT,
    KargoIcerik NVARCHAR(100),
    AgirlikKG FLOAT,
    Ucret DECIMAL(18,2),
    Durum NVARCHAR(20), 
    GonderimTarihi DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Gonderici FOREIGN KEY (GondericiID) REFERENCES Musteriler(MusteriID),
    CONSTRAINT FK_Alici FOREIGN KEY (AliciID) REFERENCES Musteriler(MusteriID),
    CONSTRAINT FK_CikisSube FOREIGN KEY (CikisSubeID) REFERENCES Subeler(SubeID)
);
GO

-- TABLO 4: KARGO HAREKETLERI
CREATE TABLE KargoHareketleri (
    HareketID INT PRIMARY KEY IDENTITY(1,1),
    KargoID INT,
    IslemSubeID INT,
    IslemTarihi DATETIME DEFAULT GETDATE(),
    Aciklama NVARCHAR(255),
    
    CONSTRAINT FK_HareketKargo FOREIGN KEY (KargoID) REFERENCES Kargolar(KargoID),
    CONSTRAINT FK_IslemSube FOREIGN KEY (IslemSubeID) REFERENCES Subeler(SubeID)
);
GO

-- =============================================
-- VERI GIRISLERI (INSERT SORGULARI)
-- =============================================

INSERT INTO Subeler (SubeAdi, Sehir) VALUES 
('Merkez Þube', 'Balikesir'),
('Kampüs Þube', 'Balikesir'),
('Alsancak Þube', 'Izmir');

INSERT INTO Musteriler (AdSoyad, Telefon, Adres) VALUES 
('Ahmet Yilmaz', '5551234567', 'Ataturk Mah. No:1'),
('Ayse Demir', '5559876543', 'Cumhuriyet Cad. No:5'),
('Mehmet Kaya', '5550001122', 'Konak Meydani No:3');

INSERT INTO Kargolar (GondericiID, AliciID, CikisSubeID, KargoIcerik, AgirlikKG, Ucret, Durum) VALUES 
(1, 2, 1, 'Kitap Kolisi', 5.5, 150.00, 'Yolda'),
(2, 3, 2, 'Elektronik Esya', 1.2, 75.50, 'Teslim Edildi');

INSERT INTO KargoHareketleri (KargoID, IslemSubeID, Aciklama) VALUES 
(1, 1, 'Kargo subeden teslim alindi'),
(1, 1, 'Kargo araca yüklendi');
GO

-- =============================================
-- BÖLÜM 1: STORED PROCEDURES
-- =============================================

-- 1. SP
CREATE PROCEDURE sp_MusteriEkle
    @AdSoyad NVARCHAR(100),
    @Telefon NVARCHAR(15),
    @Adres NVARCHAR(255)
AS
BEGIN
    INSERT INTO Musteriler (AdSoyad, Telefon, Adres) VALUES (@AdSoyad, @Telefon, @Adres);
END;
GO

-- 2. SP
CREATE PROCEDURE sp_DurumGuncelle
    @KargoID INT,
    @YeniDurum NVARCHAR(20)
AS
BEGIN
    UPDATE Kargolar SET Durum = @YeniDurum WHERE KargoID = @KargoID;
END;
GO

-- 3. SP
CREATE PROCEDURE sp_TarihBazliKargoGetir
    @Baslangic DATETIME,
    @Bitis DATETIME
AS
BEGIN
    SELECT * FROM Kargolar WHERE GonderimTarihi BETWEEN @Baslangic AND @Bitis;
END;
GO

-- =============================================
-- BÖLÜM 2: VIEWS
-- =============================================

-- 1. View
CREATE VIEW vw_KargoDetaylari AS
SELECT 
    K.KargoID, 
    G.AdSoyad AS Gonderen, 
    S.SubeAdi AS CikisSubesi, 
    K.Durum, 
    K.Ucret 
FROM Kargolar K
JOIN Musteriler G ON K.GondericiID = G.MusteriID
JOIN Subeler S ON K.CikisSubeID = S.SubeID;
GO

-- 2. View
CREATE VIEW vw_BekleyenKargolar AS
SELECT * FROM Kargolar WHERE Durum != 'Teslim Edildi';
GO

-- 3. View
CREATE VIEW vw_SubeYogunluk AS
SELECT S.SubeAdi, COUNT(K.KargoID) AS ToplamKargo
FROM Subeler S
LEFT JOIN Kargolar K ON S.SubeID = K.CikisSubeID
GROUP BY S.SubeAdi;
GO

-- =============================================
-- BÖLÜM 3: TRIGGERS
-- =============================================

-- 1. Trigger
CREATE TRIGGER trg_KargoSilinemez
ON Kargolar
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Güvenlik nedeniyle kargo kayitlari silinemez!';
END;
GO

-- 2. Trigger
CREATE TRIGGER trg_IlkHareketOtomatik
ON Kargolar
AFTER INSERT
AS
BEGIN
    DECLARE @KargoID INT, @SubeID INT;
    SELECT @KargoID = KargoID, @SubeID = CikisSubeID FROM inserted;
    
    INSERT INTO KargoHareketleri (KargoID, IslemSubeID, Aciklama)
    VALUES (@KargoID, @SubeID, 'Kargo sisteme girildi.');
END;
GO

-- 3. Trigger
CREATE TRIGGER trg_YuksekUcretKontrol
ON Kargolar
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Kargolar 
    SET KargoIcerik = KargoIcerik + ' (ÖZEL)' 
    WHERE Ucret > 1000 AND KargoID IN (SELECT KargoID FROM inserted);
END;
GO

-- =============================================
-- BÖLÜM 4: FUNCTIONS
-- =============================================

-- 1. Function
CREATE FUNCTION fn_KDVHesapla (@Ucret DECIMAL(18,2))
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN @Ucret * 1.20; 
END;
GO

-- 2. Function
CREATE FUNCTION fn_MusteriKargoSayisi (@MusteriID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Sayi INT;
    SELECT @Sayi = COUNT(*) FROM Kargolar WHERE GondericiID = @MusteriID;
    RETURN @Sayi;
END;
GO

-- 3. Function
CREATE FUNCTION fn_DurumaGoreKargolar (@Durum NVARCHAR(20))
RETURNS TABLE
AS
RETURN
(
    SELECT KargoID, KargoIcerik, Ucret FROM Kargolar WHERE Durum = @Durum
);
GO

-- =============================================
-- SON: ORNEK SORGULAR (NESTED SELECTS)
-- =============================================

-- 1. Nested Select
SELECT * FROM Kargolar 
WHERE Ucret > (SELECT AVG(Ucret) FROM Kargolar);

-- 2. Nested Select
SELECT AdSoyad FROM Musteriler 
WHERE MusteriID NOT IN (SELECT DISTINCT GondericiID FROM Kargolar);

-- 3. Nested Select
SELECT * FROM Kargolar 
WHERE KargoID = (
    SELECT TOP 1 KargoID FROM KargoHareketleri ORDER BY IslemTarihi DESC
);

GO
