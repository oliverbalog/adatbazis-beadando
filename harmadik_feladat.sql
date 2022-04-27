--Ez a funkció egy szám típusú 'ár' bemenetet vár meghíváskor, majd hibakódokat ad vissza, ha hibát talál. 
--Ha sikeresen talál mindkét esetben egy relációjú rekordot, akkor a menetrend tábla eredmény rekordjának az azonosítóját adja vissza eredményül.
--Ha az útvonalban létezik ilyen ár, de többször is, akkor -2 eredménnyel tér vissza
--Ha a megadott ár nem létezik az útvonal tábla rekorjainak az ár mezőiben, akkor -1 eredménnyel tér vissza.
--Ha mind a kettő táblában sikeresen csak egy-egy kapcsolódó rekordot talál: a kapcsolódó menetrend tábla rekord azonosítóját adja vissza.
--Ha létezik az ár az útvonal tábla rekorjainak az ár mezőjében és van hozzá kapcsolódó rekord a menetrend táblában, de ott több is, akkor -4 eredményt ad.
--Végül ha létezik az útvonalban ilyen árú útvonal, de a menetrendből nincs hozzá kapcsolódó rekord, akkor -3 az eredmény.

/*
Példa függvényhívások:
-------------------------------------------------------------------------------------
begin
    dbms_output.put_line(ar_eredmeny(4500));    --létezik, de több rekordot is eredménynek talál a kulcs táblájából, azaz az útvonal táblából
end;
-------------------------------------------------------------------------------------
begin
    dbms_output.put_line(ar_eredmeny(1));    --nem létezik ilyen árú útvonal rekord
end;
-------------------------------------------------------------------------------------
begin
    dbms_output.put_line(ar_eredmeny(2000));    --létezik és mindkét táblában csak egy kapcsolódása van -> sikeresen visszaadja az azonosítót a másik táblából (a menetrendből)
end;
-------------------------------------------------------------------------------------
begin
    dbms_output.put_line(ar_eredmeny(3000));    --létezik mindkét táblában, de több rekord is kapcsolódik hozzá abból a táblából, amelyikben az idegen kulcs van. (a menetrendbőlÖ
end;
-------------------------------------------------------------------------------------
begin
    dbms_output.put_line(ar_eredmeny(8678));    --létezik, de az idegen kulcsot tartalmazó táblából nem kapcsolódik hozzá rekord (a menetrendből)
end;
-------------------------------------------------------------------------------------
*/


create or replace function ar_eredmeny(be_ar number) return number as
    eredmeny number(5);
    nemletezoar exception;
    nemletezoar_c number;
    tobbar  exception;
    nemletezomenetrend exception;
    nemletezomenetrend_c number;
    tobbmenetrend exception;
    eredmenyid number;
begin
    select count(*) into nemletezoar_c from utvonal where ar = be_ar;
    select count(*) into nemletezomenetrend_c from utvonal inner join menetrend on menetrend.utvonal_id = utvonal.id
        where ar=be_ar;
    if nemletezoar_c < 1 
        then raise nemletezoar;
    elsif nemletezoar_c > 1
        then raise tobbar;
    elsif nemletezomenetrend_c < 1
        then raise nemletezomenetrend;
    elsif nemletezomenetrend_c > 1
        then raise tobbmenetrend;
    elsif nemletezoar_c = 1 and nemletezomenetrend_c=1
       then select menetrend.id into eredmenyid from utvonal inner join menetrend on menetrend.utvonal_id = utvonal.id
        where ar=be_ar;
        return eredmenyid;
    end if;
exception
    when  nemletezoar
        then return -1;
    when tobbar
        then return -2;
    when nemletezomenetrend
        then return -3;
    when tobbmenetrend
        then return -4;
end ar_eredmeny;
/
