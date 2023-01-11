-------------------------------------------------------------SQL �rnekler----------------------------------------------------------------------------
------------------------fak�lteler tablosunu varsa silen ve olu�turan sql kodunu yaz�n�z
drop table if exists Fakulteler
go
if not exists (Select * from sys.tables where name=N'Fakulteler')
create table Fakulteler (
Id int, 
Adi varchar(50), 
Kodu varchar(10) constraint UQ_Fakulteler_Kodu unique) 


------------------------b�l�mler tablosu ile fak�lteler tablosunu ili�kilendiren sql kodunu yaz�n�z
ALTER TABLE Bolumler 
ADD FakulteKodu VARCHAR(10)  constraint fk_Bolumler_Fakulteler_Fkodu foreign key references Fakulteler(Kodu) on update cascade 

------------------------��rencilerin harf notlar�n�n hesaplat�lmas�, d�nemlik ortalamalar�n�n hesaplat�lmas�(toplu olarak yap�lmal�)
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


------------------------��rencilerin b�l�mad� ve fak�lte adlar�yla birlikte t�m bilgilerini getiren sql
------------------------(b�l�mlere alan ekle hangi fak�lteye ait)
Select o.*, b.Adi as BolumAdi, (Select Adi from Fakulteler f where f.Kodu = b.FakulteKodu) as FakAdi from Ogrenciler o left join Bolumler b on o.BKodu=b.Kodu


------------------------ogrencidersler tablosundaki t�m verileri ��renci ad soyad (tek s�tunda) ve ders ad� bilgileriyle getiren sql
Select od.*, o.Adi+' '+o.Soyadi as AdSoyad, (Select adi from Dersler where Dersler.kodu=od.DersKodu) from OgrenciDersler od left join Ogrenciler o on o.OgrenciNo = od.OgrenciNo

--S1: Toplam ��renci Say�s�n� Veren SQL?
--Select Count(*) as OgrSayisi From "Ogrenciler";
--S2: Cinsiyetine G�re ��renci Say�lar�n� Getiren SQL?
--Select Count(*) as OgrSayisi, "Cinsiyeti" From "Ogrenciler" GROUP BY "Cinsiyeti";

--S3: Bolumlerine G�re ��renci Say�lar�n� Getiren SQL?
--Select "BKodu", Count(*) as OgrSayisi From "Ogrenciler" GROUP By "BKodu";

--S4: B�l�m ve Cinsiyetlerine G�re ��renci Say�lar�n� Getiren SQL?
--Select "BKodu", "Cinsiyeti", Count(*) as OgrSayisi From "Ogrenciler" GROUP By "BKodu", "Cinsiyeti";

--S5: B�l�m, Cinsiyet ve S�n�flar�na G�re ��renci Say�lar�n� Getiren SQL?
--Select "BKodu", "Cinsiyeti", "Sinifi", Count(*) as OgrSayisi From "Ogrenciler" GROUP By "BKodu", "Cinsiyeti", "Sinifi";

--S6: ��ersinde 1 den Fazla ��rencisi Olan b�l�mleri Getiren SQL? (Sorgu Sadece Ogrenciler Tablosuna Yap�lacak)
--Select "BKodu", Count(*) OgrSayisi From "Ogrenciler" Group By "BKodu" Having Count(*) >= 2;
--S7: ��rencilerin T�m Bilgilerini B�l�m Adlar� ile birlikte getiren SQL?
--(1. Join Kullanarak, 2 Altsorgu Kullanarak)
--1 Y�ntem JOIN ile
--Select o.*, b."Adi" as BolumAdi From "Ogrenciler" o inner Join "Bolumler" b on b."Kodu" = o."BKodu";
--Select o.*, b."Adi" BolumAdi From "Ogrenciler" o Left Join "Bolumler" b on b."Kodu" = o."BKodu";
--2. Y�ntem SubQuery (Alt Sorgu)
Select o.*, (Select  b."Adi" From "Bolumler" b  where b."Kodu" = o."BKodu" ) BolumAdi From "Ogrenciler" o; 

--DECALRE --if
--Donguler
--Case When
--Soru: Veritaban� Tablolar�na Yeni S�tun Eklemeden ��rencilerin Bolumlerine G�re Almalar� Gereken Ders Say�s�n� Hesplayan/Getiren SQL?
/*
bilgisyar prog = 10
bili�im g�venli�i = 11
U�ak teknoljisi = 9
Di�erleri = 8
*/
Select "OgrenciNo", "Adi", "Soyadi", "BKodu",

Case "BKodu" When 'B1' then 10
			 When 'B2' then 11
			 else 8
END DersSayisi

from ogrencileryedek;

--D�ng�ler Exit

do $$
	Declare sayac INTEGER := 0;
	Declare toplam Integer := 0;
begin
	--0 ile sayac aras�ndaki say�lardan 100 de�erine ula��nc�ya kadar 
	--Toplama i�lemini yapan program	 
	
	while sayac <= 40 loop
		raise notice 'Ad�m: %', sayac;
		toplam := toplam + sayac;
		if (toplam >= 100) then
			Exit;
		end if;
		
		sayac := sayac + 1;
	end loop;
	raise notice 'Toplam: %', toplam;

end$$;
















--Donguler Continue
--Soru: 0 ile 50 aras�ndaki say�lardan 5'e tam b�l�nmeyen say�lar�n toplamlar�n� 400 ve daha b�y�k oluncaya kadar bulan program/SQL

do $$
	Declare sayac Integer := 1;
	Declare toplam Integer:=0;
begin
	while sayac <= 50 loop
		
                      if mod(sayac, 5) = 0 then
			sayac := sayac + 1;
			continue;
		end if;

		raise notice '��lem Yap�lan Say�: %', sayac;
		toplam := toplam + sayac ;
		
		if(toplam >= 400) then
			exit;
		end if;
		
           sayac := sayac + 1;
		
           End loop;

	raise Notice 'Toplam : %', toplam;

END $$;

--D�ng�ler
--Record veri tipi
-- Ogrenciler Tablosundan Ogrno, Adi ve Soyadi Bilgilerini Mesaj olarak Konsola yazd�ran Program
--Select * from "Ogrenciler";

do $$
	Declare ogr record;
	Declare ogrders record;
	DECLARE ort float;
	Declare hn varchar(2);
