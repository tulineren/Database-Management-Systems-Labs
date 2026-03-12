-- ==========================================================
-- PROJE: KUTUphane YOnetim Sistemi Otomasyonu
-- ICERIK: ÝliSkisel Tablo Tasarimi, Veri Tutarliligi ve Otomasyon
-- TEKNOLOJILER: MSSQL, T-SQL (INSTEAD OF Triggers, Stored Procedures, Views)
-- ==========================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'KutuphaneDB')
BEGIN
    CREATE DATABASE KutuphaneDB;
END
GO

USE KutuphaneDB;
GO


-- SORU 1: Books, Members ve BorrowedBooks tablolari arasýnda Foreign Key iliskilerinin kurulmasi.
-- 1.1 Books (Kitaplar) Tablosu Olusturma 
IF OBJECT_ID('Books', 'U') IS NOT NULL DROP TABLE Books;
CREATE TABLE Books (
    [cite_start]BookID INT PRIMARY KEY,      
    [cite_start]Title NVARCHAR(100),         
    [cite_start]Author NVARCHAR(100),       
    [cite_start]Genre NVARCHAR(50),          
    [cite_start]Stock INT                    
);

-- 1.2 Members (Uyeler) Tablosu Olusturma 
IF OBJECT_ID('Members', 'U') IS NOT NULL DROP TABLE Members;
CREATE TABLE Members (
    [cite_start]MemberID INT PRIMARY KEY,    
    [cite_start]FirstName NVARCHAR(50),       
    [cite_start]LastName NVARCHAR(50),        
    [cite_start]JoinDate DATE                 
);

