-------------------------------------------------------------SQL Örnekler----------------------------------------------------------------------------
------------------------fakülteler tablosunu varsa silen ve oluþturan sql kodunu yazýnýz
drop table if exists Fakulteler
go
if not exists (Select * from sys.tables where name=N'Fakulteler')
create table Fakulteler (
Id int, 
Adi varchar(50), 
Kodu varchar(10) constraint UQ_Fakulteler_Kodu unique) 


------------------------bölümler tablosu ile fakülteler tablosunu iliþkilendiren sql kodunu yazýnýz
ALTER TABLE Bolumler 
ADD FakulteKodu VARCHAR(10)  constraint fk_Bolumler_Fakulteler_Fkodu foreign key references Fakulteler(Kodu) on update cascade 

------------------------öðrencilerin harf notlarýnýn hesaplatýlmasý, dönemlik ortalamalarýnýn hesaplatýlmasý(toplu olarak yapýlmalý)
declare @ogrno varchar(max), @ad varchar(19), @soyad varchar(19), @vize float(5), @fnl float(5), @ort float(5) , @hnotu varchar(2), @kredi float(3), @topkredi float(5), @agirlikkredi float(5), @donemort float(5)
declare ogrcursor cursor for Select OgrenciNo, adi, soyadi from Ogrenciler
open ogrcursor
FETCH NEXT FROM ogrcursor INTO @ogrno, @ad, @soyad
while @@FETCH_STATUS=0
	begin
		set @topkredi=0
		declare hncursor cursor for select  od.Vize, od.Final, od.Ortalama, od.HarfNotu, d.Kredi from OgrenciDersler od left join Dersler d on d.kodu=od.DersKodu where od.OgrenciNo=@ogrno
			open hncursor 
			FETCH NEXT FROM hncursor INTO  @vize, @fnl, @ort, @hnotu , @kredi
			while @@FETCH_STATUS = 0
					begin
						set @ort = cast(( @vize * 0.4)+ (@fnl * 0.6) as float)
						set @hnotu = (sELECT harf from harfaralik where @ort>=alt and @ort <= ust) 
						update OgrenciDersler set Ortalama=@ort, HarfNotu = @hnotu where OgrenciNo=@ogrno
						set @topkredi = @topkredi + @kredi
						print @ogrno +' '+ cast(@vize as varchar) +' '+ cast(@fnl as varchar) +' '+ cast(@ort as varchar) +' '+ @hnotu 
						FETCH NEXT FROM hncursor INTO @ogrno, @vize, @fnl, @ort, @hnotu , @kredi
					end
					close hncursor
					DEALLOCATE hncursor

	end
close ogrcursor
DEALLOCATE ogrcursor


------------------------öðrencilerin bölümadý ve fakülte adlarýyla birlikte tüm bilgilerini getiren sql
------------------------(bölümlere alan ekle hangi fakülteye ait)
Select o.*, b.Adi as BolumAdi, (Select Adi from Fakulteler f where f.Kodu = b.FakulteKodu) as FakAdi from Ogrenciler o left join Bolumler b on o.BKodu=b.Kodu


------------------------ogrencidersler tablosundaki tüm verileri öðrenci ad soyad (tek sütunda) ve ders adý bilgileriyle getiren sql
Select od.*, o.Adi+' '+o.Soyadi as AdSoyad, (Select adi from Dersler where Dersler.kodu=od.DersKodu) from OgrenciDersler od left join Ogrenciler o on o.OgrenciNo = od.OgrenciNo

--S1: Toplam Öðrenci Sayýsýný Veren SQL?
--Select Count(*) as OgrSayisi From "Ogrenciler";
--S2: Cinsiyetine Göre Öðrenci Sayýlarýný Getiren SQL?
--Select Count(*) as OgrSayisi, "Cinsiyeti" From "Ogrenciler" GROUP BY "Cinsiyeti";

--S3: Bolumlerine Göre Öðrenci Sayýlarýný Getiren SQL?
--Select "BKodu", Count(*) as OgrSayisi From "Ogrenciler" GROUP By "BKodu";

--S4: Bölüm ve Cinsiyetlerine Göre Öðrenci Sayýlarýný Getiren SQL?
--Select "BKodu", "Cinsiyeti", Count(*) as OgrSayisi From "Ogrenciler" GROUP By "BKodu", "Cinsiyeti";

--S5: Bölüm, Cinsiyet ve Sýnýflarýna Göre Öðrenci Sayýlarýný Getiren SQL?
--Select "BKodu", "Cinsiyeti", "Sinifi", Count(*) as OgrSayisi From "Ogrenciler" GROUP By "BKodu", "Cinsiyeti", "Sinifi";

--S6: Ýçersinde 1 den Fazla Öðrencisi Olan bölümleri Getiren SQL? (Sorgu Sadece Ogrenciler Tablosuna Yapýlacak)
--Select "BKodu", Count(*) OgrSayisi From "Ogrenciler" Group By "BKodu" Having Count(*) >= 2;
--S7: Öðrencilerin Tüm Bilgilerini Bölüm Adlarý ile birlikte getiren SQL?
--(1. Join Kullanarak, 2 Altsorgu Kullanarak)
--1 Yöntem JOIN ile
--Select o.*, b."Adi" as BolumAdi From "Ogrenciler" o inner Join "Bolumler" b on b."Kodu" = o."BKodu";
--Select o.*, b."Adi" BolumAdi From "Ogrenciler" o Left Join "Bolumler" b on b."Kodu" = o."BKodu";
--2. Yöntem SubQuery (Alt Sorgu)
Select o.*, (Select  b."Adi" From "Bolumler" b  where b."Kodu" = o."BKodu" ) BolumAdi From "Ogrenciler" o; 

--DECALRE --if
--Donguler
--Case When
--Soru: Veritabaný Tablolarýna Yeni Sütun Eklemeden Öðrencilerin Bolumlerine Göre Almalarý Gereken Ders Sayýsýný Hesplayan/Getiren SQL?
/*
bilgisyar prog = 10
biliþim güvenliði = 11
Uçak teknoljisi = 9
Diðerleri = 8
*/
Select "OgrenciNo", "Adi", "Soyadi", "BKodu",

Case "BKodu" When 'B1' then 10
			 When 'B2' then 11
			 else 8
END DersSayisi

from ogrencileryedek;

--Döngüler Exit

do $$
	Declare sayac INTEGER := 0;
	Declare toplam Integer := 0;
begin
	--0 ile sayac arasýndaki sayýlardan 100 deðerine ulaþýncýya kadar 
	--Toplama iþlemini yapan program	 
	
	while sayac <= 40 loop
		raise notice 'Adým: %', sayac;
		toplam := toplam + sayac;
		if (toplam >= 100) then
			Exit;
		end if;
		
		sayac := sayac + 1;
	end loop;
	raise notice 'Toplam: %', toplam;

end$$;
















--Donguler Continue
--Soru: 0 ile 50 arasýndaki sayýlardan 5'e tam bölünmeyen sayýlarýn toplamlarýný 400 ve daha büyük oluncaya kadar bulan program/SQL

do $$
	Declare sayac Integer := 1;
	Declare toplam Integer:=0;
begin
	while sayac <= 50 loop
		
                      if mod(sayac, 5) = 0 then
			sayac := sayac + 1;
			continue;
		end if;

		raise notice 'Ýþlem Yapýlan Sayý: %', sayac;
		toplam := toplam + sayac ;
		
		if(toplam >= 400) then
			exit;
		end if;
		
           sayac := sayac + 1;
		
           End loop;

	raise Notice 'Toplam : %', toplam;

END $$;

--Döngüler
--Record veri tipi
-- Ogrenciler Tablosundan Ogrno, Adi ve Soyadi Bilgilerini Mesaj olarak Konsola yazdýran Program
--Select * from "Ogrenciler";

do $$
	Declare ogr record;
	Declare ogrders record;
	DECLARE ort float;
	Declare hn varchar(2);
