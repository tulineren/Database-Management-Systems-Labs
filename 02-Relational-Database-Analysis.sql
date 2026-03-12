-- 1. SORU: Personel tablosundan ad ve soyadi birlestirerek tek bir sutunda listeleme.
USE CENG_SinavSoruBankasi;
GO

SELECT 
    CONCAT(ad, ' ', soyad) AS "Personel Adi ve Soyadi"
FROM 
    personel;


-- 2. SORU: Proje adlarini kucuk harfe (LOWER) donusturerek sorgulama.
USE CENG_SinavSoruBankasi;
GO

SELECT 
    LOWER(proje_ad)
FROM 
    proje;


-- 3. SORU: Personel maaslarini benzersiz (DISTINCT) degerler olarak listeleme.
USE CENG_SinavSoruBankasi;
GO

SELECT 
    DISTINCT maas
FROM 
    personel;


-- 4. SORU: Belirli bir yil ve ayda (Örn: Mayis 2002) ise baslayan personelleri filtreleme.
USE CENG_SinavSoruBankasi;
GO

SELECT *
FROM personel
WHERE 
    YEAR(baslama_tarihi) = 2002 
    AND MONTH(baslama_tarihi) = 5;


-- 5. SORU: Birim bazli calisan sayilarini gruplandirarak raporlama.
USE CENG_SinavSoruBankasi;
GO

SELECT 
    birim_no,
    COUNT(*) AS KackisiCalisiyor
FROM 
    personel
GROUP BY 
    birim_no;


-- 6. SORU: Birden fazla cocugu olan personellerin ad, soyad ve çocuk sayilarini JOIN kullanarak listeleme.
USE CENG_SinavSoruBankasi;
GO

SELECT 
    p.ad, 
    p.soyad, 
    COUNT(c.personel_no) AS KacCocuguVar
FROM 
    personel AS p
INNER JOIN 
    cocuk AS c ON p.personel_no = c.personel_no
GROUP BY 
    p.personel_no, p.ad, p.soyad
HAVING 
    COUNT(c.personel_no) > 1;



-- 7. SORU: Calisan sayiyi 5'ten az olan birimleri HAVING kullanarak filtreleme.
USE CENG_SinavSoruBankasi;
GO

SELECT 
    b.birim_ad, 
    COUNT(p.personel_no) AS "Toplam Calisan Sayisi"
FROM 
    personel AS p
INNER JOIN 
    birim AS b ON p.birim_no = b.birim_no
GROUP BY 
    b.birim_ad
HAVING 
    COUNT(p.personel_no) < 5;



-- 8. SORU: il ve ilçe bazli calisan dagilimini coklu JOIN yapisi ile analiz etme.
USE CENG_SinavSoruBankasi;
GO

SELECT 
    ic.ilce_ad, 
    i.il_ad, 
    COUNT(p.personel_no) AS "Toplam Calisan Sayisi"
FROM 
    personel AS p
INNER JOIN 
    ilce AS ic ON p.dogum_yeri = ic.ilce_no
INNER JOIN 
    il AS i ON ic.il_no = i.il_no
GROUP BY 
    i.il_ad, ic.ilce_ad
HAVING 
    COUNT(p.personel_no) > 3;



-- 9. SORU: Personel, gorevlendirme, proje ve birim tablolarini birlestirerek yeni bir fiziksel tablo (PersonelProjeListesi) olusturma.
-- (1. Adim: Tabloyu olusturma)
USE CENG_SinavSoruBankasi;
GO

SELECT 
    p.ad, 
    p.soyad, 
    u.unvan_ad, 
    pr.proje_ad, 
    pr.baslama_tarihi, 
    pr.planlanan_bitis_tarihi, 
    b.birim_ad
INTO 
    PersonelProjeListesi
FROM 
    personel as p, 
    gorevlendirme as g, 
    proje as pr, 
    unvan as u, 
    birim as b
WHERE 
    p.personel_no = g.personel_no 
    AND pr.proje_no = g.proje_no 
    AND p.unvan_no = u.unvan_no 
    AND p.birim_no = b.birim_no;

-- (2. Adim: Tabloyu cagirma)

SELECT * FROM PersonelProjeListesi;
