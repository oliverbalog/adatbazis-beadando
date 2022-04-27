-- Ez a tárolt eljárás a meghívásakor 5 paramétert vár, amik: a beszúrni kívánt útvonal ára, neve, hossza és a
-- hivatkozott tábla (idegenkulcs) azonosítója, azaz az indulas és végállomás id-je.
-- Sikeres adatok megadása esetén a tárolt eljárás beszúr egy rekordot az útvonal táblába.

--Példa futtatások:
--  exec utvonal_beszuras(3453,'onnan-oda',124,5,9); --Sikeres beszúrásra példa
--  exec utvonal_beszuras(3453,'Jászalsószentgyörgy - Szolnok',124,5,9); --Már létezõ útvonalnévre adott hiba példa
--  exec utvonal_beszuras(3453,'Innen - Oda',124,8,7); --Már létezõ megálló azonosítókra adott hiba példa


create or replace procedure utvonal_beszuras (ut_ar number, ut_nev varchar2, ut_hossz number, ut_vegallomas_id number, ut_indulas_id number) as
    hanyadik_ind       number;
    hanyadik_erk       number;
    talalat         number;
    letezo_utvonal  exception;
begin
    select count(*) into talalat
    from utvonal 
    where upper(utvonal.nev) = upper(ut_nev)
        or (utvonal.vegallomas_id = ut_vegallomas_id and utvonal.indulas_id = ut_indulas_id);
    if talalat > 0 then
        raise letezo_utvonal;
    end if;
    insert into utvonal (ar, nev, hossz, vegallomas_id, indulas_id) values (ut_ar, initcap(ut_nev), ut_hossz, ut_vegallomas_id, ut_indulas_id);
    select count(*) into hanyadik_ind
    from utvonal inner join megallo on utvonal.vegallomas_id = megallo.id
    where utvonal.vegallomas_id = ut_vegallomas_id;
    select count(*) into hanyadik_erk
    from utvonal inner join megallo on utvonal.indulas_id = megallo.id
    where utvonal.indulas_id = ut_indulas_id;
    dbms_output.put_line('A rekord beszúrva!');
    dbms_output.put_line('Az indulásra ' || hanyadik_ind || ' alkalommal van hivatkozva,' || ' az érkezésre pedig ' || hanyadik_erk || ' alkalommal van hivatkozva!' );
exception
    when letezo_utvonal
        then dbms_output.put_line('Ez az útvonal név vagy indulási és érkezési azonosító hivatkozás már létezik');
end utvonal_beszuras;
/