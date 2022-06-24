/*
Created: 22. 3. 2021
Modified: 18. 5. 2021
Model: Oracle 19c
Database: Oracle 19c
*/


-- Create tables section -------------------------------------------------

-- Table dodavatel

CREATE TABLE dodavatel(
  ICO Char(8 ) NOT NULL,
  nazov Varchar2(30 ) NOT NULL,
  krajina Varchar2(25 ) NOT NULL,
  ulica Varchar2(30 ),
  obec Varchar2(50 ) NOT NULL,
  psc Char(5 ),
  tel Varchar2(20 ) NOT NULL,
  email Varchar2(30 )
)
/

-- Add keys for table dodavatel

ALTER TABLE dodavatel ADD CONSTRAINT PK_dodavatel PRIMARY KEY (ICO)
/

-- Table and Columns comments section

COMMENT ON COLUMN dodavatel.tel IS 'Telefonné číslo medzinárodného formátu'
/

-- Table dodavka

CREATE TABLE dodavka(
  id_dodavky Integer NOT NULL,
  ICO Char(8 ) NOT NULL,
  nazov_centra Varchar2(50 ) NOT NULL,
  typ_vakciny Char(2 ) NOT NULL
        CHECK (typ_vakciny in ('Pf', 'AZ', 'Mo', 'Cu', 'Sa', 'Jo', 'No', 'Sp', 'CV', 'Co')),
  datum_dodavky Date NOT NULL,
  pocet_kusov Integer NOT NULL,
  pocet_davok Integer NOT NULL,
  datum_spotreby Date NOT NULL,
  datum_vyroby Date,
  SK_norma Char(1 ) NOT NULL
        CHECK (SK_norma in ('A','N')
)
)
/

-- Create indexes for table dodavka

CREATE INDEX IX_Relationship11 ON dodavka (nazov_centra)
/

CREATE INDEX IX_Relationship8 ON dodavka (ICO)
/

-- Add keys for table dodavka

ALTER TABLE dodavka ADD CONSTRAINT PK_dodavka PRIMARY KEY (id_dodavky)
/

-- Table and Columns comments section

COMMENT ON COLUMN dodavka.pocet_kusov IS 'Počet kusov ampuliek/vakcíny'
/
COMMENT ON COLUMN dodavka.pocet_davok IS 'Počet dávok, jedna ampulka môže mať napríklad dve dávky'
/
COMMENT ON COLUMN dodavka.SK_norma IS 'Spĺňa požiadavky na očkovanie v SK ? áno/nie'
/

-- Table ockovacie_centrum

CREATE TABLE ockovacie_centrum(
  nazov_centra Varchar2(50 ) NOT NULL,
  od Date NOT NULL,
  do Date,
  ulica Varchar2(30 ),
  obec Varchar2(50 ) NOT NULL,
  psc Char(5 ),
  typ_zriadenia Char(2 )
        CHECK (typ_zriadenia in ('ST','SU'))
)
/

-- Add keys for table ockovacie_centrum

ALTER TABLE ockovacie_centrum ADD CONSTRAINT PK_ockovacie_centrum PRIMARY KEY (nazov_centra)
/

-- Table and Columns comments section

COMMENT ON COLUMN ockovacie_centrum.typ_zriadenia IS 'štátne/súkromné'
/

-- Table ockovaci_tim

CREATE TABLE ockovaci_tim(
  id_tim Char(4 ) NOT NULL,
  id_clen Integer NOT NULL,
  nazov_centra Varchar2(50 ) NOT NULL,
  rod_cislo Char(11 ) NOT NULL,
  datum_prac_zmeny Date NOT NULL,
  typ_ulohy Char(1 ) NOT NULL
        CHECK (typ_ulohy in ('Z', 'O', 'D'))
)
/

-- Create indexes for table ockovaci_tim

CREATE INDEX IX_Relationship1 ON ockovaci_tim (rod_cislo)
/

-- Add keys for table ockovaci_tim

ALTER TABLE ockovaci_tim ADD CONSTRAINT PK_ockovaci_tim PRIMARY KEY (id_tim,nazov_centra,id_clen)
/

-- Table and Columns comments section

COMMENT ON COLUMN ockovaci_tim.id_tim IS 'V tvare XXNN, kde XX je okres a NN je poradové číslo'
/
COMMENT ON COLUMN ockovaci_tim.typ_ulohy IS 'Úloha zapisovateľa, dozoru a očkujúceho'
/

-- Table ockovanie

CREATE TABLE ockovanie(
  id_ockovania Integer NOT NULL,
  nazov_centra Varchar2(50 ) NOT NULL,
  id_tim Char(4 ) NOT NULL,
  id_clen Integer NOT NULL,
  rod_cislo Char(11 ) NOT NULL,
  datum_ockovania Date NOT NULL,
  pracovna_pozicia Char(1 ) NOT NULL
        CHECK (pracovna_pozicia in ('S', 'D', 'Z', 'U', 'O', 'I'>),
  typ_vakciny Char(2 ) NOT NULL
        CHECK (typ_vakciny in ('Pf', 'AZ', 'Mo', 'Cu', 'Sa', 'Jo', 'No', 'Sp', 'CV', 'Co'))
)
/

-- Create indexes for table ockovanie

CREATE INDEX IX_Relationship9 ON ockovanie (rod_cislo)
/

CREATE INDEX IX_Relationship10 ON ockovanie (id_tim,nazov_centra,id_clen)
/

-- Add keys for table ockovanie

ALTER TABLE ockovanie ADD CONSTRAINT PK_ockovanie PRIMARY KEY (id_ockovania)
/

-- Table and Columns comments section

COMMENT ON COLUMN ockovanie.id_tim IS 'V tvare XXNN, kde XX je okres a NN je poradové číslo.'
/

-- Table osoba

CREATE TABLE osoba(
  rod_cislo Char(11 ) NOT NULL,
  meno Varchar2(15 ) NOT NULL,
  priezvisko Varchar2(40 ) NOT NULL,
  ulica Varchar2(30 ),
  psc Char(5 ) NOT NULL,
  obec Varchar2(50 ) NOT NULL,
  tel Varchar2(20 ) NOT NULL,
  email Varchar2(30 )
)
/

-- Add keys for table osoba

ALTER TABLE osoba ADD CONSTRAINT PK_osoba PRIMARY KEY (rod_cislo)
/

-- Table and Columns comments section

COMMENT ON COLUMN osoba.tel IS 'Telefonné číslo medzinárodného formátu'
/




-- Create foreign keys (relationships) section ------------------------------------------------- 

ALTER TABLE ockovaci_tim ADD CONSTRAINT Ma FOREIGN KEY (nazov_centra) REFERENCES ockovacie_centrum (nazov_centra)
/



ALTER TABLE dodavka ADD CONSTRAINT Donasa FOREIGN KEY (ICO) REFERENCES dodavatel (ICO)
/



ALTER TABLE ockovanie ADD CONSTRAINT Podstupila FOREIGN KEY (rod_cislo) REFERENCES osoba (rod_cislo)
/



ALTER TABLE ockovanie ADD CONSTRAINT Robi FOREIGN KEY (id_tim, nazov_centra, id_clen) REFERENCES ockovaci_tim (id_tim, nazov_centra, id_clen)
/



ALTER TABLE dodavka ADD CONSTRAINT Prijma FOREIGN KEY (nazov_centra) REFERENCES ockovacie_centrum (nazov_centra)
/



ALTER TABLE ockovaci_tim ADD CONSTRAINT Pracuje FOREIGN KEY (rod_cislo) REFERENCES osoba (rod_cislo)
/




