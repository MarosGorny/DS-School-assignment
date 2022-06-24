--Zaockovani zdravotnici
--Master report
SELECT distinct(SUBSTR(o.id_tim,1,2)) as Okres
    FROM ockovanie.o;
--Child report
SELECT 'Poèet zaoèkovaných zdravotníkov v kraji', SUBSTR(id_tim,1,2), COUNT(*)
    FROM ockovanie
        WHERE SUBSTR(id_tim,1,2)=:OKRES and pracovna_pozicia = 'Z'
            GROUP BY SUBSTR(id_tim,1,2)
                ORDER BY SUBSTR(id_tim,1,2);

--Ockovane osoby
--Master report
select os.meno, os.priezvisko, os.rod_cislo as RODNECISLO
    from osoba os
--Child report
select 'Pocet Ockovani', datum_ockovania, count(*) as PocetOckovani
    from ockovanie
        where rod_cislo=:RODNECISLO
            group by rod_cislo, datum_ockovania