begin

	for ogr in Select ogrenciNo, adi, soyadi From ogrenciler  Loop
		
		raise notice 'OgrenciNo: %  Adý: % Soyadý: %  ADI SOYADI: %', 
		ogr.ogrenciNo, ogr.adi, ogr.soyadi , ogr.Adi ||  '--' || ogr.soyadi;
		
		for ogrders in Select od.*, d.kredi as DKredi from ogrencidersler od left join dersler d on d.kodu = od.dersler
		 where od.ogrenciNo = ogr.ogrenciNo 		
		LOOP
		
			ort := (ogrders.vize * 0.4) + (ogrders.fnl * 0.6);
			hn := 'BA';
			/*
				ortalama ve harfnotu hesabý yapýldý
			*/
				--Update ogrencidersler set ortalama = hesapOrt, harfNotu = hesapHN;
				Raise notice 'ID : % OgrNo:% DKodu: % Vize: % Final: %  ORT: % HN: %', ogrders.id,  ogrders.ogrenciNo, ogrders.dersKodu, 
				ogrders.Vize, 		ogrders.fnl, ort, hn;
				
				update ogrencidersler set ortalama = ort, harfnotu = hn where id = ogrders.id;
				
		END LOOP; --OgrenciDersler
		
		raise notice '--------------------------------------------------------------------';

	
	End loop; -- Ogrenciler


End $$;
--Select * from pg_database;

--DÖNGÜLER
--While Döngüsü
/*
do $$
	DECLARE sayac INTEGER := 5;

BEGIN
	while sayac > 0 loop
		raise notice 'Sayaç : % ',sayac ;
		sayac := sayac - 1;
	
	end loop;


End$$;

*/
do $$
	Declare toplam INTEGER:= 0;
Begin
	raise notice 'For Döngüsü Örneði';
	
	for i in 1..10 loop
	    raise notice 'For Sayaç: %', i ;
	end loop;
	
	raise notice 'Tersten For Döngü Örneði';
	for n in reverse 10..5 loop
		raise notice 'n : %', n;
	end loop;
	
	raise notice 'Step By Step For ';
	--0 ile 10 arasýndaki çift sayýlarýn Toplamý
	for x in 0..10 by 2 loop
	   toplam := toplam + x;
	end loop;
	
	raise notice 'Toplam:= %', toplam;
	
END$$;

--Drop Table if Exists "Ogrenciler"
/*
Drop Table if exists "Bolumler";
Drop Table if exists Bolumler;

Create Table Bolumler(
	Id Integer Constraint PK_Bolumler_Id Primary Key,
	Kodu Character Varying(5) Constraint UQ_Bolumler_Kodu Unique Not NULL,
	Adi Character Varying(30) Not Null
	 
);
*/
/*
Insert Into bolumler(Adi, Id, Kodu) --Values(2, 'bKodu', 'BAdi')
Select  "Adi", "Id", "Kodu" From bolumleryedek;
*/
/*
Drop Table if Exists ogrenciler;

Create Table ogrenciler(
	Id int4 Constraint PK_Ogrenciler_Id Primary Key,
	ogrenciNo varchar(10) Constraint UQ_Ogrenciler_OgrNo Unique Not Null,
	tcNo varchar(11) Constraint UQ_Ogrenciler_TcNo Unique Not Null
		Constraint CK_Ogrenciler_tcNo Check(length(tcNo) >= 3),
	adi character varying(30) Not null,
	soyadi character varying(30) Not null,
	cinsiyeti varchar(1) Not Null Default 'E' 
		Constraint CK_Ogrenciler_Cinsiyet Check(cinsiyeti='E' OR cinsiyeti = 'K'),
	bkodu varchar(5),

	sinifi int2 Not null Default 1,
	
	Constraint FK_Ogrenciler_Bolumler_BKodu Foreign Key(bkodu)
	References bolumler(kodu)
	
);

*/
/*
Insert into ogrenciler
Select * from ogrencileryedek;
*/

Select * from bolumler;
Select * from ogrenciler;

Drop Table bolumleryedek;
DROP table ogrencileryedek;


/*
Select * from bolumler;

--insert into bolumler (kodu, adi) values('b5', 'bölüm-5');


Select * from ogrenciler Order by id desc;

insert into ogrenciler (ogrencino, tcno, adi, soyadi, cinsiyeti, bkodu, sinifi)
Values('O7', '777', 'Yelda', 'YILMAZ', 'K', null, 2);
*/
--VÝZE Hazýrlýk Sorular
--1: Öðrenci Bilgilerini bölüm Adý ile birlikte Getiren SQL
--2: Fakulteler tablosunu oluþturan, içerisine en az 3 kayýt ekleyen sql
--3: Fakülteler tablosu ile Öðrenciler veya bölümler ile iliþkilendiriniz
--4: Öðrenci Bilgilerini Fakülte Adý ve Bölüm Adý ile birlikte Getiren SQL
--5: OgrenciDersler Tablosundaki verilere göre (vize,final notu) ilgili kayýtlara ait 
--ortalama ve harf notu hesabýný yapan, 
--öðrencilerin dönem bazlý Agýrlýklý not ortalmasýný hesaplayan ve ekrana yazdýran/getiren SQL?

--Insert Into "Bolumler" Values('B6', 'Deneme');
--Select * from public."Bolumler"

--Insert Into public."Ogrenciler" ("OgrenciNo", "TCNo", "Adi", "Soyadi", "Cinsiyeti", "BKodu")
--Values('O2', '321', 'Melisa', 'AKTUNA', 'K', NULL);

Insert Into public."Ogrenciler" ("OgrenciNo", "TCNo", "Adi", "Soyadi", "Cinsiyeti", "BKodu")
Values('O3', '333', 'Mehmet Can', 'ATAR', 'E', 'B2'),
('O4', '444', 'Muhammed Emre', 'GÜRBÜZ', 'E', 'B3'),
('05', '555', 'Berkay', 'AKYOL', 'E', 'B1'),
('06', '666', 'Tuðçe', 'ERANIL', 'K', 'B4');


Select * from "Ogrenciler"
/*
Truncate Table "Bolumler" Restart Identity;

Truncate Table "Ogrenciler" Restart Identity;

Select * from "Ogrenciler";

Select * from "Bolumler";

Delete From "Bolumler" 
*/

Insert Into "Bolumler" ("Adi", "Kodu") 
				 Select "Adi", "Kodu" From bolumleryedek
				 
--Insert into "Bolumler" ("Kodu", "Adi") Values('B5', 'Bölüm5')
				 

--Select * into BolumlerYedek From "Bolumler";

--Select * into OgrencilerYedek From "Ogrenciler";

--Truncate table "Bolumler";

--Delete From "Bolumler";

--Truncate Table "Ogrenciler";
TRUNCATE TABLE "Ogrenciler" RESTART IDENTITY;

Select * from "Bolumler";
Select * from "Ogrenciler";

--Insert Into "Bolumler" ("Id", "Kodu", "Adi") Values(9,'b5', 'bölüm5');
--Insert Into "Ogrenciler" ("OgrenciNo", "TCNo", "Adi", "Soyadi", "BKodu", "Cinsiyeti", "Sinifi")
--Values('O2', '321', 'Aliþan', 'YILDIZ', 'b1', 'E', 2)

CREATE TABLE Dersler (
    ID       INTEGER      CONSTRAINT Pk_Dersler_Id PRIMARY KEY ASC AUTOINCREMENT,
    Kodu     VARCHAR (10) CONSTRAINT Uq_Dersler_Kodu UNIQUE
                          NOT NULL,
    Adi      VARCHAR (30) COLLATE NOCASE,
    Kredi    INTEGER      NOT NULL,
    Akts     INTEGER      NOT NULL,
    Teorik   INTEGER      NOT NULL
                          DEFAULT (0),
    Uygulama INTEGER      NOT NULL
                          DEFAULT (0),
    Turu     VARCHAR (5)  NOT NULL
                          DEFAULT ('Z') 
                          CHECK (Turu IN ('Z', 'MS', 'MOS') ) 
);
Select * from Ogrenciler;