begin

	for ogr in Select ogrenciNo, adi, soyadi From ogrenciler  Loop
		
		raise notice 'OgrenciNo: %  Ad�: % Soyad�: %  ADI SOYADI: %', 
		ogr.ogrenciNo, ogr.adi, ogr.soyadi , ogr.Adi ||  '--' || ogr.soyadi;
		
		for ogrders in Select od.*, d.kredi as DKredi from ogrencidersler od left join dersler d on d.kodu = od.dersler
		 where od.ogrenciNo = ogr.ogrenciNo 		
		LOOP
		
			ort := (ogrders.vize * 0.4) + (ogrders.fnl * 0.6);
			hn := 'BA';
			/*
				ortalama ve harfnotu hesab� yap�ld�
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

--D�NG�LER
--While D�ng�s�
/*
do $$
	DECLARE sayac INTEGER := 5;

BEGIN
	while sayac > 0 loop
		raise notice 'Saya� : % ',sayac ;
		sayac := sayac - 1;
	
	end loop;


End$$;

*/
do $$
	Declare toplam INTEGER:= 0;
Begin
	raise notice 'For D�ng�s� �rne�i';
	
	for i in 1..10 loop
	    raise notice 'For Saya�: %', i ;
	end loop;
	
	raise notice 'Tersten For D�ng� �rne�i';
	for n in reverse 10..5 loop
		raise notice 'n : %', n;
	end loop;
	
	raise notice 'Step By Step For ';
	--0 ile 10 aras�ndaki �ift say�lar�n Toplam�
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

--insert into bolumler (kodu, adi) values('b5', 'b�l�m-5');


Select * from ogrenciler Order by id desc;

insert into ogrenciler (ogrencino, tcno, adi, soyadi, cinsiyeti, bkodu, sinifi)
Values('O7', '777', 'Yelda', 'YILMAZ', 'K', null, 2);
*/
--V�ZE Haz�rl�k Sorular
--1: ��renci Bilgilerini b�l�m Ad� ile birlikte Getiren SQL
--2: Fakulteler tablosunu olu�turan, i�erisine en az 3 kay�t ekleyen sql
--3: Fak�lteler tablosu ile ��renciler veya b�l�mler ile ili�kilendiriniz
--4: ��renci Bilgilerini Fak�lte Ad� ve B�l�m Ad� ile birlikte Getiren SQL
--5: OgrenciDersler Tablosundaki verilere g�re (vize,final notu) ilgili kay�tlara ait 
--ortalama ve harf notu hesab�n� yapan, 
--��rencilerin d�nem bazl� Ag�rl�kl� not ortalmas�n� hesaplayan ve ekrana yazd�ran/getiren SQL?

--Insert Into "Bolumler" Values('B6', 'Deneme');
--Select * from public."Bolumler"

--Insert Into public."Ogrenciler" ("OgrenciNo", "TCNo", "Adi", "Soyadi", "Cinsiyeti", "BKodu")
--Values('O2', '321', 'Melisa', 'AKTUNA', 'K', NULL);

Insert Into public."Ogrenciler" ("OgrenciNo", "TCNo", "Adi", "Soyadi", "Cinsiyeti", "BKodu")
Values('O3', '333', 'Mehmet Can', 'ATAR', 'E', 'B2'),
('O4', '444', 'Muhammed Emre', 'G�RB�Z', 'E', 'B3'),
('05', '555', 'Berkay', 'AKYOL', 'E', 'B1'),
('06', '666', 'Tu��e', 'ERANIL', 'K', 'B4');


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
				 
--Insert into "Bolumler" ("Kodu", "Adi") Values('B5', 'B�l�m5')
				 

--Select * into BolumlerYedek From "Bolumler";

--Select * into OgrencilerYedek From "Ogrenciler";

--Truncate table "Bolumler";

--Delete From "Bolumler";

--Truncate Table "Ogrenciler";
TRUNCATE TABLE "Ogrenciler" RESTART IDENTITY;

Select * from "Bolumler";
Select * from "Ogrenciler";

--Insert Into "Bolumler" ("Id", "Kodu", "Adi") Values(9,'b5', 'b�l�m5');
--Insert Into "Ogrenciler" ("OgrenciNo", "TCNo", "Adi", "Soyadi", "BKodu", "Cinsiyeti", "Sinifi")
--Values('O2', '321', 'Ali�an', 'YILDIZ', 'b1', 'E', 2)

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

--SORU1-Toplam ��renci say�lar�n� veren sql? (�ki �ekilde yapar�z ama * yapmak avantajl� de�il sadece pratik, ger�ek datalarda * kullanmamaly�z)
Select COUNT(ID) as OgrSayisi from Ogrenciler;
Select COUNT(*) as OgrSayisi from Ogrenciler;

--SORU2-Toplam Ders say�lar�n� veren sql?
Select COUNT(*) DersSayisi from Dersler;

--SORU3-Kredi Toplamlar�n� veren sql? SUM Sat�r baz�nda, Count hem sat�r hem s�tun baz�nda �al���r.
Select SUM(Kredi) TopKredi from Dersler;

--SORU4-Kredi ve AKTS Toplamlar�n� veren sql? 1 Sat�r 1 s�tuna H�CRE denir. �kiside tek bir de�er d�nd�rd��� i�in ard arda SUM yazabildik.
Select SUM(Kredi) TopKredi, SUM(AKTS) AKTSToplam from Dersler;

--SORU5-En B�y�k Ders Kredisini bulan sql?
Select MAX(Kredi) as EnBuyukKredi from Dersler;

--SORU6-En K���k Ders Kredisini bulan sql?
Select MIN(Kredi) EnKucukKredi from Dersler;

--SORU7-Derslerin Ortalama Kredi De�erini veren sql? AVG Ortalamay� verir.
Select AVG(Kredi) OrtKredi from Dersler;

--SORU8-Derslerin Ortalama Kredi De�erini hesaplayan VE virg�lden sonra 2 haneye yuvarlayan sql? ROUND yuvarl�yor.
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
--GROUP BY, HAVING Kullan�m� -- SELECT, WHERE, GROUP BY, HAVING, UNION, ORDER BY Kullan�m s�ras�

--SORU1 - Cinsiyetine g�re �grenci say�s�n� getiren sql?
Select Cinsiyeti, COUNT(*) as Sayi from Ogrenciler GROUP BY Cinsiyeti; --Geriye tek de�er d�nd�ren (Count, Sum gibi) bir SQL ifadesinin oldu�u yerde bu fonksiyonlar d���nda herhangi bir tablo alan� yaz�lacak ise bu alan�n grupland�r�lmas� gerekir(GROUP)

