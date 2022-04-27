-- Ez a t�rolt elj�r�s a megh�v�sakor 5 param�tert v�r, amik: a besz�rni k�v�nt �tvonal �ra, neve, hossza �s a
-- hivatkozott t�bla (idegenkulcs) azonos�t�ja, azaz az indulas �s v�g�llom�s id-je.
-- Sikeres adatok megad�sa eset�n a t�rolt elj�r�s besz�r egy rekordot az �tvonal t�bl�ba.

--P�lda futtat�sok:
--  exec utvonal_beszuras(3453,'onnan-oda',124,5,9); --Sikeres besz�r�sra p�lda
--  exec utvonal_beszuras(3453,'J�szals�szentgy�rgy - Szolnok',124,5,9); --M�r l�tez� �tvonaln�vre adott hiba p�lda
--  exec utvonal_beszuras(3453,'Innen - Oda',124,8,7); --M�r l�tez� meg�ll� azonos�t�kra adott hiba p�lda


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
    dbms_output.put_line('A rekord besz�rva!');
    dbms_output.put_line('Az indul�sra ' || hanyadik_ind || ' alkalommal van hivatkozva,' || ' az �rkez�sre pedig ' || hanyadik_erk || ' alkalommal van hivatkozva!' );
exception
    when letezo_utvonal
        then dbms_output.put_line('Ez az �tvonal n�v vagy indul�si �s �rkez�si azonos�t� hivatkoz�s m�r l�tezik');
end utvonal_beszuras;
/