--SORU1-Toplam Öðrenci sayýlarýný veren sql? (Ýki Þekilde yaparýz ama * yapmak avantajlý deðil sadece pratik, gerçek datalarda * kullanmamalyýz)
Select COUNT(ID) as OgrSayisi from Ogrenciler;
Select COUNT(*) as OgrSayisi from Ogrenciler;

--SORU2-Toplam Ders sayýlarýný veren sql?
Select COUNT(*) DersSayisi from Dersler;

--SORU3-Kredi Toplamlarýný veren sql? SUM Satýr bazýnda, Count hem satýr hem sütun bazýnda çalýþýr.
Select SUM(Kredi) TopKredi from Dersler;

--SORU4-Kredi ve AKTS Toplamlarýný veren sql? 1 Satýr 1 sütuna HÜCRE denir. Ýkiside tek bir deðer döndürdüðü için ard arda SUM yazabildik.
Select SUM(Kredi) TopKredi, SUM(AKTS) AKTSToplam from Dersler;

--SORU5-En Büyük Ders Kredisini bulan sql?
Select MAX(Kredi) as EnBuyukKredi from Dersler;

--SORU6-En Küçük Ders Kredisini bulan sql?
Select MIN(Kredi) EnKucukKredi from Dersler;

--SORU7-Derslerin Ortalama Kredi Deðerini veren sql? AVG Ortalamayý verir.
Select AVG(Kredi) OrtKredi from Dersler;

--SORU8-Derslerin Ortalama Kredi Deðerini hesaplayan VE virgülden sonra 2 haneye yuvarlayan sql? ROUND yuvarlýyor.
Select 12.5432 as Deger;
Select ROUND(12.5432) as Deger;
Select ROUND(12.5432, 2) as Deger;

Select ROUND( AVG(Kredi) , 2 ) OrtKredi from Dersler;

Select ROUND( AVG(Kredi) , 2 ) OrtKredi,
       AVG(Kredi) Ort_Kredi,
       SUM(Kredi) TopKredi,
       COUNT(Kredi) as DersSayisi,
       SUM(AKTS) TopAKTS,
       Max(Kredi) EnBuyukKredi,
       Min(Kredi) EnKucukKredi    from Dersler;
--GROUP BY, HAVING Kullanýmý -- SELECT, WHERE, GROUP BY, HAVING, UNION, ORDER BY Kullaným sýrasý

--SORU1 - Cinsiyetine göre ögrenci sayýsýný getiren sql?
Select Cinsiyeti, COUNT(*) as Sayi from Ogrenciler GROUP BY Cinsiyeti; --Geriye tek deðer döndüren (Count, Sum gibi) bir SQL ifadesinin olduðu yerde bu fonksiyonlar dýþýnda herhangi bir tablo alaný yazýlacak ise bu alanýn gruplandýrýlmasý gerekir(GROUP)

--SORU2 - Bölümlerine göre toplam ögrenci sayýsýný getiren sql?
Select BKodu, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu;

--SORU3 - Bölümü ve cinsiyetine göre toplam ögrenci sayýsýný getiren sql?
Select BKodu, Cinsiyeti, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu, Cinsiyeti;
                                       
--SORU4 - Bölümlerine göre toplam ögrenci sayisi 2 ve daha fazlasý olan kayýtlarý getiren sql?
Select BKodu, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu HAVING Sayi >=2; --Having þart koþuyor
Select BKodu, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu HAVING COUNT(*) >=2; --Sayi çýkmayabilir sorun oluþturabilir, Count'a baðladýk

--SORU5 - Bölümlerine göre toplam ögrenci sayisi 2 ve daha fazlasý olan VE Bölüm Koduna göre azalan þekilde sýralayan sql?
Select BKodu, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu HAVING COUNT(*) >=2 ORDER BY BKodu Desc;

--SORU6- Cinsiyeti E olan ve Bölümlerine göre toplam ögrenci sayisi 2 ve daha fazlasý olan VE Bölüm Koduna göre azalan þekilde sýralayan sql?
Select BKodu, COUNT(*) as Sayi from Ogrenciler WHERE Cinsiyeti = 'E' GROUP BY BKodu HAVING COUNT(*) >=2 ORDER BY BKodu Desc;

--IN(ÝÇÝNDE), BETWEEN(ARASINDA) KULLANIMI

--SORU1: Dersler tablosundan ID deðeri 1,3,4,5 olan kayýtlarý getiren sql?
SELECT * from Dersler WHERE ID=1 OR ID=3 OR ID=4 OR ID=5;
Select * from Dersler WHERE ID IN(1,3,4,5);

--SORU2: Dersler tablosundan Kodu BLG103, BLG104, BLG105 olan kayýtlarý getiren sql? (OR yerine IN kullanabiliyoruz, milyonluk kayýtlarda OR daha iyidir)
Select * from Dersler WHERE Kodu='BLG103' OR Kodu='BLG104' OR Kodu='BLG105';
Select * from Dersler WHERE Kodu IN('BLG103', 'BLG104', 'BLG105');

--SORU3: Dersler tablosunda ID deðeri 2-6 arasýnda olan kayýtlarý getiren sql?(2 ve 6 da dahil olarak alýyoruz eðer almazsak BETWEEN 3 AND 5 derdik)
Select * from Dersler WHERE ID>=2 AND ID<=6;
Select * from Dersler WHERE ID BETWEEN 2 AND 6;

Select * from Dersler;

--INSERT(KAYIT EKLEME)
Insert Into Dersler VALUES (4, 'BLG244', 'Deneme Dersi', 5, 5, 0, 1, 'MOS', NULL);

Insert Into Dersler (Kodu, Adi, Turu, Kredi, AKTS) VALUES('BLG250', 'Saðlýklý Yaþam','MOS', 2, 3);

--UPDATE(KAYIT GÜNCELLEME)
UPDATE Dersler SET Teorik=0;

UPDATE Dersler SET Teorik = Kredi-1, Uygulama=0;

UPDATE Dersler SET Teorik=1, Uygulama=1 WHERE Turu='Z';

--SORU1: Dersler tablosundaki verilerden kredisi 4 ve büyük olanlarý VE turu Z olanlarýn teorik 0, uygulama -1 olarak güncelle
UPDATE Dersler SET Teorik=0, Uygulama=-1 WHERE Turu= 'Z' AND Kredi>=4; --VE-AND-&& / VEYA-OR-||

--DELETE(KAYIT SÝLME)
DELETE from Dersler WHERE Turu='MOS' AND Kredi<=2;
Select * from Dersler WHERE Turu = 'MOS' AND Kredi <=2;
--LIKE(BENZER-ÝÇERÝR) KULLANIMI
Select * from Ogrenciler;

--SORU1 - Ýsmi A ile baþlayan öðrencileri getiren sql?
Select * from Ogrenciler WHERE Ad LIKE 'A%';

--SORU2 - Ýsmi AY ile baþlayan öðrencileri getiren sql?
Select * from Ogrenciler WHERE Ad LIKE 'Ay%';

--SORU3 - Soyadi Z ile biten öðrencileri getiren sql?
Select * from Ogrenciler WHERE Soyadi LIKE '%Z';

--SORU4 - Adýnýn içinde E harfi olan öðrencileri getiren sql? 
Select * from Ogrenciler WHERE Ad LIKE '%E%';

--SORU5 - Adýnýn içinde L harfi olan öðrencileri getiren sql?
Select * from Ogrenciler WHERE Ad LIKE '%l%';

--SORU6 - Adýnýn içinde A , soyadýnýn içinde E harfi olanlar?
Select * from Ogrenciler WHERE Ad LIKE '%A%' AND Soyadi LIKE '%E%';

--sORU7 - Adýnda A olan Soyadý EZ ile biten?
Select * from Ogrenciler WHERE Ad LIKE '%A%' AND Soyadi LIKE '%EZ%';

--SORU7 - Adýnýn Baþharfi A olmayan verileri getiren sql?
Select * from Ogrenciler WHERE Ad NOT LIKE 'A%';

--SORU9 - Adýnýn ilk 2 harfi AY olan VE 5.Harfi G olan verileri getiren sql? _ Tek bir karakter 
Select * from Ogrenciler WHERE Ad LIKE 'AY__G%';

