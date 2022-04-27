--Ez a tárolt eljárás az útvonal tábla hossz mezõjét várja bemenõ paramétereként, majd
--ha talál ilyen létezõ hosszú útvonalat, akkor a hozzá kapcsolódó rekordokat formázottan kilistázza a menetrend
--táblából. Ha nincs ilyen hossz hibaüzenetet ír ki, ha nincs a léátezõ hossz rekordjához kapcsolódó
--rekord a menetrend táblában , szintén hibát ír az eljárás.


--Példa futtatások:
exec hossz_kereso(235); --A másik táblából (az idegen kulcsot tartalmazó) nem tartozik hozzá rekord
exec hossz_kereso(2353); --A kulcsot tartalmazó táblában nincs ilyen rekord
exec hossz_kereso(200); --Tartozik hozzá több rekord is, megjeleníti õket formázottan


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
         dbms_output.put_line(rpad('Azonosító:',11) || rpad(ut_rec.id,5) || 
                         rpad('Útvonal az.:',15) || rpad(ut_rec.utvonal_id, 5) ||
                         rpad('Vonat az.:',15) || rpad(ut_rec.vonat_id, 5) ||
                         rpad('Indulás ideje:',20) || rpad(ut_rec.indulas_ideje,35) ||
                         rpad('Érkezés ideje:',20) || rpad(ut_rec.erkezes_ideje, 35));

        end loop;
        select count(*) into menetrend_c from utvonal inner join menetrend on utvonal.id = menetrend.utvonal_id where hossz = hosszusag;
    end if;
    dbms_output.put_line('Az vonat azonosítóhoz tartozó útvonalak száma: ' || menetrend_c);

exception
    when nemletezo_ut
        then dbms_output.put_line('Ehhez a hosszhoz nem tartozik útvonal' || nemletezo_menetrend_c);
    when nemletezo_menetrend
         then dbms_output.put_line('Ehhez a hosszhoz tartozó útvonalhoz nem tartozik kapcsolódó menetrend!' || nemletezo_ut_c);
    
       


end hossz_kereso;
/