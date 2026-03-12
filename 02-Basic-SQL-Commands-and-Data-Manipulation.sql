-- 1. SORU: PERSONEL tablosunun DDL komutlarýyla oluþturulmasý ve örnek kayýtlarýn INSERT edilmesi.-- Önce tablo varsa temizleyelim (Hata almamak için)
IF OBJECT_ID('PERSONEL', 'U') IS NOT NULL 
DROP TABLE PERSONEL;

CREATE TABLE PERSONEL (
    id INT PRIMARY KEY,
    ad VARCHAR(50),
    soyad VARCHAR(50),
    yas INT,
    cinsiyet CHAR(1), -- 'E' veya 'B' tek karakter
    sehir VARCHAR(50),
    ulke VARCHAR(50),
    maas DECIMAL(10, 2) -- Para birimi için Decimal kullanýmý uygundur
);

-- Veri Giriþleri (INSERT)
INSERT INTO PERSONEL (id, ad, soyad, yas, cinsiyet, sehir, ulke, maas) VALUES
(2, 'Ahmet', 'Yilmaz', 20, 'E', 'Ankara', 'Turkiye', 2000.00),
(3, 'Mehmet', 'Efe', 22, 'E', 'Bolu', 'Turkiye', 2000.00),
(4, 'Ayse', 'Can', 23, 'B', 'Istanbul', 'Turkiye', NULL),
(5, 'Fatma', 'Ak', 35, 'B', 'Ankara', 'Turkiye', 3200.00),
(6, 'John', 'Smith', 45, 'E', 'New York', 'USA', 3000.00),
(7, 'Ellen', 'Smith', 40, 'B', 'New York', 'USA', 3500.00),
(8, 'Hans', 'Muller', 30, 'E', 'Berlin', 'Almanya', 4000.00),
(9, 'Frank', 'Cesanne', 35, 'E', 'Paris', 'Fransa', NULL),
(10, 'Abbas', 'Demir', 26, 'E', 'Adana', 'Turkiye', 2000.00),
(11, 'Hatice', 'Topcu', 26, 'B', 'Hatay', 'Turkiye', 2200.00),
(12, 'Gulsum', 'Demir', 35, 'B', 'Adana', 'Turkiye', 2000.00);

-- tabloyu görelim
SELECT * FROM PERSONEL;


-- 2. SORU: Belirli bir ülke kriterine göre maaþlarda %10 oranýnda UPDATE iþlemi.
UPDATE PERSONEL 
SET maas = maas * 1.10 
WHERE ulke = 'Turkiye';


-- 3.soru
SELECT * FROM PERSONEL 
WHERE cinsiyet = 'E';


-- 4. SORU: String fonksiyonlarý (LOWER) ve operatörler kullanarak dinamik mail adresi oluþturma.
SELECT 
    ad, 
    soyad, 
    LOWER(ad) + LOWER(soyad) + '@hotmail.com' AS Mail 
FROM PERSONEL;


-- 5-6. SORU: BETWEEN ve IN operatörleri ile belirli aralýklarda veri filtreleme.
SELECT * FROM PERSONEL 
WHERE maas BETWEEN 2000 AND 3500;


-- 6.soru
SELECT * FROM PERSONEL 
WHERE maas IN (2000, 3000, 4000);


-- 7.soru
SELECT ad, soyad, ulke 
FROM PERSONEL 
WHERE maas IS NULL;


-- 8.soru
SELECT * FROM PERSONEL 
WHERE ad LIKE 'A%';


-- 9.soru
SELECT ad, soyad, ulke, maas 
FROM PERSONEL 
ORDER BY yas ASC;


-- 10.soru
SELECT 
    LOWER(ad) AS Ad, 
    UPPER(soyad) AS Soyad, 
    maas 
FROM PERSONEL;


-- 11. SORU: COUNT ve AVG gibi agregasyon fonksiyonlarý ile veri analizi.
SELECT 
    COUNT(*) AS Sayi, 
    AVG(yas) AS Yas_Ortalamasý 
FROM PERSONEL;


-- 12.soru
UPDATE PERSONEL 
SET maas = 2500 
WHERE maas IS NULL;


-- 13.soru
SELECT 
    MAX(maas) AS En_Yuksek_Maas, 
    MIN(maas) AS En_Dusuk_Maas 
FROM PERSONEL;


-- 14.soru
SELECT COUNT(*) AS Toplam_Kayit 
FROM PERSONEL;


-- 15.soru
SELECT SUM(maas) AS Toplam_Maas 
FROM PERSONEL;


-- 16-20. SORU: GROUP BY ve HAVING yapýlarý kullanýlarak ülke ve cinsiyet bazlý geliþmiþ raporlama.
SELECT ulke, COUNT(*) AS Kisi_Sayisi 
FROM PERSONEL 
GROUP BY ulke;


-- 17.soru
SELECT ulke, COUNT(*) AS Kisi_Sayisi_30_Ustu
FROM PERSONEL
WHERE yas > 30
GROUP BY ulke;


-- 18.soru
SELECT 
    cinsiyet, 
    AVG(yas) AS Yas_Ortalamasi, 
    COUNT(*) AS Kisi_Sayisi
FROM PERSONEL
GROUP BY cinsiyet;


-- 19.soru
SELECT 
    ulke, 
    cinsiyet, 
    AVG(maas) AS Maas_Ortalamasi, 
    COUNT(*) AS Kisi_Sayisi
FROM PERSONEL
GROUP BY ulke, cinsiyet;


-- 20.soru
SELECT 
    ulke, 
    AVG(maas) AS Maas_Ortalamasi
FROM PERSONEL
WHERE cinsiyet = 'E'
GROUP BY ulke
HAVING COUNT(*) < 2;