--SORU10 - Ýlk 2 harfi AY olan VE ÝSMÝNÝN 4.HARFÝ E olan veya Soyadýnda Z harfi olan aql?
Select * from Ogrenciler WHERE Ad LIKE 'AY_E%' OR Soyadi LIKE '%Z%';

--SORU11 - Cinsiyeti Erkek olan kayýtlarý getiren sql?
Select * from Ogrenciler WHERE Cinsiyeti = 'E';
Select * from Ogrenciler WHERE Cinsiyeti LIKE 'E';

--SORU12 - Cinsiyeti Erkek olmayanlar?
Select * from Ogrenciler WHERE Cinsiyeti != 'E';
Select * from Ogrenciler WHERE NOT Cinsiyeti = 'E';

--SORU1: Dersler tablosundan türü Z olan VEYA Kredisi 3 ten büyük eþit olan dersleri getiren sql?
Select * from Dersler WHERE Turu='Z' OR Kredi >=3;

--SORU2: Dersler tablosundan türü Z olan VE Kredisi 3 ten küçük eþit olan dersleri getiren sql?
Select * from Dersler WHERE Turu='Z' AND Kredi <=3;

--sSORU: Dersler tablosundan türü Z olan veya kredisi 3 ten büyük eþit olan, ID deðeri 2-6 arasýnda olan dersleri getiren sql? (VE/VEYA yazmýyorsa VE olarak alýrýz)
Select * from Dersler WHERE (Turu='Z' OR Kredi >=3) AND (ID>=2 AND ID<=6);
--WHERE, ORDER BY(SIRALAMA) KULLANIMI

Select ID, Adi, Kodu, Turu From Dersler;

--SORU1: Dersler tablosundaki verileri adlarýna göre artan sýralý olarak getiren sql?
Select * from Dersler ORDER BY Adi asc;
Select * from Dersler ORDER BY Adi;

--SORU2: Adlarýna göre azalan þekilde göre sýralayan sql?
Select * from Dersler ORDER BY Adi desc;

--SORU3: Derslerin kredilerine göre artan þekilde sýralayan sql?
Select * from Dersler ORDER BY Kredi;

--SORU4: Derslerin kredilerine göre artan, AKTS deðerine göre azalan þekilde sýralayan sql?
Select * from Dersler ORDER BY Kredi, AKTS desc;

--SORU5: Zorunlu dersleri kredilerine göre artan, AKTS deðerine göre azalan þekilde sýralayan sql?
Select * from Dersler WHERE Turu= 'Z' ORDER BY Kredi, AKTS desc;

--SORU6: Kredisi 4 ve daha fazla olan zorunlu dersleri kredilerine göre artan, AKTS deðerine göre azalan þekilde sýralayan sql?
Select * from Dersler WHERE Turu= 'Z' AND Kredi>=4 ORDER BY Kredi, AKTS desc;

--TAKMA AD (ALTAS)
Select ID as OGR_ID, OgrenciNo, Tcno [TC Kimlik No], Ad ADI from Ogrenciler;

Select Ogrenciler.ID, Ogrenciler.OgrenciNo from Ogrenciler;

Select o.ID, Ogr_ID, o.OgrenciNo from Ogrenciler as o;
--ALTER TABLE --TABLO ADI DEÐÝÞTÝRME, SÜTUN EKLEME, ÇIKARMA

--sORU1: Uyeler tablosunun adýný Users olarak deðiþtiren sql?
ALTER TABLE Uyeler RENAME TO Users;

--SORU2: Users tablosundaki cinsiyet adýný Cinsiyeti olarak deðiþtiren sql?
ALTER TABLE Users RENAME COLUMN Cinsiyet TO Cinsiyeti;

--SORU3: Users tablosuna country, city alanlarýný ekleyen sql?
ALTER TABLE Users ADD COLUMN Country VARCHAR(30) NOT NULL DEFAULT('Türkiye');
ALTER TABLE Users ADD COLUMN City VARCHAR(30);

--SORU4: Users tablosundan City alanýný silen sql?
ALTER TABLE Users DROP COLUMN City;

--SORU5: Users tablosuna Kayýt Tarihi adýnda o an ki tarih ve zaman bilgisini Default olarak ekleyen sql?
ALTER TABLE Users ADD COLUMN KayitTarihi DateTime NOT NULL DEFAULT( datetime('now', 'localtime') );
--DDL(Data Defination Language)
--CREATE(Nesne oluþturur), DROP(Nesneyi Siler)

--SORU1: Ýçerisinde ID, UserName, Password, email, Cinsiyet, DogumTarihi alanlarýný barýndýran üyeler ismindeki tabloyu gerekli kýsýtlamalarýda göz önüne alýnarak oluþturan sql?

--CREATE TABLE if not exists Uyeler (zaten var deðilse)

CREATE TABLE Uyeler(

ID INTEGER CONSTRAINT Pk_Uyeler_Id Primary Key Autoincrement NOT NULL, 

Username VARCHAR(30) CONSTRAINT UQ_Uyeler_Username UNIQUE NOT NULL CHECK(length(Username) >=3 ),

Password VARCHAR(30) NOT NULL,

Email VARCHAR(50) CONSTRAINT UQ_Uyeler_Emaile UNIQUE NOT NULL,

Cinsiyet VARCHAR(1)  NOT NULL DEFAULT('E') CHECK (Cinsiyet IN ('E', 'K') ),

DogumTarihi DATE
);


--DROP TABLE Uyeler;

--DROP TABLE if exists Uyeler; --Eðer varsa silsin.

--SORU1: ÖgrenciDersler tablosuna tablolar arasý iliþkileri gözeterek en az 2 kayýt ekleyen tek bir sql?
INSERT INTO OgrenciDersler (OgrenciNo, DersKodu, Vize) vALUES ('O3', 'BLG106', 80); 

INSERT INTO OgrenciDersler (OgrenciNo, DersKodu, Vize) 
vALUES
('O3', 'BLG106', 80),
('O4', 'BLG106', 70);

--SORU2: Dersler tablosundaki verileri AKTS Kredilerine göre azalan þekilde sýralayan ve içerisinde A harfi bulunan dersleri getiren sql?
Select * from Dersler WHERE Adi LIKE '%A%' ORDER BY AKTS desc;

--SORU3: Ogrenciler tablosundan isimleri benzersiz olarak getiren sql? --DISTINCT benzersizlik saðlýyor.
Select Ad, COUNT(*) Sayi from Ogrenciler GROUP BY Ad;
Select DISTINCT Ad from Ogrenciler;

--SORU4: Türüne göre ders sayýsýný getiren sql?
Select Turu, COUNT(*) as Sayi from Dersler GROUP BY Turu;

--SORU5: Dersler tablosundan ID Kodu, Adi, Kredi, AKTS bilgileriyle birlikte AKTS'nin 2 katý ve Kredi'nin 3 katýný hesaplayan sql?
Select ID, Kodu, Adi, Kredi, Akts, (Kredi*2) Kredi2Kat, (Akts*3) as Akts3Kat from Dersler;
--DROP, CREATE, if Exists, if Not Exists

DROP TABLE Bolumler; 

DROP TABLE if Exists Bolumler;

--SORU1: ID, Kodu ve Adi alanlarýný barýndýran Bölümler Tablosunu oluþturan sql?
CREATE TABLE Bolumler ( 
ID INTEGER CONSTRAINT PK_Bolumler_ID PRIMARY KEY Autoincrement,
Kodu VARCHAR(5) CONSTRAINT UQ_Bolumler_Kodu UNIQUE NOT NULL,
Adi VARCHAR(40) NOT NULL COLLATE NOCASE);

--SORU2: Bolumler tablosuna en az 3 kayýt ekleyen sql?
INSERT INTO Bolumler (Kodu, Adi) 
VALUES('B1', 'Bilgisayar'), 
      ('B2', 'Biliþim'),
      ('B3', 'Uçak'),
      ('B4', 'Kontrol Otomasyon');
--ALT SORGU(SUB QUERY): Ana(Main) Select'in içinde Select olmasý.

