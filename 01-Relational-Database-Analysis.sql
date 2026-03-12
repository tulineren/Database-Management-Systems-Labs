-- 1. SORU: Personel tablosundan ad ve soyadý birleþtirerek tek bir sütunda listeleme.
USE CENG_SýnavSoruBankasi;
GO

SELECT 
    CONCAT(ad, ' ', soyad) AS "Personel Adý ve Soyadý"
FROM 
    personel;


-- 2. SORU: Proje adlarýný küçük harfe (LOWER) dönüþtürerek sorgulama.
USE CENG_SýnavSoruBankasi;
GO

SELECT 
    LOWER(proje_ad)
FROM 
    proje;


-- 3. SORU: Personel maaþlarýný benzersiz (DISTINCT) deðerler olarak listeleme.
USE CENG_SýnavSoruBankasi;
GO

SELECT 
    DISTINCT maas
FROM 
    personel;


-- 4. SORU: Belirli bir yýl ve ayda (Örn: Mayýs 2002) iþe baþlayan personelleri filtreleme.
USE CENG_SýnavSoruBankasi;
GO

SELECT *
FROM personel
WHERE 
    YEAR(baslama_tarihi) = 2002 
    AND MONTH(baslama_tarihi) = 5;


-- 5. SORU: Birim bazlý çalýþan sayýlarýný gruplandýrarak raporlama.
USE CENG_SýnavSoruBankasi;
GO

SELECT 
    birim_no,
    COUNT(*) AS KackisCalisiyor
FROM 
    personel
GROUP BY 
    birim_no;


-- 6. SORU: Birden fazla çocuðu olan personellerin ad, soyad ve çocuk sayýlarýný JOIN kullanarak listeleme.
USE CENG_SýnavSoruBankasi;
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



-- 7. SORU: Çalýþan sayýsý 5'ten az olan birimleri HAVING kullanarak filtreleme.
USE CENG_SýnavSoruBankasi;
GO

SELECT 
    b.birim_ad, 
    COUNT(p.personel_no) AS "Toplam Calýsan Sayýsý"
FROM 
    personel AS p
INNER JOIN 
    birim AS b ON p.birim_no = b.birim_no
GROUP BY 
    b.birim_ad
HAVING 
    COUNT(p.personel_no) < 5;



-- 8. SORU: Ýl ve ilçe bazlý çalýþan daðýlýmýný çoklu JOIN yapýsý ile analiz etme.
USE CENG_SýnavSoruBankasi;
GO

SELECT 
    ic.ilce_ad, 
    i.il_ad, 
    COUNT(p.personel_no) AS "Toplam Calisan Sayýsý"
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



-- 9. SORU: Personel, görevlendirme, proje ve birim tablolarýný birleþtirerek yeni bir fiziksel tablo (PersonelProjeListesi) oluþturma.
-- (1. Adým: Tabloyu oluþturma)
USE CENG_SýnavSoruBankasi;
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

-- (2. Adým: Tabloyu çaðýrma)
SELECT * FROM PersonelProjeListesi;