--SORU2 - B�l�mlerine g�re toplam �grenci say�s�n� getiren sql?
Select BKodu, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu;

--SORU3 - B�l�m� ve cinsiyetine g�re toplam �grenci say�s�n� getiren sql?
Select BKodu, Cinsiyeti, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu, Cinsiyeti;
                                       
--SORU4 - B�l�mlerine g�re toplam �grenci sayisi 2 ve daha fazlas� olan kay�tlar� getiren sql?
Select BKodu, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu HAVING Sayi >=2; --Having �art ko�uyor
Select BKodu, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu HAVING COUNT(*) >=2; --Sayi ��kmayabilir sorun olu�turabilir, Count'a ba�lad�k

--SORU5 - B�l�mlerine g�re toplam �grenci sayisi 2 ve daha fazlas� olan VE B�l�m Koduna g�re azalan �ekilde s�ralayan sql?
Select BKodu, COUNT(*) as Sayi from Ogrenciler GROUP BY BKodu HAVING COUNT(*) >=2 ORDER BY BKodu Desc;

--SORU6- Cinsiyeti E olan ve B�l�mlerine g�re toplam �grenci sayisi 2 ve daha fazlas� olan VE B�l�m Koduna g�re azalan �ekilde s�ralayan sql?
Select BKodu, COUNT(*) as Sayi from Ogrenciler WHERE Cinsiyeti = 'E' GROUP BY BKodu HAVING COUNT(*) >=2 ORDER BY BKodu Desc;

--IN(���NDE), BETWEEN(ARASINDA) KULLANIMI

--SORU1: Dersler tablosundan ID de�eri 1,3,4,5 olan kay�tlar� getiren sql?
SELECT * from Dersler WHERE ID=1 OR ID=3 OR ID=4 OR ID=5;
Select * from Dersler WHERE ID IN(1,3,4,5);

--SORU2: Dersler tablosundan Kodu BLG103, BLG104, BLG105 olan kay�tlar� getiren sql? (OR yerine IN kullanabiliyoruz, milyonluk kay�tlarda OR daha iyidir)
Select * from Dersler WHERE Kodu='BLG103' OR Kodu='BLG104' OR Kodu='BLG105';
Select * from Dersler WHERE Kodu IN('BLG103', 'BLG104', 'BLG105');

--SORU3: Dersler tablosunda ID de�eri 2-6 aras�nda olan kay�tlar� getiren sql?(2 ve 6 da dahil olarak al�yoruz e�er almazsak BETWEEN 3 AND 5 derdik)
Select * from Dersler WHERE ID>=2 AND ID<=6;
Select * from Dersler WHERE ID BETWEEN 2 AND 6;

Select * from Dersler;

--INSERT(KAYIT EKLEME)
Insert Into Dersler VALUES (4, 'BLG244', 'Deneme Dersi', 5, 5, 0, 1, 'MOS', NULL);

Insert Into Dersler (Kodu, Adi, Turu, Kredi, AKTS) VALUES('BLG250', 'Sa�l�kl� Ya�am','MOS', 2, 3);

--UPDATE(KAYIT G�NCELLEME)
UPDATE Dersler SET Teorik=0;

UPDATE Dersler SET Teorik = Kredi-1, Uygulama=0;

UPDATE Dersler SET Teorik=1, Uygulama=1 WHERE Turu='Z';

--SORU1: Dersler tablosundaki verilerden kredisi 4 ve b�y�k olanlar� VE turu Z olanlar�n teorik 0, uygulama -1 olarak g�ncelle
UPDATE Dersler SET Teorik=0, Uygulama=-1 WHERE Turu= 'Z' AND Kredi>=4; --VE-AND-&& / VEYA-OR-||

--DELETE(KAYIT S�LME)
DELETE from Dersler WHERE Turu='MOS' AND Kredi<=2;
Select * from Dersler WHERE Turu = 'MOS' AND Kredi <=2;
--LIKE(BENZER-��ER�R) KULLANIMI
Select * from Ogrenciler;

--SORU1 - �smi A ile ba�layan ��rencileri getiren sql?
Select * from Ogrenciler WHERE Ad LIKE 'A%';

--SORU2 - �smi AY ile ba�layan ��rencileri getiren sql?
Select * from Ogrenciler WHERE Ad LIKE 'Ay%';

--SORU3 - Soyadi Z ile biten ��rencileri getiren sql?
Select * from Ogrenciler WHERE Soyadi LIKE '%Z';

--SORU4 - Ad�n�n i�inde E harfi olan ��rencileri getiren sql? 
Select * from Ogrenciler WHERE Ad LIKE '%E%';

--SORU5 - Ad�n�n i�inde L harfi olan ��rencileri getiren sql?
Select * from Ogrenciler WHERE Ad LIKE '%l%';

--SORU6 - Ad�n�n i�inde A , soyad�n�n i�inde E harfi olanlar?
Select * from Ogrenciler WHERE Ad LIKE '%A%' AND Soyadi LIKE '%E%';

--sORU7 - Ad�nda A olan Soyad� EZ ile biten?
Select * from Ogrenciler WHERE Ad LIKE '%A%' AND Soyadi LIKE '%EZ%';

--SORU7 - Ad�n�n Ba�harfi A olmayan verileri getiren sql?
Select * from Ogrenciler WHERE Ad NOT LIKE 'A%';

--SORU9 - Ad�n�n ilk 2 harfi AY olan VE 5.Harfi G olan verileri getiren sql? _ Tek bir karakter 
Select * from Ogrenciler WHERE Ad LIKE 'AY__G%';

--SORU10 - �lk 2 harfi AY olan VE �SM�N�N 4.HARF� E olan veya Soyad�nda Z harfi olan aql?
Select * from Ogrenciler WHERE Ad LIKE 'AY_E%' OR Soyadi LIKE '%Z%';

--SORU11 - Cinsiyeti Erkek olan kay�tlar� getiren sql?
Select * from Ogrenciler WHERE Cinsiyeti = 'E';
Select * from Ogrenciler WHERE Cinsiyeti LIKE 'E';

--SORU12 - Cinsiyeti Erkek olmayanlar?
Select * from Ogrenciler WHERE Cinsiyeti != 'E';
Select * from Ogrenciler WHERE NOT Cinsiyeti = 'E';