--SORU1: En Büyük Kredi deðerinw sahip olan dersi getiren sql?
Select MAX(Kredi) from Dersler;

Select * From Dersler WHERE Kredi = (Select MAX(Kredi) from Dersler); --Diðer bilgileri de getiriyor(Alt Sorfu)

--SORU2: ÖðrenciDerler tablosundaki verileri ders adlarý ile birlikte getiren sql?
Select od.ID, od.OgrenciNo, od.DersKodu, (Select d.Adi from Dersler d WHERE d.Kodu = od.DersKodu) DersAdi from OgrenciDersler od; 

--Kodu BLG103 olan dersin adý nedir? Select d.Adi From Dersler d WHERE d.Kodu = 'BLG103';

--SORU3: OgrenciDersler tablosundaki verileri öðrenci adý ile getiren sql?
Select od.ID, od.OgrenciNo, (Select o.Ad from Ogrenciler o WHERE o.OgrenciNo=od.OgrenciNo) OgrAdi, od.DersKodu from OgrenciDersler od;

--SORU4: OgrenciDersler tablosundaki verileri soyadý ile getiren sql?
Select od.ID, od.OgrenciNo, (Select o.Soyadi from Ogrenciler o WHERE o.OgrenciNo=od.OgrenciNo) OgrSoyadi, od.DersKodu from OgrenciDersler od;

--SORU5: Öðrencinin Ad-Soyadýný bir sütunda getiren sql?
Select o.*, (o.Ad || ' ' || o.Soyadi) AdiSoyadi from Ogrenciler o; --METÝN BÝRLEÞTÝRME

Select od.ID, od.OgrenciNo, (Select o.Ad || ' ' || o.Soyadi from Ogrenciler o WHERE o.OgrenciNo=od.OgrenciNo) OgrAdi_Soyadi, od.DersKodu from OgrenciDersler od;
--ALT SORGU DEVAM
--SORU1: Bilgisayar bölümünde okuyan öðrencileri getiren sql?
Select b.Kodu from Bolumler b WHERE b.Adi = 'Bilgisayar';
Select o.* from Ogrenciler o WHERE BKodu = (Select b.Kodu from Bolumler b WHERE b.Adi = 'Bilgisayar');

--SORU2: Bölümü B ile baþlayan öðrencileri getiren sql?
Select o.* from Ogrenciler o WHERE BKodu = 'B1' OR BKodu = 'B2';
Select o.* from Ogrenciler o WHERE BKodu IN ('B1', 'B2');

Select o.* from Ogrenciler o WHERE BKodu IN(Select b.Kodu from Bolumler b WHERE b.Adi LIKE 'B%');

--SORU3: Bölüm Adý B ile Baþlamayan öðrencileri getiren sql?
Select o.* from Ogrenciler o WHERE BKodu IN(Select b.Kodu from Bolumler b WHERE b.Adi NOT LIKE 'B%');
Select o.* from Ogrenciler o WHERE BKodu NOT IN(Select b.Kodu from Bolumler b WHERE b.Adi LIKE 'B%');

--SORU4: Bölüm Adi ile birlikte öðrenci bilgilerini getiren sql?
Select o.*, (Select b.Adi from Bolumler b WHERE b.Kodu = o.BKodu) BolumAdi from Ogrenciler o;
--LIMIT  (SQL Server'da ise TOP kullanýlýyor)

--SORU1: öðrenciler tablosundan ÝLK 3 kiþiyi geetiren sql?
Select * from Ogrenciler Order by Ad LIMIT 3;
--SORU1: Öðrenciler tablosunun YEDEÐÝNÝ alýnýz. Yedekte VARCHAR veri tipi TEXT olur.

CREATE TABLE OgrencilerYedek as 
Select o.*, (Select b.Adi from Bolumler b WHERE b.Kodu=o.BKodu) BolumAdi from Ogrenciler o;

--SORU2: Ayný dersi birden fazla alan öðrenci ve ders bilgilerini getiren sql?
Select OgrenciNO, DersKodu, COUNT(*) Adet from OgrenciDersler GROUP BY OgrenciNO, DersKodu HAVING Adet>1;

Select ID from OgrenciDersler od WHERE od.OgrenciNO = 'O3' AND od.DersKodu = 'BLG106' ORDER BY ID Desc LIMIT 1;

DELETE from OgrenciDersler
WHERE ID IN (Select ID from OgrenciDersler od WHERE od.OgrenciNO = 'O3' AND od.DersKodu = 'BLG106' ORDER BY ID Desc LIMIT 1);
Select * from Ogrenciler WHERE Trim(Ad) = 'Ali'; --Baþýnda boýþluk olan Ali ismini getirmedi.

UPDATE Ogrenciler set Ad = Trim(Ad) WHERE length(Ad) != length(Trim(Ad)); --Baþýnda boþluk olanlarý düzeltti, güncelledi.

Select o.Ad, INSTR(o.Ad, 'ALÝ') from Ogrenciler o;
--String Fonksiyonlarý

--Length
Select o.Ad, length (o.Ad) as Ad_Uzunluk, o.Soyadi, length(o.Soyadi) Soyad_Uzunluk from Ogrenciler o;

Select 'Deniz' as Name, length('Deniz') Name_Uzunluk;

--LTrim, RTrim, Trim
Select '  Deniz  ' as Name, length('  Deniz  ') Name_Uzunluk,
ltrim('  Deniz  ') as ltrimName, length(ltrim('  Deniz  ')) ltrim_uzunluk,
rtrim('  Deniz  ') as rtrimName, length(rtrim('  Deniz  ')) rtrim_uzunluk,
trim('  Deniz  ') as trimName, length(trim('  Deniz  ')) trim_uzunluk;

--lOWER(Metni Büyütür) - UPPER(Metni Küçültür)
Select o.Ad, UPPER(o.Ad) Upper_Adi, o.Soyadi, Lower(o.Soyadi) Lower_Soyadi from Ogrenciler o;

--INSTR: Bir string içinde baþka string var nmý yok mu görmemizi saðlar, varsa baþlangýç noktasýndaki index numarasýný alýr.
Select INSTR('Merhaba Dünya', 'a') Sonuc; --5
Select INSTR('Merhaba Dünya', 'M') Sonuc; --1
Select INSTR('Merhaba Dünya', 'MER') Sonuc; --1
Select INSTR('Merhaba Dünya', 'Z') Sonuc; --0

--SUBSTR: 
--Baþa en az 2 parametre alýr
Select SUBSTR('Merhaba Dünya', 4) Sonuc;
Select SUBSTR('Merhaba Dünya', 4, 2) Sonuc;

--REPLACE: Bir string içinde baþka string arýyor varsa deðiþtiriyor
Select REPLACE('Merhaba Dünya', 'a' , 'e') Sonuc;
Select REPLACE('Merhaba Dünya', 'Dünya' , 'Ahali') Sonuc;
--String Fonksiyonlarý

--Length
Select o.Ad, length (o.Ad) as Ad_Uzunluk, o.Soyadi, length(o.Soyadi) Soyad_Uzunluk from Ogrenciler o;

Select 'Deniz' as Name, length('Deniz') Name_Uzunluk;

--LTrim, RTrim, Trim
Select '  Deniz  ' as Name, length('  Deniz  ') Name_Uzunluk,
ltrim('  Deniz  ') as ltrimName, length(ltrim('  Deniz  ')) ltrim_uzunluk,
rtrim('  Deniz  ') as rtrimName, length(rtrim('  Deniz  ')) rtrim_uzunluk,
trim('  Deniz  ') as trimName, length(trim('  Deniz  ')) trim_uzunluk;

--lOWER(Metni Büyütür) - UPPER(Metni Küçültür)
Select o.Ad, UPPER(o.Ad) Upper_Adi, o.Soyadi, Lower(o.Soyadi) Lower_Soyadi from Ogrenciler o;

--INSTR: Bir string içinde baþka string var nmý yok mu görmemizi saðlar, varsa baþlangýç noktasýndaki index numarasýný alýr.
Select INSTR('Merhaba Dünya', 'a') Sonuc; --5
Select INSTR('Merhaba Dünya', 'M') Sonuc; --1
Select INSTR('Merhaba Dünya', 'MER') Sonuc; --1
Select INSTR('Merhaba Dünya', 'Z') Sonuc; --0

--SUBSTR: 
--Baþa en az 2 parametre alýr
Select SUBSTR('Merhaba Dünya', 4) Sonuc;
Select SUBSTR('Merhaba Dünya', 4, 2) Sonuc;

--REPLACE: Bir string içinde baþka string arýyor varsa deðiþtiriyor
Select REPLACE('Merhaba Dünya', 'a' , 'e') Sonuc;
Select REPLACE('Merhaba Dünya', 'Dünya' , 'Ahali') Sonuc;
--SORU: Öðrenciler tablsu ile ÖðrencilerYedek tablosunun verilerini birleþtirerek getiren sql? 
--Birleþtirmesi için UNION'da sütun sayýlarý eþit, veri tipleri ayný olmalý.
--UNION ALL bütün kayýtlarý getiriyor, UNION Benzersizlik kaydýný göz önüne alýyor.

Select * from Ogrenciler
UNION ALL
Select * from OgrencilerYedek; 

Select * from Ogrenciler
UNION 
Select * from OgrencilerYedek; 

Select ID, TCNO from Ogrenciler
UNION
Select ID, TCNO from OgrencilerYedek;

--CASE WHEN KULLANIMI (if else switch gibi bir þey)

--SORU1: Öðrenci bilgilerini getiren ve cinsiyeti E ise +500 ek maaþ hesaplayan, cinsiyeti K ise +600 ek maaþ, diðerleri için +450 ek maaþ hesaplayan sql?
Select o.*, 
CASE Cinsiyeti
    When 'E' Then 500
    When 'K' Then 600
    Else 450
END EkMaas

from Ogrenciler o;

/*SORU2:
Cinsiyeti E ve Bölümü Bilgisayar olanlara 500, 
Cibnsiyeti E ve Bölümü Biliþim olanlara 575, 
Cinsiyeti E ve Bölümü Uçak olanlara 550,
Cinsiyeti K olanlara 600, 
diðerlerine 450 ek maas hesaplayan sql? */

Select O.*,

CASE
  When o.Cinsiyeti = 'E' AND o.BKodu = 'B1' Then 500
  When o.Cinsiyeti = 'E' AND o.BKodu = 'B2' Then 575
  When o.Cinsiyeti = 'E' AND o.BKodu = 'B3' Then 550
  When o.Cinsiyeti = 'K' Then 600
  Else 450
END EkMaas

from Ogrenciler o;

--SORU3: Soruya ilave olarak Bölüm Adlarýný kullanarak eþleþtirmeyi saðlayan sql? (alt sorgu)


Select O.*,

CASE
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bilgisayar') Then 500
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Biliþim') Then 575
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Uçak') Then 550
  When o.Cinsiyeti = 'K' Then 600
  Else 450
END EkMaas,

(Select Adi from Bolumler WHERE Kodu = o.BKodu) BlmAdi

from Ogrenciler o;

--2.YOL JOÝN ÝLE

Select O.*,
CASE
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bilgisayar') Then 500
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Biliþim') Then 575
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Uçak') Then 550
  When o.Cinsiyeti = 'K' Then 600
  Else 450
END EkMaas,

b.Kodu BlmKodu, b.Adi BlmAdi

from Ogrenciler o LEFT JOIN Bolumler b ON o.BKodu = b.Kodu; --lEFT soldaki tabloya ait bütün satýrlarý getiriyor. Soldakiyle eþleþenleri yazýyor eþleþmeyenlere Null diyor)
CREATE VIEW OgrenciBilgileri AS

