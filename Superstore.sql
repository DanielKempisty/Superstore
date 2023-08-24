USE Superstore;

--Zmiana typu danych kolumn z datami
ALTER TABLE 
  Superstore ALTER COLUMN Data_Zamówienia date;


ALTER TABLE 
  Superstore ALTER COLUMN Data_dostawy date;


--Zmiana typu danych kolumny z kodem pocztowym
ALTER TABLE 
  Superstore ALTER COLUMN Kod_pocztowy nvarchar(255);


--Dodanie usuniętych zer na początku kodu pocztowego 
UPDATE
	Superstore
SET Kod_pocztowy= CONCAT('0', Kod_pocztowy)
WHERE LEN(Kod_pocztowy) = 4;


--Zamienianie pustych kodów pocztowych na 0
UPDATE Superstore
SET [Kod_pocztowy] = '0' WHERE [Kod_pocztowy] IS NULL;


--Tworzenie nowych tabel
CREATE TABLE Stan (
    [StanID] int IDENTITY(1,1) PRIMARY KEY,
    [Stan] nvarchar(255) NOT NULL,
    [Region] nvarchar(255) NOT NULL,
);


CREATE TABLE Miasto (
    [MiastoID] int IDENTITY(1,1) PRIMARY KEY,
    [Miasto] nvarchar(255) NOT NULL,
	[Kod pocztowy] nvarchar(255),
    [StanID] int,
    FOREIGN KEY ([StanID]) REFERENCES Stan([StanID])
);


CREATE TABLE Klient(
	[KlientID] nvarchar(255) PRIMARY KEY NOT NULL,
	[Imie i nazwisko] nvarchar(255) NOT NULL,
	[Rodzaj klienta] nvarchar(255) NOT NULL,
);


CREATE TABLE Zamowienie(
	[ZamowienieID] nvarchar(255) PRIMARY KEY NOT NULL, 
	[Data zamowienia] date NOT NULL,
	[Data dostawy] date NOT NULL,
	[Rodzaj dostawy] nvarchar(255) NOT NULL,
	[KlientID] nvarchar(255),
	[MiastoID] int,
	FOREIGN KEY ([KlientID]) REFERENCES Klient([KlientID]),
	FOREIGN KEY ([MiastoID]) REFERENCES Miasto([MiastoID])
);


CREATE TABLE Kategoria(
	[KategoriaID] int IDENTITY(1,1) PRIMARY KEY, 
	[Kategoria] nvarchar(255) NOT NULL,
);


CREATE TABLE Podkategoria(
	[PodkategoriaID] int IDENTITY(1,1) PRIMARY KEY, 
	[Podkategoria] nvarchar(255) NOT NULL,
	[KategoriaID] int,
	FOREIGN KEY ([KategoriaID]) REFERENCES Kategoria([KategoriaID])
);


CREATE TABLE Produkt(
	[ProduktID] nvarchar(255) PRIMARY KEY NOT NULL, 
	[Nazwa Produktu] nvarchar(255) NOT NULL,
	[PodkategoriaID] int,
	FOREIGN KEY ([PodkategoriaID]) REFERENCES Podkategoria([PodkategoriaID])
);


CREATE TABLE [Szczegoly zamowienia](
	[ZamowienieID] nvarchar(255), 
	[ProduktID] nvarchar(255),
	[Cena] float NOT NULL,
	FOREIGN KEY ([ZamowienieID]) REFERENCES Zamowienie([ZamowienieID]),
	FOREIGN KEY ([ProduktID]) REFERENCES Produkt([ProduktID])
);


CREATE TABLE Kalendarz
(
    Data DATE
);


--Uzupełnianie utworzonych tabel
INSERT INTO Stan ([Stan], [Region]) 
SELECT 
  DISTINCT [Stan], 
  [Region] 
FROM 
  Superstore;


INSERT INTO Miasto([Miasto], [Kod pocztowy], [StanID]) 
SELECT 
  DISTINCT su.[Miasto], 
  su.[Kod_pocztowy], 
  st.[StanID] 
FROM 
  Superstore AS su 
  JOIN Stan AS st ON su.[Stan] = st.[Stan];


INSERT INTO Klient([KlientID], [Imie i nazwisko], [Rodzaj klienta]) 
SELECT 
	DISTINCT([Klient_ID]),
	[Imię_Nazwisko],
	[Rodzaj_klienta]
FROM
	Superstore;


INSERT INTO Zamowienie([ZamowienieID], [Data zamowienia], [Data dostawy], [Rodzaj dostawy], [KlientID], [MiastoID]) 
SELECT 
	DISTINCT(su.[Zamówienie_ID]),
	su.[Data_Zamówienia],
	su.[Data_dostawy],
	su.[Rodzaj_dostawy],
	su.[Klient_ID],
	m.[MiastoID]
FROM
	Superstore AS su
	LEFT JOIN Miasto AS m ON su.[Miasto] = m.[Miasto] AND su.[Kod_pocztowy] = m.[Kod pocztowy];


INSERT INTO Kategoria([Kategoria])
SELECT
	DISTINCT([Kategoria])
FROM Superstore;


INSERT INTO Podkategoria([Podkategoria], [KategoriaID])
SELECT
	DISTINCT(su.[Podkategoria]),
	k.[KategoriaID]
FROM Superstore AS su
JOIN Kategoria AS k ON su.[Kategoria] = k.[Kategoria];


INSERT INTO Produkt([ProduktID], [Nazwa produktu], [PodkategoriaID])
SELECT
	DISTINCT(su.[Produkt_ID]),
	su.[Nazwa_produktu],
	pk.[PodkategoriaID]
FROM Superstore as su
JOIN Podkategoria AS pk ON pk.[Podkategoria] = su.[Podkategoria];


INSERT INTO [Szczegoly zamowienia]([ZamowienieID], [ProduktID], [Cena])
SELECT
	su.[Zamówienie_ID],
	su.[Produkt_ID],
	su.[Cena]
FROM Superstore as su;


INSERT INTO Kalendarz(Data)
	SELECT 
	CONVERT(DATE, DATEADD(DAY, Number, '2015-01-03'), 23) AS Data
FROM master.dbo.spt_values
WHERE Type = 'P'
    AND DATEADD(DAY, Number, '2015-01-03') <= '2019-01-05';