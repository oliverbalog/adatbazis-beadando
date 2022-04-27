--Ez a t�rolt elj�r�s az �tvonal t�bla hossz mez�j�t v�rja bemen� param�terek�nt, majd
--ha tal�l ilyen l�tez� hossz� �tvonalat, akkor a hozz� kapcsol�d� rekordokat form�zottan kilist�zza a menetrend
--t�bl�b�l. Ha nincs ilyen hossz hiba�zenetet �r ki, ha nincs a l��tez� hossz rekordj�hoz kapcsol�d�
--rekord a menetrend t�bl�ban , szint�n hib�t �r az elj�r�s.


--P�lda futtat�sok:
exec hossz_kereso(235); --A m�sik t�bl�b�l (az idegen kulcsot tartalmaz�) nem tartozik hozz� rekord
exec hossz_kereso(2353); --A kulcsot tartalmaz� t�bl�ban nincs ilyen rekord
exec hossz_kereso(200); --Tartozik hozz� t�bb rekord is, megjelen�ti �ket form�zottan


create or replace procedure hossz_kereso(hosszusag in number) as
    cursor ut_cur is
        select 
menetrend.ID ID,
menetrend.UTVONAL_ID UTVONAL_ID,
menetrend.VONAT_ID VONAT_ID,
menetrend.INDULAS_IDEJE INDULAS_IDEJE,
menetrend.ERKEZES_IDEJE ERKEZES_IDEJE from utvonal inner join menetrend on utvonal.id = menetrend.utvonal_id
        where hossz = hosszusag;
    ut_rec ut_cur%rowtype;
    menetrend_c number(3);
    nemletezo_menetrend_c number(3);
    nemletezo_ut_c number(3);
    nemletezo_menetrend exception;
    nemletezo_ut exception;
begin
    select count(*) into nemletezo_ut_c from utvonal where hossz = hosszusag;
    select count(*) into nemletezo_menetrend_c from utvonal inner join menetrend on utvonal.id = menetrend.utvonal_id
        where hossz = hosszusag;
    if nemletezo_ut_c < 1 then
        raise nemletezo_ut;
    elsif nemletezo_menetrend_c < 1 then
        raise nemletezo_menetrend;
    
    end if;
    if nemletezo_menetrend_c > 0 and nemletezo_ut_c > 0 then
        for ut_rec in ut_cur loop
         dbms_output.put_line(rpad('Azonos�t�:',11) || rpad(ut_rec.id,5) || 
                         rpad('�tvonal az.:',15) || rpad(ut_rec.utvonal_id, 5) ||
                         rpad('Vonat az.:',15) || rpad(ut_rec.vonat_id, 5) ||
                         rpad('Indul�s ideje:',20) || rpad(ut_rec.indulas_ideje,35) ||
                         rpad('�rkez�s ideje:',20) || rpad(ut_rec.erkezes_ideje, 35));

        end loop;
        select count(*) into menetrend_c from utvonal inner join menetrend on utvonal.id = menetrend.utvonal_id where hossz = hosszusag;
    end if;
    dbms_output.put_line('Az vonat azonos�t�hoz tartoz� �tvonalak sz�ma: ' || menetrend_c);

exception
    when nemletezo_ut
        then dbms_output.put_line('Ehhez a hosszhoz nem tartozik �tvonal' || nemletezo_menetrend_c);
    when nemletezo_menetrend
         then dbms_output.put_line('Ehhez a hosszhoz tartoz� �tvonalhoz nem tartozik kapcsol�d� menetrend!' || nemletezo_ut_c);
    
       


end hossz_kereso;
/