Select O.*,
CASE
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bilgisayar') Then 500
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Biliþim') Then 575
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Uçak') Then 550
  When o.Cinsiyeti = 'K' Then 600
  Else 450
END EkMaas,

b.Kodu BlmKodu, b.Adi BlmAdi

from Ogrenciler o LEFT JOIN Bolumler b ON o.BKodu = b.Kodu;

--VIEW kullanýmý tablo oluþturmasý dýþýnda tablo gibi de kullanýlabilir. Birden fazla view kullanabiliriz.
--SORU1: Ýçinde Öðrencisi olan bölümleri getiren sql? 
--1.Yol IN kullanarak

Select b.* from Bolumler b WHERE b.Kodu IN ('B1' , 'B2' , 'B3' , 'B4');

Select b.* from Bolumler b WHERE b.Kodu IN(Select o.BKodu from Ogrenciler o WHERE o.BKodu is not null GROUP BY o.BKodu);

--2.Yol EXISTS kullanarak (exists daha hýzlý çalýþýyor)
Select b.* from Bolumler b WHERE EXISTS(Select o.ID from Ogrenciler o WHERE o.BKodu = b.Kodu)

--SORU2: Ýçinde Öðrenci olmayan bölümleri getiren sql?

Select b.* from Bolumler b WHERE b.Kodu NOT IN(Select o.BKodu from Ogrenciler o WHERE o.BKodu is not null GROUP BY o.BKodu);