--SORU1: Dersler tablosundan t�r� Z olan VEYA Kredisi 3 ten b�y�k e�it olan dersleri getiren sql?
Select * from Dersler WHERE Turu='Z' OR Kredi >=3;

--SORU2: Dersler tablosundan t�r� Z olan VE Kredisi 3 ten k���k e�it olan dersleri getiren sql?
Select * from Dersler WHERE Turu='Z' AND Kredi <=3;

--sSORU: Dersler tablosundan t�r� Z olan veya kredisi 3 ten b�y�k e�it olan, ID de�eri 2-6 aras�nda olan dersleri getiren sql? (VE/VEYA yazm�yorsa VE olarak al�r�z)
Select * from Dersler WHERE (Turu='Z' OR Kredi >=3) AND (ID>=2 AND ID<=6);
--WHERE, ORDER BY(SIRALAMA) KULLANIMI

Select ID, Adi, Kodu, Turu From Dersler;

--SORU1: Dersler tablosundaki verileri adlar�na g�re artan s�ral� olarak getiren sql?
Select * from Dersler ORDER BY Adi asc;
Select * from Dersler ORDER BY Adi;

--SORU2: Adlar�na g�re azalan �ekilde g�re s�ralayan sql?
Select * from Dersler ORDER BY Adi desc;

--SORU3: Derslerin kredilerine g�re artan �ekilde s�ralayan sql?
Select * from Dersler ORDER BY Kredi;

--SORU4: Derslerin kredilerine g�re artan, AKTS de�erine g�re azalan �ekilde s�ralayan sql?
Select * from Dersler ORDER BY Kredi, AKTS desc;

--SORU5: Zorunlu dersleri kredilerine g�re artan, AKTS de�erine g�re azalan �ekilde s�ralayan sql?
Select * from Dersler WHERE Turu= 'Z' ORDER BY Kredi, AKTS desc;

--SORU6: Kredisi 4 ve daha fazla olan zorunlu dersleri kredilerine g�re artan, AKTS de�erine g�re azalan �ekilde s�ralayan sql?
Select * from Dersler WHERE Turu= 'Z' AND Kredi>=4 ORDER BY Kredi, AKTS desc;

--TAKMA AD (ALTAS)
Select ID as OGR_ID, OgrenciNo, Tcno [TC Kimlik No], Ad ADI from Ogrenciler;

Select Ogrenciler.ID, Ogrenciler.OgrenciNo from Ogrenciler;

Select o.ID, Ogr_ID, o.OgrenciNo from Ogrenciler as o;
--ALTER TABLE --TABLO ADI DE���T�RME, S�TUN EKLEME, �IKARMA

--sORU1: Uyeler tablosunun ad�n� Users olarak de�i�tiren sql?
ALTER TABLE Uyeler RENAME TO Users;

--SORU2: Users tablosundaki cinsiyet ad�n� Cinsiyeti olarak de�i�tiren sql?
ALTER TABLE Users RENAME COLUMN Cinsiyet TO Cinsiyeti;

--SORU3: Users tablosuna country, city alanlar�n� ekleyen sql?
ALTER TABLE Users ADD COLUMN Country VARCHAR(30) NOT NULL DEFAULT('T�rkiye');
ALTER TABLE Users ADD COLUMN City VARCHAR(30);

--SORU4: Users tablosundan City alan�n� silen sql?
ALTER TABLE Users DROP COLUMN City;

--SORU5: Users tablosuna Kay�t Tarihi ad�nda o an ki tarih ve zaman bilgisini Default olarak ekleyen sql?
ALTER TABLE Users ADD COLUMN KayitTarihi DateTime NOT NULL DEFAULT( datetime('now', 'localtime') );
--DDL(Data Defination Language)
--CREATE(Nesne olu�turur), DROP(Nesneyi Siler)

--SORU1: ��erisinde ID, UserName, Password, email, Cinsiyet, DogumTarihi alanlar�n� bar�nd�ran �yeler ismindeki tabloyu gerekli k�s�tlamalar�da g�z �n�ne al�narak olu�turan sql?

--CREATE TABLE if not exists Uyeler (zaten var de�ilse)

CREATE TABLE Uyeler(

ID INTEGER CONSTRAINT Pk_Uyeler_Id Primary Key Autoincrement NOT NULL, 

Username VARCHAR(30) CONSTRAINT UQ_Uyeler_Username UNIQUE NOT NULL CHECK(length(Username) >=3 ),

Password VARCHAR(30) NOT NULL,

Email VARCHAR(50) CONSTRAINT UQ_Uyeler_Emaile UNIQUE NOT NULL,

Cinsiyet VARCHAR(1)  NOT NULL DEFAULT('E') CHECK (Cinsiyet IN ('E', 'K') ),

DogumTarihi DATE
);


--DROP TABLE Uyeler;

--DROP TABLE if exists Uyeler; --E�er varsa silsin.

--SORU1: �grenciDersler tablosuna tablolar aras� ili�kileri g�zeterek en az 2 kay�t ekleyen tek bir sql?
INSERT INTO OgrenciDersler (OgrenciNo, DersKodu, Vize) vALUES ('O3', 'BLG106', 80); 

INSERT INTO OgrenciDersler (OgrenciNo, DersKodu, Vize) 
vALUES
('O3', 'BLG106', 80),
('O4', 'BLG106', 70);

--SORU2: Dersler tablosundaki verileri AKTS Kredilerine g�re azalan �ekilde s�ralayan ve i�erisinde A harfi bulunan dersleri getiren sql?
Select * from Dersler WHERE Adi LIKE '%A%' ORDER BY AKTS desc;

--SORU3: Ogrenciler tablosundan isimleri benzersiz olarak getiren sql? --DISTINCT benzersizlik sa�l�yor.
Select Ad, COUNT(*) Sayi from Ogrenciler GROUP BY Ad;
Select DISTINCT Ad from Ogrenciler;

--SORU4: T�r�ne g�re ders say�s�n� getiren sql?
Select Turu, COUNT(*) as Sayi from Dersler GROUP BY Turu;

--SORU5: Dersler tablosundan ID Kodu, Adi, Kredi, AKTS bilgileriyle birlikte AKTS'nin 2 kat� ve Kredi'nin 3 kat�n� hesaplayan sql?
Select ID, Kodu, Adi, Kredi, Akts, (Kredi*2) Kredi2Kat, (Akts*3) as Akts3Kat from Dersler;
--DROP, CREATE, if Exists, if Not Exists

