/*
4. feladat
A fájl lefuttatásakor létrejön egy tábla, amit arra használunk, hogy naplózzuk a DML mûveleteket, 
amik a VONAT táblát érintik.
Ezután létrejön egy TRIGGER, ami azt teszi lehetõvé, hogy a VONAT táblára kiható DML mûveleteket 
elmenti a VONAT_LOG táblába.

Példa mûveletek:

insert into vonat (id,nev) values (25,'VONATNEV'); --> beszúr a VONAT táblába egy rekordot, ezen kívül
		kitalálja a VONAT_DML_TRIGGER nevû TRIGGER, hogy milyen mûveletet végeztünk rajta, majd 
		beszúr egy rekordot a VONAT_LOG táblába.

update vonat set nev = 'ÚJ VONAT' where id = 25; --Módosítja a VONAT táblában a 25-ös id-jû rekordot "ÚJ VONAT"
		névre, majd beszúr a módosítás adatairól egy rekordot a VONAT_LOG táblába.
		
delete from vonat where id = 25; --Kitörli a VONAT táblából a 25-ös id-jû rekordot, majd naplózza azt.

*/

create table vonat_log (
    insert_date DATE,
    username    varchar2(100),
    primary_key number(3),
    modifications   varchar2(100));
    
create or replace trigger vonat_dml_trigger
after insert or update or delete on vonat
for each row
declare
    pragma autonomous_transaction;
begin
        if inserting then
            insert into vonat_log values(sysdate, user, :new.id, 'Beszúrás');
        elsif updating then
            insert into vonat_log values(sysdate, user, :old.id, 'Módosítás');
        elsif deleting then
            insert into vonat_log values(sysdate, user, :old.id, 'Törlés');
        end if;
        commit;
end vonat_dml;
/