Select b.* from Bolumler b WHERE NOT EXISTS(Select o.ID from Ogrenciler o WHERE o.BKodu = b.Kodu)
CREATE TABLE MyData AS
Select o.*, (strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as YAS from Ogrenciler o;

CREATE VIEW MyView AS
Select o.*, (strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as YAS from Ogrenciler o;

Select AVG(YAS) yasort, ROUND(AVG(YAS) , 2 ) yasort1 from MyData Where DTarihi is not null;

Drop Table if Exists MyData;
Select date('now') Bugun;

Select time('now') Simdi, time('now', 'Localtime') SimdiYerel;

Select datetime() as BugunSimdi, datetime('now' , 'Localtime') as BugunSimdiYerel; --localtime now ile birlikte kullanýlýr.

Select date('2014-10-16' , 'start of month' ), date('now') ,  date('now','start of month' );

Select date ('now'), date('now' , '+5 years'), date('now' , '+5 month');

SELECT date('2014-10-16', 'start of month','+1 month', '-1 day');

Select date('now' , 'weekday 2'); --Bir sonraki haftanýn Salý günü

Select strftime('%d.%m.%Y' , '2018-05-22') , strftime( '%d.%m.%Y' , 'now');
Select strftime('%Y' , '2018-05-22');

--Öðrencilerin yaþ ortalamnasýný bulan ve getiren sql?
Select o.* from Ogrenciler o WHERE o.Dtarihi is not null;

Select o.*, (strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as YAS from Ogrenciler o;

Select AVG(strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as ORTALAMA from Ogrenciler o WHERE o.Dtarihi is not null;



CREATE TABLE MyData AS
Select o.*, (strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as YAS from Ogrenciler o;

CREATE VIEW MyView AS
Select o.*, (strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as YAS from Ogrenciler o;

Select AVG(YAS) from MyData Where DTarihi is not null;
-- SQLite System Tables

Select * from sqlite_sequence; --ID'de kullanýlan en son deðeri gösteriyor.

Select * from sqlite_master; --Örneðin veri tabanýmýzda Elmalar isminde bir tablo var mý yok mu? Detaylý þekilde görmemizi saðlar.

--Elmalar isminde tablo var mý yok mu?
Select * from sqlite_master WHERE Name = 'Elmalar' and Type = 'table';

Select * from sqlite_master WHERE Name = 'Dersler' and Type = 'table';
CREATE TABLE OgrenciDersler (
    ID          INTEGER       CONSTRAINT Pk_OgrenciDersler_Id PRIMARY KEY ASC AUTOINCREMENT,
    OgrenciNo   VARCHAR (15)  NOT NULL
                              CONSTRAINT FK_Ogrenciler_OgrenciDersler_OgrenciNo REFERENCES Ogrenciler (OgrenciNo) ON UPDATE CASCADE,
    DersKodu    VARCHAR (10)  NOT NULL
                              CONSTRAINT FK_Dersler_OgrenciDersler_Kodu REFERENCES Dersler (Kodu) ON UPDATE CASCADE,
    Vize        FLOAT (3, 2),
    Final       REAL (3, 2),
    Ortalama    DOUBLE (3, 2),
    HarfNotu    VARCHAR (3),
    KayitTarihi DATETIME      DEFAULT (datetime('now', 'localtime') ) 
);
CREATE TABLE Ogrenciler (
    ID        INTEGER      CONSTRAINT Pk_Ogrenciler_Id PRIMARY KEY ASC AUTOINCREMENT,
    TCNO      VARCHAR (11) CONSTRAINT Uq_Ogrenciler_Tcno UNIQUE
                           NOT NULL,
    OgrenciNo VARCHAR (15) CONSTRAINT Uq_Ogrenciler_OgrenciNo UNIQUE
                           NOT NULL,
    Ad        VARCHAR (30) NOT NULL
                           COLLATE NOCASE,
    Soyadi    VARCHAR (30) NOT NULL
                           COLLATE NOCASE,
    Cinsiyeti VARCHAR (1)  NOT NULL
                           DEFAULT ('E'),
    BKodu     VARCHAR (5)  NOT NULL
                           DEFAULT (''),
    DTarihi   DATE
);
PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM Ogrenciler;

DROP TABLE Ogrenciler;

CREATE TABLE Ogrenciler (
    ID        INTEGER      CONSTRAINT Pk_Ogrenciler_Id PRIMARY KEY ASC AUTOINCREMENT,
    TCNO      VARCHAR (11) CONSTRAINT Uq_Ogrenciler_Tcno UNIQUE
                           NOT NULL,
    OgrenciNo VARCHAR (15) CONSTRAINT Uq_Ogrenciler_OgrenciNo UNIQUE
                           NOT NULL,
    Ad        VARCHAR (30) NOT NULL
                           COLLATE NOCASE,
    Soyadi    VARCHAR (30) NOT NULL
                           COLLATE NOCASE,
    Cinsiyeti VARCHAR (1)  NOT NULL
                           DEFAULT ('E') 
                           CHECK (Cinsiyeti IN ('E', 'K') ),
    BKodu     VARCHAR (5)  NOT NULL
                           DEFAULT (''),
    DTarihi   DATE
);

INSERT INTO Ogrenciler (
                           ID,
                           TCNO,
                           OgrenciNo,
                           Ad,
                           Soyadi,
                           Cinsiyeti,
                           BKodu,
                           DTarihi
                       )
                       SELECT ID,
                              TCNO,
                              OgrenciNo,
                              Ad,
                              Soyadi,
                              Cinsiyeti,
                              BKodu,
                              DTarihi
                         FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

PRAGMA foreign_keys = 1;

-- Ogrencidersler tablosunda ayný dersi 1 den fazla alan ögrenci ve ders bilgilerini getiren sql?
Select DersKodu, OgrenciNo, COUNT(*) as Sayi from OgrenciDersler GROUP BY DersKodu, OgrenciNo HAVING COUNT(*) > 1;
--SORU1: Toplam Öðrenci Sayýsýný getiren sql?
Select COUNT(*) as OgrSayisi from "Ogrenciler";

--SORU2: Cinsiyetine göre öðrenci sayýsýný getiren sql?
Select "Cinsiyeti", COUNT(*) as Sayi from "Ogrenciler" GROUP BY "Cinsiyeti";

--SORU3: Bölümlerine göre öðrenci sayýsýný getiren sql?
Select "BKodu" , COUNT(*) as OgrSayisi from "Ogrenciler" GROUP BY "BKodu";

--SORU4: Bölüm ve Cinsiyetlerine göre öðrenci sayýsýný getiren sql?
Select "BKodu", "Cinsiyeti", COUNT(*) as OgrSayi from "Ogrenciler" GROUP BY "BKodu", "Cinsiyeti";

--SORU5: Bölüm, Cinsiyet, Sýnýf'larýna göre öðrenci sayýsýný getiren sql?
Select "BKodu", "Cinsiyeti", "Sinifi", COUNT(*) as OgrSayi from "Ogrenciler" GROUP BY "BKodu", "Cinsiyeti", "Sinifi";

--SORU6: Ýçerisinde 1 den fazla Öðrencisi olan bölümleri getiren sql?
Select "BKodu", COUNT(*) as OgrSayisi from "Ogrenciler" GROUP BY "BKodu" HAVING COUNT(*)>1;

--SORU7: Öðrencilerin tüm bilgilerini Bölüm Adlari ile birlikte getiren sql? 
--(1- JOIN kullarak) 
Select O.*, b."Adi" BolumAdi FROM "Ogrenciler" o INNER JOIN "Bolumler" b on b."Kodu" = o."BKodu";
Select O.*, b."Adi" BolumAdi FROM "Ogrenciler" o LEFT JOIN "Bolumler" b on b."Kodu" = o."BKodu";

--(2- SubQuery (Alt Sorgu) kullanarak)
Select o.*, (Select b."Adi" From "Bolumler" b WHERE b."Kodu"= o."BKodu") BolumAdi from "Ogrenciler" o;

--SORU8:
--Drop Table if Exists "Ogrenciler" --Eðer varsa öðrenciler tablosunu sil
--Drop Table if exists "Bolumler "

--int2:small insteger, int4:integer, int8:long integer.
--serial: integer gibi çalýþýr otomatik alanlar için kullanabiliriz
--Yedekten veri alacaðýmýz için primary key'den sonra autoincrement ve null yazmadýk.

/*
Create Table Bolumler(
   Id integer CONSTRAINT PK_Bolumler_Id PRIMARY KEY, 
   Kodu CHARACTER VARYING(5) CONSTRAINT UQ_Bolumler_Kodu UNIQUE NOT NULL,
   Adi CHARACTER VARYING(30) NOT NULL
);
*/

--Þimdi Yedekteki verileri geri getireceðiz.
/*
INSERT INTO bolumler(Id, Adi, Kodu)
Select "Id", "Adi", "Kodu" from bolumleryedek;
*/

--Drop Table if Exists "Ogrenciler"

/*Create Table ogrenciler(
	Id int4 CONSTRAINT PK_Ogrenciler_Id Primary Key,
	OgrenciNo varchar(10) CONSTRAINT UQ_Ogrenciler_OgrNo UNIQUE NOT NULL,
	TCNo varchar(11) CONSTRAINT UQ_Ogrenciler_TcNo UNIQUE NOT NULL CONSTRAINT CK_Ogrenciler_tcNo CHECK(length(tcNo)>=3),
	Adi CHARACTER VARYING(30) NOT NULL,
	Soyadi CHARACTER VARYING(30) NOT NULL,
	Cinsiyeti varchar(1) NOT NULL DEFAULT 'E' CONSTRAINT CK_Ogrenciler_Cinsiyet CHECK(cinsiyeti = 'E' OR cinsiyeti = 'K'),
	bkodu varchar(5),
	Sinifi int2 NOT NULL DEFAULT 1,
	CONSTRAINT FK_Ogrenciler_Bolumler_BKodu FOREIGN KEY(bkodu) REFERENCES bolumler(kodu)
);*/

--INSERT INTO ogrenciler Select * from ogrencileryedek; 

--Select * from ogrenciler;

--DROP TABLE bolumleryedek;
--DROP TABLE ogrencileryedek;
CREATE TABLE dersler( 
    id SERIAL CONSTRAINT PK_Dersler_id PRIMARY KEY,
    kodu Varchar(10) CONSTRAINT UQ_Dersler_Kodu UNIQUE NOT NULL,
    adi Varchar(40) NOT NULL,
	teorik int2 NOT NULL DEFAULT 0,
	uygulama int2 NOT NULL DEFAULT 0,
	kredi int2 NOT NULL DEFAULT 0,
	akts int2 NOT NULL DEFAULT 0,
	
	turu varchar(1) NOT NULL DEFAULT 'Z' 
	CONSTRAINT CK_Dersler_Turu 
	CHECK(turu IN('Z', 'S')),
	
	kategori varchar(1) NOT NULL DEFAULT 'Z' 
	CONSTRAINT CK_Dersler_Kategori 
	CHECK(kategori='Z' OR kategori='MS' OR kategori='MOS' OR kategori = 'ADS')

)


--CASCADE: Ýki tablo arasýnda iliþki kurduðumuz zaman tekinde deðiþikliðe uðradýðý zaman diðerinde de deðiþtirir. Buna izin verir. Otomatik günceller.
--Birden fazla sütunu barýndýran unique yazdýk.

CREATE TABLE ogrenciDersler(	
   id SERIAL PRIMARY KEY,
   ogrenciNo Varchar(10) NOT NULL,
   derskodu Varchar(10) NOT NULL,
   donem varchar(15) NOT NULL DEFAULT '22-23-G',
   vize FLOAT NOT NULL DEFAULT 0,
   fnl FLOAT NOT NULL DEFAULT 0,
   ortalama FLOAT,
   harfnotu Varchar(2),
	
   CONSTRAINT FK_ogrenciler_OgrDersler_OgrNo FOREIGN KEY (ogrenciNo) REFERENCES ogrenciler(ogrenciNo) on update CASCADE,
	
   CONSTRAINT FK_dersler_OgrDersler_BKodu FOREIGN KEY (derskodu) REFERENCES dersler(kodu) on update CASCADE,
	
   CONSTRAINT UQ_OgrenciDersler_Ogr_Ders_Donem UNIQUE(ogrenciNo, dersKodu, donem) 
	
)
Select O.* from "Ogrenciler" O WHERE o."Adi" = 'Deniz';

Insert Into "Bolumler" ("Kodu","Adi") Values ('B3', 'Kontrol Otomasyon') , ('B4' , 'Ýþletme');
                    
					
Select * from public."Bolumler"
--DÖNGÜLER
--Continue: Tekrar baþa dönüp devam ediyor
--0 ile 50 arasýndaki sayýlardan 5'e tam bölünmeyen sayýlarýn toplamýný bulan, sayýlarýn toplamlarý 400 ve daha büyük olunca durduran sql?

do $$
DECLARE sayac INTEGER :=1;
DECLARE toplam INTEGER :=0;
BEGIN
While sayac <= 50 loop

	   if mod(sayac, 5)=0 then
	   sayac := sayac + 1;
	   continue;
	   end if;
	   
	   raise notice 'Ýslem Yapýlan Sayý: %', sayac;
	   toplam:= toplam + sayac;
	   if (toplam >=400) then
	   Exit;
	   end if;
	   
	   sayac := sayac + 1;
	   
  End loop; 
  
       raise notice 'Toplam : %', toplam;
   
END $$;
--DÖNGÜLER 
--Exit

do $$
DECLARE sayac INTEGER := 0;
DECLARE toplam INTEGER := 0;
BEGIN
--0 ile Sayaç arasýndaki sayýlardan 100 deðerine ulaþýncaya kadar toplama iþlemini yapan program;
While sayac <= 40 loop
     raise notice 'Adým: %' , sayac;
	 sayac := sayac + 1;
	 toplam := toplam + sayac;
	 if toplam >= 100 then
	 Exit; --Java da ise break kullanýyorduk
	 end if;
     end loop;
	 raise notice 'Toplam: %' , toplam; --Döngüden çýktýktan sonra toplamý yazdýrýyoruz
	 
End $$;
--DÖNGÜLER
--RECORD VERÝ TÝPÝ
--Öðrenciler tablosundan OgrNo, Adi, Soyadi bilgilerini mesaj olarak Konsola yazdýran sql?

--Select * from "ogrencileryedek";

do $$
DECLARE ogr record;
BEGIN
   for ogr in Select "OgrenciNo", "Adi", "Soyadi" from "ogrencileryedek" loop
   raise notice 'OgrenciNo: % Adi: % Soyadi: % ADI SOYADI: %', 
   ogr."OgrenciNo", ogr."Adi", ogr."Soyadi", ogr."Adi" || '--' || ogr."Soyadi";
   
   end loop;
   
END$$;
-- Select * from pg_database; --Var olan database'leri getirdi

--DÖNGÜLER
--ilk önce arka planda deðiþken tanýmlamasý yapacaðýz.

--WHILE DÖNGÜSÜ
/*do $$
DECLARE sayac integer := 5;
BEGIN --Kodlarý içine yazacaðýz
while sayac > 0 loop --Koþullarý belirtelim, posgrede  loop var(otomatik olarak altýnda begin barýndýrýyor o yüzden loop, end loop yapýyoruz)
  raise notice 'Sayaç: %' , sayac; --raise notice ekrana yazdýrýyor
  sayac := sayac - 1;
  end loop;
END$$;
*/

do $$
DECLARE toplam integer := 0;
BEGIN
  raise notice 'For Döngüsü Örneði';
  for i in 1..10 loop --Bu sefer sayac yerine i tanýmladýk. Otomatik deðiþken olarak integer olarak tanýmladý. --in reverse ise tersten sayýyor -- in 1..6 by 2 (by 2 þer arttýr demek)
    raise notice'For sayaç: %' , i;
  end loop;
  
  raise notice'Tersten For Döngüsü';
  for n in reverse 10..5 loop
    raise notice 'n : %' , n;
  end loop;
 
 raise notice 'Step By Step For';
 for  x in 0..10 by 2 loop --0 ile 10 arasýndaki çift sayýlarýn toplamý (0 ve 10'u da dahil ediyor)
    toplam:= toplam + x;
 end loop;
 raise notice 'Toplam:= %' , toplam;
  
END$$;
Select * from bolumler; 

INSERT INTO bolumler (kodu,adi) VALUES('b6', 'bolum-6'); --Bolumler sað týkla properties, columns, Id'yi start kýsmýný 4 yaptým ýd ordan devam etsin diye.

Select * from ogrenciler Order by Id desc; --burada da startý 8 yaptým

INSERT INTO ogrenciler(ogrencino, tcno, adi, soyadi, cinsiyeti, bkodu, sinifi)
VALUES('O8', '222', 'Özge', 'Gülsoy', 'K', null, 2);

--select * into BolumlerYedek from "Bolumler ";

--select * into OgrencilerYedek from "Ogrenciler";

--Truncate table "Bolumler "; --Bolumler tablosu baþka tabloyla iliþkilendirildiði için bunu yapamazsýn diye hata veriyor.

--Delete from "Bolumler "; --DELETE ile sildiðimiz zaman eski veriler arka planda tutuluyor.

--Truncate table "Ogrenciler"; --Önce öðrencileri truncate ettik sonra delete bolumler yaptýk.. Öðrencilerin verileri truncate ile yok oldu.

--TRUNCATE ile sildiðimiz zaman haarddiskten de siliniyor.

TRUNCATE TABLE "Ogrenciler" RESTART IDENTITY; --Tüm ID'leri resetledi.

Select * from "Ogrenciler";
Select * from "Bolumler ";

--Insert Into "Bolumler " ("Kodu", "Adi") Values('b1', 'bölüm1');

--Insert Into "Bolumler " ("Kodu", "Adi") Values('b2', 'bölüm2');

--Insert Into "Bolumler " ("Kodu", "Adi") Values('b3', 'bölüm3');

Insert Into "Ogrenciler" ("OgrenciNo", "TCNo","Adi","Soyadi","BKodu", "Sinifi") 
Values('O2', '123', 'Ertuðrul', 'DUMAN', 'b1', 'E', 1);

--TRUNCATE TABLE "Bolumler " RESTART IDENTITY;
--TRUNCATE TABLE "Ogrenciler" RESTART IDENTITY;

--Delete from "Bolumler ";

--Yedekten verileri geri alacaðýz. Otomatik artan var mý yok mu diye kontrol edeceðiz önce. Varsa iptal edeceðiz.

Select * from "Bolumler ";

--Insert Into "Bolumler " ("Adi" , "Kodu", "Id") Select "Adi", "Kodu", "Id" from bolumleryedek
				  
--Insert Into "Bolumler " ("Kodu", "Adi") VALUES ('B8', 'Bölüm8')
				  
Insert Into "Bolumler " ("Adi" , "Kodu") Select "Adi", "Kodu" from bolumleryedek