DROP TABLE Bolumler; 

DROP TABLE if Exists Bolumler;

--SORU1: ID, Kodu ve Adi alanlar�n� bar�nd�ran B�l�mler Tablosunu olu�turan sql?
CREATE TABLE Bolumler ( 
ID INTEGER CONSTRAINT PK_Bolumler_ID PRIMARY KEY Autoincrement,
Kodu VARCHAR(5) CONSTRAINT UQ_Bolumler_Kodu UNIQUE NOT NULL,
Adi VARCHAR(40) NOT NULL COLLATE NOCASE);

--SORU2: Bolumler tablosuna en az 3 kay�t ekleyen sql?
INSERT INTO Bolumler (Kodu, Adi) 
VALUES('B1', 'Bilgisayar'), 
      ('B2', 'Bili�im'),
      ('B3', 'U�ak'),
      ('B4', 'Kontrol Otomasyon');
--ALT SORGU(SUB QUERY): Ana(Main) Select'in i�inde Select olmas�.

--SORU1: En B�y�k Kredi de�erinw sahip olan dersi getiren sql?
Select MAX(Kredi) from Dersler;

Select * From Dersler WHERE Kredi = (Select MAX(Kredi) from Dersler); --Di�er bilgileri de getiriyor(Alt Sorfu)

--SORU2: ��renciDerler tablosundaki verileri ders adlar� ile birlikte getiren sql?
Select od.ID, od.OgrenciNo, od.DersKodu, (Select d.Adi from Dersler d WHERE d.Kodu = od.DersKodu) DersAdi from OgrenciDersler od; 

--Kodu BLG103 olan dersin ad� nedir? Select d.Adi From Dersler d WHERE d.Kodu = 'BLG103';

--SORU3: OgrenciDersler tablosundaki verileri ��renci ad� ile getiren sql?
Select od.ID, od.OgrenciNo, (Select o.Ad from Ogrenciler o WHERE o.OgrenciNo=od.OgrenciNo) OgrAdi, od.DersKodu from OgrenciDersler od;

--SORU4: OgrenciDersler tablosundaki verileri soyad� ile getiren sql?
Select od.ID, od.OgrenciNo, (Select o.Soyadi from Ogrenciler o WHERE o.OgrenciNo=od.OgrenciNo) OgrSoyadi, od.DersKodu from OgrenciDersler od;

--SORU5: ��rencinin Ad-Soyad�n� bir s�tunda getiren sql?
Select o.*, (o.Ad || ' ' || o.Soyadi) AdiSoyadi from Ogrenciler o; --MET�N B�RLE�T�RME

Select od.ID, od.OgrenciNo, (Select o.Ad || ' ' || o.Soyadi from Ogrenciler o WHERE o.OgrenciNo=od.OgrenciNo) OgrAdi_Soyadi, od.DersKodu from OgrenciDersler od;
--ALT SORGU DEVAM
--SORU1: Bilgisayar b�l�m�nde okuyan ��rencileri getiren sql?
Select b.Kodu from Bolumler b WHERE b.Adi = 'Bilgisayar';
Select o.* from Ogrenciler o WHERE BKodu = (Select b.Kodu from Bolumler b WHERE b.Adi = 'Bilgisayar');

--SORU2: B�l�m� B ile ba�layan ��rencileri getiren sql?
Select o.* from Ogrenciler o WHERE BKodu = 'B1' OR BKodu = 'B2';
Select o.* from Ogrenciler o WHERE BKodu IN ('B1', 'B2');

Select o.* from Ogrenciler o WHERE BKodu IN(Select b.Kodu from Bolumler b WHERE b.Adi LIKE 'B%');

--SORU3: B�l�m Ad� B ile Ba�lamayan ��rencileri getiren sql?
Select o.* from Ogrenciler o WHERE BKodu IN(Select b.Kodu from Bolumler b WHERE b.Adi NOT LIKE 'B%');
Select o.* from Ogrenciler o WHERE BKodu NOT IN(Select b.Kodu from Bolumler b WHERE b.Adi LIKE 'B%');

