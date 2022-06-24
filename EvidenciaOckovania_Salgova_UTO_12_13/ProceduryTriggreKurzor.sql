-------------------Vratenie nazov a krajinu dodavatela na zaklade ICO
create or replace procedure get_nazov_krajinu_Dodavatela
(p_ICO char, vysledok out varchar) -- je jedno ci pouzijem varchar alebo char
is
begin
    select nazov || ': ' || krajina
        into vysledok
        from dodavatel
        where ICO = p_ICO;
    exception when no_data_found then vysledok := 'xxxx';
end;
/

declare
vysledok Varchar(40);
cursor dodavatel is (select ICO from dodavatel);
begin
for i in dodavatel
loop
get_nazov_krajinu_Dodavatela(i.ICO, vysledok);
dbms_output.put_line(vysledok);
end loop;
end;
/

-------------------Vratenie mena a priezviska
CREATE OR REPLACE PROCEDURE p_meno_priezvisko
(p_rod_cislo char, menoOsoba OUT varchar) 
	IS
BEGIN
    SELECT meno || ' ' || priezvisko
        INTO menoOsoba
        	FROM osoba
        		WHERE rod_cislo = p_rod_cislo;
    EXCEPTION WHEN no_data_found THEN menoOsoba := 'Osoba sa nenašla';
END;
/

VARIABLE vysledok_osoba char(40); 
EXEC p_meno_priezvisko('990108/0000', :vysledok_osoba);
PRINT vysledok_osoba;

-------------------Kontrola zmeny
alter table osoba add zmenu_vykonal varchar2(30);

create or replace trigger zmena
    before insert or update on osoba
    for each row
begin
    :new.zmenu_vykonal := user;     -- v tele len nastavim rekord, ten ktorym to idem aktualizovat
end;
/
-------------------Zmena rod cisla
create or replace trigger zmena_rod_cisla
after update on osoba       --nezalezi ci before alebo after,referencna integrita sa skontroluje na konci
for each row
begin 
update ockovanie set rod_cislo = :new.rod_cislo where :old.rod_cislo = rod_cislo;
update ockovaci_tim set rod_cislo = :new.rod_cislo where :old.rod_cislo = rod_cislo;
end;
/
-------------------Zmena ICO
CREATE OR REPLACE TRIGGER zmena_ICO
	AFTER UPDATE ON dodavatel      
		FOR EACH ROW
BEGIN 
	UPDATE dodavka SET ICO = :NEW.ICO WHERE :OLD.ICO = ICO;
END;
/

-------------------Kurzor
--chcel by som dodavatela a pre daneho dodavatela vypisem informacie o tom ake dodavky vykonal
--jeden kurzor ziska konkretnych dodavatelov, druhy hodnoty ktore aktualne spracuvavam na dodavatela
--prvy kurzov s parametrom a budem nim preberat konkretneho dodavatela
declare
 cursor cur_dodavatel is select nazov, krajina, ICO as ICO_DO
  from dodavatel
   where ICO=&hodnota; --& bude vyjardovat ze hodnotu bude ziadat od pouzivatela, dame tam 1
 -- zadeklarovany kurzor, select asociujem s kurzorom
 -- budem potrebovat tie hodnoty toho kurzora niekde ukladat prikazom fetch do nejakych premmenych
 -- jedna s moznosti je ze si napisem tolko premmenych kolko mam v selecte atributov
 -- alebo si zadefinujem rekordovu premennu
 riadok_dodavatel cur_dodavatel%rowtype; --rekordova premenna, rovnaka struktura ako kurzor, odkazujem sa na ICO_DO
 -- kedze mam alias
 cursor cur_dodavky(p_ICO char) is select id_dodavky, nazov_centra as Nazov_Centra
  from dodavka where ICO=p_ICO; -- rozdielny nazov kvoli parametru kurzora
 -- kurzor pre dodavky, kurzor s parametrom, bude
 -- asociovany so selectom 
 -- kedze bude asociovany s rowtype tak musim zadat alias pri funkcii to_char
 riadok_dodavka cur_dodavky%rowtype;
 begin
  --spracujem kurzov
  open cur_dodavatel;--najprv ho otvorim, tu sa mi vytvori v pamati virtualna krabica
   loop
    fetch cur_dodavatel into riadok_dodavatel;--prikaz ktory priradi zaznam s kurzora do nejakych premennych
    exit when cur_dodavatel%notfound; -- ak kurzor uz nic nepriradi tak skoncim
    --chcel by som to niekde vypisat
    dbms_output.put_line(rpad(riadok_dodavatel.ICO_DO || ': ', 10) || rpad(riadok_dodavatel.nazov, 30) || ' ' || rpad(riadok_dodavatel.krajina, 30));
     --teraz by som otvaral druhy kurzor a v nom by som pre daneho dodavatela ziskal inf o dodavkach
     open cur_dodavky(riadok_dodavatel.ICO_DO);
       fetch cur_dodavky into riadok_dodavka;
       exit when cur_dodavky%notfound;
       dbms_output.put_line(' ' || riadok_dodavka.id_dodavky || ' ' || riadok_dodavka.Nazov_Centra);
     close cur_dodavky;
   end loop;
  close cur_dodavatel;
 end;
/

                                        
                --tim ktory nikdy neockoval astraZenca 
SELECT id_tim
    from ockovaci_tim ot
    WHERE NOT EXISTS(SELECT 'X'
                FROM ockovanie oc
                    where oc.id_tim = ot.id_tim
                        AND typ_vakciny = 'AZ');    
