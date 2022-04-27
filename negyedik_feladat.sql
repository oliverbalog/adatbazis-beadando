/*
4. feladat
A f�jl lefuttat�sakor l�trej�n egy t�bla, amit arra haszn�lunk, hogy napl�zzuk a DML m�veleteket, 
amik a VONAT t�bl�t �rintik.
Ezut�n l�trej�n egy TRIGGER, ami azt teszi lehet�v�, hogy a VONAT t�bl�ra kihat� DML m�veleteket 
elmenti a VONAT_LOG t�bl�ba.

P�lda m�veletek:

insert into vonat (id,nev) values (25,'VONATNEV'); --> besz�r a VONAT t�bl�ba egy rekordot, ezen k�v�l
		kital�lja a VONAT_DML_TRIGGER nev� TRIGGER, hogy milyen m�veletet v�gezt�nk rajta, majd 
		besz�r egy rekordot a VONAT_LOG t�bl�ba.

update vonat set nev = '�J VONAT' where id = 25; --M�dos�tja a VONAT t�bl�ban a 25-�s id-j� rekordot "�J VONAT"
		n�vre, majd besz�r a m�dos�t�s adatair�l egy rekordot a VONAT_LOG t�bl�ba.
		
delete from vonat where id = 25; --Kit�rli a VONAT t�bl�b�l a 25-�s id-j� rekordot, majd napl�zza azt.

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
            insert into vonat_log values(sysdate, user, :new.id, 'Besz�r�s');
        elsif updating then
            insert into vonat_log values(sysdate, user, :old.id, 'M�dos�t�s');
        elsif deleting then
            insert into vonat_log values(sysdate, user, :old.id, 'T�rl�s');
        end if;
        commit;
end vonat_dml;
/