--SORU4: B�l�m Adi ile birlikte ��renci bilgilerini getiren sql?
Select o.*, (Select b.Adi from Bolumler b WHERE b.Kodu = o.BKodu) BolumAdi from Ogrenciler o;
--LIMIT  (SQL Server'da ise TOP kullan�l�yor)

--SORU1: ��renciler tablosundan �LK 3 ki�iyi geetiren sql?
Select * from Ogrenciler Order by Ad LIMIT 3;
--SORU1: ��renciler tablosunun YEDE��N� al�n�z. Yedekte VARCHAR veri tipi TEXT olur.

CREATE TABLE OgrencilerYedek as 
Select o.*, (Select b.Adi from Bolumler b WHERE b.Kodu=o.BKodu) BolumAdi from Ogrenciler o;

--SORU2: Ayn� dersi birden fazla alan ��renci ve ders bilgilerini getiren sql?
Select OgrenciNO, DersKodu, COUNT(*) Adet from OgrenciDersler GROUP BY OgrenciNO, DersKodu HAVING Adet>1;

Select ID from OgrenciDersler od WHERE od.OgrenciNO = 'O3' AND od.DersKodu = 'BLG106' ORDER BY ID Desc LIMIT 1;

DELETE from OgrenciDersler
WHERE ID IN (Select ID from OgrenciDersler od WHERE od.OgrenciNO = 'O3' AND od.DersKodu = 'BLG106' ORDER BY ID Desc LIMIT 1);
Select * from Ogrenciler WHERE Trim(Ad) = 'Ali'; --Ba��nda bo��luk olan Ali ismini getirmedi.

UPDATE Ogrenciler set Ad = Trim(Ad) WHERE length(Ad) != length(Trim(Ad)); --Ba��nda bo�luk olanlar� d�zeltti, g�ncelledi.

Select o.Ad, INSTR(o.Ad, 'AL�') from Ogrenciler o;
--String Fonksiyonlar�

--Length
Select o.Ad, length (o.Ad) as Ad_Uzunluk, o.Soyadi, length(o.Soyadi) Soyad_Uzunluk from Ogrenciler o;

Select 'Deniz' as Name, length('Deniz') Name_Uzunluk;

--LTrim, RTrim, Trim
Select '  Deniz  ' as Name, length('  Deniz  ') Name_Uzunluk,
ltrim('  Deniz  ') as ltrimName, length(ltrim('  Deniz  ')) ltrim_uzunluk,
rtrim('  Deniz  ') as rtrimName, length(rtrim('  Deniz  ')) rtrim_uzunluk,
trim('  Deniz  ') as trimName, length(trim('  Deniz  ')) trim_uzunluk;

--lOWER(Metni B�y�t�r) - UPPER(Metni K���lt�r)
Select o.Ad, UPPER(o.Ad) Upper_Adi, o.Soyadi, Lower(o.Soyadi) Lower_Soyadi from Ogrenciler o;

--INSTR: Bir string i�inde ba�ka string var nm� yok mu g�rmemizi sa�lar, varsa ba�lang�� noktas�ndaki index numaras�n� al�r.
Select INSTR('Merhaba D�nya', 'a') Sonuc; --5
Select INSTR('Merhaba D�nya', 'M') Sonuc; --1
Select INSTR('Merhaba D�nya', 'MER') Sonuc; --1
Select INSTR('Merhaba D�nya', 'Z') Sonuc; --0

--SUBSTR: 
--Ba�a en az 2 parametre al�r
Select SUBSTR('Merhaba D�nya', 4) Sonuc;
Select SUBSTR('Merhaba D�nya', 4, 2) Sonuc;

--REPLACE: Bir string i�inde ba�ka string ar�yor varsa de�i�tiriyor
Select REPLACE('Merhaba D�nya', 'a' , 'e') Sonuc;
Select REPLACE('Merhaba D�nya', 'D�nya' , 'Ahali') Sonuc;
--String Fonksiyonlar�

--Length
Select o.Ad, length (o.Ad) as Ad_Uzunluk, o.Soyadi, length(o.Soyadi) Soyad_Uzunluk from Ogrenciler o;

Select 'Deniz' as Name, length('Deniz') Name_Uzunluk;

--LTrim, RTrim, Trim
Select '  Deniz  ' as Name, length('  Deniz  ') Name_Uzunluk,
ltrim('  Deniz  ') as ltrimName, length(ltrim('  Deniz  ')) ltrim_uzunluk,
rtrim('  Deniz  ') as rtrimName, length(rtrim('  Deniz  ')) rtrim_uzunluk,
trim('  Deniz  ') as trimName, length(trim('  Deniz  ')) trim_uzunluk;

--lOWER(Metni B�y�t�r) - UPPER(Metni K���lt�r)
Select o.Ad, UPPER(o.Ad) Upper_Adi, o.Soyadi, Lower(o.Soyadi) Lower_Soyadi from Ogrenciler o;

--INSTR: Bir string i�inde ba�ka string var nm� yok mu g�rmemizi sa�lar, varsa ba�lang�� noktas�ndaki index numaras�n� al�r.
Select INSTR('Merhaba D�nya', 'a') Sonuc; --5
Select INSTR('Merhaba D�nya', 'M') Sonuc; --1
Select INSTR('Merhaba D�nya', 'MER') Sonuc; --1
Select INSTR('Merhaba D�nya', 'Z') Sonuc; --0

--SUBSTR: 
--Ba�a en az 2 parametre al�r
Select SUBSTR('Merhaba D�nya', 4) Sonuc;
Select SUBSTR('Merhaba D�nya', 4, 2) Sonuc;

--REPLACE: Bir string i�inde ba�ka string ar�yor varsa de�i�tiriyor
Select REPLACE('Merhaba D�nya', 'a' , 'e') Sonuc;
Select REPLACE('Merhaba D�nya', 'D�nya' , 'Ahali') Sonuc;
--SORU: ��renciler tablsu ile ��rencilerYedek tablosunun verilerini birle�tirerek getiren sql? 
--Birle�tirmesi i�in UNION'da s�tun say�lar� e�it, veri tipleri ayn� olmal�.
--UNION ALL b�t�n kay�tlar� getiriyor, UNION Benzersizlik kayd�n� g�z �n�ne al�yor.

Select * from Ogrenciler
UNION ALL
Select * from OgrencilerYedek; 

Select * from Ogrenciler
UNION 
Select * from OgrencilerYedek; 

Select ID, TCNO from Ogrenciler
UNION
Select ID, TCNO from OgrencilerYedek;

--CASE WHEN KULLANIMI (if else switch gibi bir �ey)

--SORU1: ��renci bilgilerini getiren ve cinsiyeti E ise +500 ek maa� hesaplayan, cinsiyeti K ise +600 ek maa�, di�erleri i�in +450 ek maa� hesaplayan sql?
Select o.*, 
CASE Cinsiyeti
    When 'E' Then 500
    When 'K' Then 600
    Else 450
END EkMaas

from Ogrenciler o;

/*SORU2:
Cinsiyeti E ve B�l�m� Bilgisayar olanlara 500, 
Cibnsiyeti E ve B�l�m� Bili�im olanlara 575, 
Cinsiyeti E ve B�l�m� U�ak olanlara 550,
Cinsiyeti K olanlara 600, 
di�erlerine 450 ek maas hesaplayan sql? */

Select O.*,

CASE
  When o.Cinsiyeti = 'E' AND o.BKodu = 'B1' Then 500
  When o.Cinsiyeti = 'E' AND o.BKodu = 'B2' Then 575
  When o.Cinsiyeti = 'E' AND o.BKodu = 'B3' Then 550
  When o.Cinsiyeti = 'K' Then 600
  Else 450
END EkMaas

from Ogrenciler o;

--SORU3: Soruya ilave olarak B�l�m Adlar�n� kullanarak e�le�tirmeyi sa�layan sql? (alt sorgu)


Select O.*,

CASE
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bilgisayar') Then 500
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bili�im') Then 575
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'U�ak') Then 550
  When o.Cinsiyeti = 'K' Then 600
  Else 450
END EkMaas,

(Select Adi from Bolumler WHERE Kodu = o.BKodu) BlmAdi

from Ogrenciler o;

--2.YOL JO�N �LE

Select O.*,
CASE
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bilgisayar') Then 500
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bili�im') Then 575
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'U�ak') Then 550
  When o.Cinsiyeti = 'K' Then 600
  Else 450
END EkMaas,

b.Kodu BlmKodu, b.Adi BlmAdi

from Ogrenciler o LEFT JOIN Bolumler b ON o.BKodu = b.Kodu; --lEFT soldaki tabloya ait b�t�n sat�rlar� getiriyor. Soldakiyle e�le�enleri yaz�yor e�le�meyenlere Null diyor)
CREATE VIEW OgrenciBilgileri AS