-- 1.3 BorrowedBooks (Odunc Kitaplar) Tablosu Olusturma 
IF OBJECT_ID('BorrowedBooks', 'U') IS NOT NULL DROP TABLE BorrowedBooks;
CREATE TABLE BorrowedBooks (
    [cite_start]BorrowID INT PRIMARY KEY,    
    [cite_start]MemberID INT,                 
    [cite_start]BookID INT,                   
    [cite_start]BorrowDate DATE,              
    [cite_start]ReturnDate DATE NULL,         
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- 1.4 Veri Ekleme (INSERT) Islemleri
INSERT INTO Books (BookID, Title, Author, Genre, Stock) VALUES
(1, 'Suç ve Ceza', 'Fyodor Dostoyevski', 'Roman', 5),
(2, 'Sineklerin Tanrýsý', 'William Golding', 'Roman', 3),
(3, 'Yapay Zeka', 'John McCarthy', 'Teknoloji', 4),
(4, 'Veri Bilimi', 'Jake VanderPlas', 'Teknoloji', 2),
(5, 'Ýki Þehrin Hikayesi', 'Charles Dickens', 'Tarih', 6);


INSERT INTO Members (MemberID, FirstName, LastName, JoinDate) VALUES
(1, 'Ali', 'Yýlmaz', '2023-01-12'),
(2, 'Ayþe', 'Kaya', '2022-09-20'),
(3, 'Mehmet', 'Demir', '2023-06-05'),
(4, 'Elif', 'Özcan', '2024-02-15'),
(5, 'Kerem', 'Çelik', '2023-11-23');

INSERT INTO BorrowedBooks (BorrowID, MemberID, BookID, BorrowDate, ReturnDate) VALUES
(1, 1, 2, '2024-04-10', NULL),
(2, 3, 1, '2024-03-25', '2024-04-05'),
(3, 2, 4, '2024-04-01', NULL),
(4, 4, 3, '2024-04-03', NULL),
(5, 5, 5, '2024-02-15', '2024-03-01');

GO


-- SORU 2-3: Stored Procedure kullanimi ile parametrik stok yonetimi ve uye bazli sorgulama.
CREATE PROCEDURE sp_StokArtir
    @BookID INT,
    @Miktar INT
AS
BEGIN
    UPDATE Books
    SET Stock = Stock + @Miktar
    WHERE BookID = @BookID;
END;
GO

-- SORU 3: 
CREATE PROCEDURE sp_UyeOduncListesi
    @MemberID INT
AS
BEGIN
    SELECT m.FirstName, m.LastName, b.Title, bb.BorrowDate, bb.ReturnDate
    FROM BorrowedBooks bb
    JOIN Books b ON bb.BookID = b.BookID
    JOIN Members m ON bb.MemberID = m.MemberID
    WHERE bb.MemberID = @MemberID;
END;
GO

-- SORU 4-5: Iade edilmemis kitaplarin takibi ve uye istatistikleri icin dinamik View yapilari.
CREATE VIEW vw_IadeEdilmemisKitaplar AS
SELECT b.Title, m.FirstName, m.LastName, bb.BorrowDate
FROM BorrowedBooks bb
JOIN Books b ON bb.BookID = b.BookID
JOIN Members m ON bb.MemberID = m.MemberID
WHERE bb.ReturnDate IS NULL;
GO

-- SORU 5: 
CREATE VIEW vw_UyeOduncSayilari AS
SELECT m.FirstName, m.LastName, COUNT(bb.BorrowID) AS ToplamOdunc
FROM Members m
LEFT JOIN BorrowedBooks bb ON m.MemberID = bb.MemberID
GROUP BY m.MemberID, m.FirstName, m.LastName;
GO

-- SORU 6-8: GELISMIS OTOMASYON: 
--     * AFTER INSERT/DELETE triggerlarý ile anlik stok senkronizasyonu.
--     * INSTEAD OF INSERT triggerý ve RAISERROR kullanýmý ile stok kontrolü (Ýþ Mantýðý Kontrolü).
CREATE TRIGGER trg_StokDusur
ON BorrowedBooks
AFTER INSERT
AS
BEGIN
    UPDATE Books
    SET Stock = Stock - 1
    FROM Books b
    JOIN inserted i ON b.BookID = i.BookID;
END;
GO

-- SORU 7:
CREATE TRIGGER trg_KayitSilininceStokArtir
ON BorrowedBooks
AFTER DELETE
AS
BEGIN
    UPDATE Books
    SET Stock = Stock + 1
    FROM Books b
    JOIN deleted d ON b.BookID = d.BookID;
END;
GO

-- SORU 8: 
CREATE TRIGGER trg_StokKontrol
ON BorrowedBooks
INSTEAD OF INSERT
AS
BEGIN
    -- Eðer eklenmek istenen kitaplardan stoðu 0 olan varsa hata fýrlat
    IF EXISTS (
        SELECT 1 
        FROM Books b
        JOIN inserted i ON b.BookID = i.BookID
        WHERE b.Stock <= 0
    )
    BEGIN
        RAISERROR ('Stokta olmayan kitap ödünç alýnamaz!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Sorun yoksa veriyi ekle (Bu islem trg_StokDusur triggerini tetikleyecektir)
        INSERT INTO BorrowedBooks (BorrowID, MemberID, BookID, BorrowDate, ReturnDate)
        SELECT BorrowID, MemberID, BookID, BorrowDate, ReturnDate FROM inserted;
    END
END;
GO

-- SORU 9-10: Skaler fonksiyonlar (UDF) ile uye bazli veri analizi.
CREATE FUNCTION fn_UyeOduncSayisi (@MemberID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Sayi INT;
    SELECT @Sayi = COUNT(*) 
    FROM BorrowedBooks 
    WHERE MemberID = @MemberID;
    
    RETURN @Sayi;
END;
GO

-- SORU 10: 
CREATE FUNCTION fn_ToplamStok ()
RETURNS INT
AS
BEGIN
    DECLARE @Toplam INT;
    SELECT @Toplam = SUM(Stock) FROM Books;
    RETURN @Toplam;
END;
GO

-- SORU 11-12: Subqueries ve Nested Select yapilari ile istatistiksel raporlama.
SELECT FirstName, LastName
FROM Members
WHERE MemberID IN (
    SELECT TOP 1 MemberID
    FROM BorrowedBooks
    GROUP BY MemberID
    ORDER BY COUNT(*) DESC
);

-- SORU 12: 
SELECT Title, Stock
FROM Books
WHERE Stock < (SELECT AVG(Stock) FROM Books);
GO