Select O.*,
CASE
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bilgisayar') Then 500
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'Bili�im') Then 575
  When o.Cinsiyeti = 'E' AND o.BKodu = (Select Kodu from bolumler WHERE Adi = 'U�ak') Then 550
  When o.Cinsiyeti = 'K' Then 600
  Else 450
END EkMaas,

b.Kodu BlmKodu, b.Adi BlmAdi

from Ogrenciler o LEFT JOIN Bolumler b ON o.BKodu = b.Kodu;

--VIEW kullan�m� tablo olu�turmas� d���nda tablo gibi de kullan�labilir. Birden fazla view kullanabiliriz.
--SORU1: ��inde ��rencisi olan b�l�mleri getiren sql? 
--1.Yol IN kullanarak

Select b.* from Bolumler b WHERE b.Kodu IN ('B1' , 'B2' , 'B3' , 'B4');

Select b.* from Bolumler b WHERE b.Kodu IN(Select o.BKodu from Ogrenciler o WHERE o.BKodu is not null GROUP BY o.BKodu);

--2.Yol EXISTS kullanarak (exists daha h�zl� �al���yor)
Select b.* from Bolumler b WHERE EXISTS(Select o.ID from Ogrenciler o WHERE o.BKodu = b.Kodu)

--SORU2: ��inde ��renci olmayan b�l�mleri getiren sql?

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

Select datetime() as BugunSimdi, datetime('now' , 'Localtime') as BugunSimdiYerel; --localtime now ile birlikte kullan�l�r.

Select date('2014-10-16' , 'start of month' ), date('now') ,  date('now','start of month' );

Select date ('now'), date('now' , '+5 years'), date('now' , '+5 month');

SELECT date('2014-10-16', 'start of month','+1 month', '-1 day');

Select date('now' , 'weekday 2'); --Bir sonraki haftan�n Sal� g�n�

Select strftime('%d.%m.%Y' , '2018-05-22') , strftime( '%d.%m.%Y' , 'now');
Select strftime('%Y' , '2018-05-22');

--��rencilerin ya� ortalamnas�n� bulan ve getiren sql?
Select o.* from Ogrenciler o WHERE o.Dtarihi is not null;

Select o.*, (strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as YAS from Ogrenciler o;

Select AVG(strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as ORTALAMA from Ogrenciler o WHERE o.Dtarihi is not null;



CREATE TABLE MyData AS
Select o.*, (strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as YAS from Ogrenciler o;

CREATE VIEW MyView AS
Select o.*, (strftime('%Y' , 'now') - strftime('%Y' , o.DTarihi)) as YAS from Ogrenciler o;

Select AVG(YAS) from MyData Where DTarihi is not null;
-- SQLite System Tables

Select * from sqlite_sequence; --ID'de kullan�lan en son de�eri g�steriyor.

Select * from sqlite_master; --�rne�in veri taban�m�zda Elmalar isminde bir tablo var m� yok mu? Detayl� �ekilde g�rmemizi sa�lar.

--Elmalar isminde tablo var m� yok mu?
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

-- Ogrencidersler tablosunda ayn� dersi 1 den fazla alan �grenci ve ders bilgilerini getiren sql?
Select DersKodu, OgrenciNo, COUNT(*) as Sayi from OgrenciDersler GROUP BY DersKodu, OgrenciNo HAVING COUNT(*) > 1;
--SORU1: Toplam ��renci Say�s�n� getiren sql?
Select COUNT(*) as OgrSayisi from "Ogrenciler";

--SORU2: Cinsiyetine g�re ��renci say�s�n� getiren sql?
Select "Cinsiyeti", COUNT(*) as Sayi from "Ogrenciler" GROUP BY "Cinsiyeti";

--SORU3: B�l�mlerine g�re ��renci say�s�n� getiren sql?
Select "BKodu" , COUNT(*) as OgrSayisi from "Ogrenciler" GROUP BY "BKodu";

--SORU4: B�l�m ve Cinsiyetlerine g�re ��renci say�s�n� getiren sql?
Select "BKodu", "Cinsiyeti", COUNT(*) as OgrSayi from "Ogrenciler" GROUP BY "BKodu", "Cinsiyeti";

--SORU5: B�l�m, Cinsiyet, S�n�f'lar�na g�re ��renci say�s�n� getiren sql?
Select "BKodu", "Cinsiyeti", "Sinifi", COUNT(*) as OgrSayi from "Ogrenciler" GROUP BY "BKodu", "Cinsiyeti", "Sinifi";

--SORU6: ��erisinde 1 den fazla ��rencisi olan b�l�mleri getiren sql?
Select "BKodu", COUNT(*) as OgrSayisi from "Ogrenciler" GROUP BY "BKodu" HAVING COUNT(*)>1;

--SORU7: ��rencilerin t�m bilgilerini B�l�m Adlari ile birlikte getiren sql? 
--(1- JOIN kullarak) 
Select O.*, b."Adi" BolumAdi FROM "Ogrenciler" o INNER JOIN "Bolumler" b on b."Kodu" = o."BKodu";
Select O.*, b."Adi" BolumAdi FROM "Ogrenciler" o LEFT JOIN "Bolumler" b on b."Kodu" = o."BKodu";

--(2- SubQuery (Alt Sorgu) kullanarak)
Select o.*, (Select b."Adi" From "Bolumler" b WHERE b."Kodu"= o."BKodu") BolumAdi from "Ogrenciler" o;

--SORU8:
--Drop Table if Exists "Ogrenciler" --E�er varsa ��renciler tablosunu sil
--Drop Table if exists "Bolumler "

--int2:small insteger, int4:integer, int8:long integer.
--serial: integer gibi �al���r otomatik alanlar i�in kullanabiliriz
--Yedekten veri alaca��m�z i�in primary key'den sonra autoincrement ve null yazmad�k.

/*
Create Table Bolumler(
   Id integer CONSTRAINT PK_Bolumler_Id PRIMARY KEY, 
   Kodu CHARACTER VARYING(5) CONSTRAINT UQ_Bolumler_Kodu UNIQUE NOT NULL,
   Adi CHARACTER VARYING(30) NOT NULL
);
*/

--�imdi Yedekteki verileri geri getirece�iz.
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


--CASCADE: �ki tablo aras�nda ili�ki kurdu�umuz zaman tekinde de�i�ikli�e u�rad��� zaman di�erinde de de�i�tirir. Buna izin verir. Otomatik g�nceller.
--Birden fazla s�tunu bar�nd�ran unique yazd�k.

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

Insert Into "Bolumler" ("Kodu","Adi") Values ('B3', 'Kontrol Otomasyon') , ('B4' , '��letme');
                    
					
Select * from public."Bolumler"
--D�NG�LER
--Continue: Tekrar ba�a d�n�p devam ediyor
--0 ile 50 aras�ndaki say�lardan 5'e tam b�l�nmeyen say�lar�n toplam�n� bulan, say�lar�n toplamlar� 400 ve daha b�y�k olunca durduran sql?

do $$
DECLARE sayac INTEGER :=1;
DECLARE toplam INTEGER :=0;
BEGIN
While sayac <= 50 loop

	   if mod(sayac, 5)=0 then
	   sayac := sayac + 1;
	   continue;
	   end if;
	   
	   raise notice '�slem Yap�lan Say�: %', sayac;
	   toplam:= toplam + sayac;
	   if (toplam >=400) then
	   Exit;
	   end if;
	   
	   sayac := sayac + 1;
	   
  End loop; 
  
       raise notice 'Toplam : %', toplam;
   
END $$;
--D�NG�LER 
--Exit

do $$
DECLARE sayac INTEGER := 0;
DECLARE toplam INTEGER := 0;
BEGIN
--0 ile Saya� aras�ndaki say�lardan 100 de�erine ula��ncaya kadar toplama i�lemini yapan program;
While sayac <= 40 loop
     raise notice 'Ad�m: %' , sayac;
	 sayac := sayac + 1;
	 toplam := toplam + sayac;
	 if toplam >= 100 then
	 Exit; --Java da ise break kullan�yorduk
	 end if;
     end loop;
	 raise notice 'Toplam: %' , toplam; --D�ng�den ��kt�ktan sonra toplam� yazd�r�yoruz
	 
End $$;
--D�NG�LER
--RECORD VER� T�P�
--��renciler tablosundan OgrNo, Adi, Soyadi bilgilerini mesaj olarak Konsola yazd�ran sql?

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

--D�NG�LER
--ilk �nce arka planda de�i�ken tan�mlamas� yapaca��z.

--WHILE D�NG�S�
/*do $$
DECLARE sayac integer := 5;
BEGIN --Kodlar� i�ine yazaca��z
while sayac > 0 loop --Ko�ullar� belirtelim, posgrede  loop var(otomatik olarak alt�nda begin bar�nd�r�yor o y�zden loop, end loop yap�yoruz)
  raise notice 'Saya�: %' , sayac; --raise notice ekrana yazd�r�yor
  sayac := sayac - 1;
  end loop;
END$$;
*/

do $$
DECLARE toplam integer := 0;
BEGIN
  raise notice 'For D�ng�s� �rne�i';
  for i in 1..10 loop --Bu sefer sayac yerine i tan�mlad�k. Otomatik de�i�ken olarak integer olarak tan�mlad�. --in reverse ise tersten say�yor -- in 1..6 by 2 (by 2 �er artt�r demek)
    raise notice'For saya�: %' , i;
  end loop;
  
  raise notice'Tersten For D�ng�s�';
  for n in reverse 10..5 loop
    raise notice 'n : %' , n;
  end loop;
 
 raise notice 'Step By Step For';
 for  x in 0..10 by 2 loop --0 ile 10 aras�ndaki �ift say�lar�n toplam� (0 ve 10'u da dahil ediyor)
    toplam:= toplam + x;
 end loop;
 raise notice 'Toplam:= %' , toplam;
  
END$$;
Select * from bolumler; 

INSERT INTO bolumler (kodu,adi) VALUES('b6', 'bolum-6'); --Bolumler sa� t�kla properties, columns, Id'yi start k�sm�n� 4 yapt�m �d ordan devam etsin diye.

Select * from ogrenciler Order by Id desc; --burada da start� 8 yapt�m

INSERT INTO ogrenciler(ogrencino, tcno, adi, soyadi, cinsiyeti, bkodu, sinifi)
VALUES('O8', '222', '�zge', 'G�lsoy', 'K', null, 2);

--select * into BolumlerYedek from "Bolumler ";

--select * into OgrencilerYedek from "Ogrenciler";

--Truncate table "Bolumler "; --Bolumler tablosu ba�ka tabloyla ili�kilendirildi�i i�in bunu yapamazs�n diye hata veriyor.

--Delete from "Bolumler "; --DELETE ile sildi�imiz zaman eski veriler arka planda tutuluyor.

--Truncate table "Ogrenciler"; --�nce ��rencileri truncate ettik sonra delete bolumler yapt�k.. ��rencilerin verileri truncate ile yok oldu.

--TRUNCATE ile sildi�imiz zaman haarddiskten de siliniyor.

TRUNCATE TABLE "Ogrenciler" RESTART IDENTITY; --T�m ID'leri resetledi.

Select * from "Ogrenciler";
Select * from "Bolumler ";

--Insert Into "Bolumler " ("Kodu", "Adi") Values('b1', 'b�l�m1');

--Insert Into "Bolumler " ("Kodu", "Adi") Values('b2', 'b�l�m2');

--Insert Into "Bolumler " ("Kodu", "Adi") Values('b3', 'b�l�m3');

Insert Into "Ogrenciler" ("OgrenciNo", "TCNo","Adi","Soyadi","BKodu", "Sinifi") 
Values('O2', '123', 'Ertu�rul', 'DUMAN', 'b1', 'E', 1);

--TRUNCATE TABLE "Bolumler " RESTART IDENTITY;
--TRUNCATE TABLE "Ogrenciler" RESTART IDENTITY;

--Delete from "Bolumler ";

--Yedekten verileri geri alaca��z. Otomatik artan var m� yok mu diye kontrol edece�iz �nce. Varsa iptal edece�iz.

Select * from "Bolumler ";

--Insert Into "Bolumler " ("Adi" , "Kodu", "Id") Select "Adi", "Kodu", "Id" from bolumleryedek
				  
--Insert Into "Bolumler " ("Kodu", "Adi") VALUES ('B8', 'B�l�m8')
				  
Insert Into "Bolumler " ("Adi" , "Kodu") Select "Adi", "Kodu" from bolumleryedek


