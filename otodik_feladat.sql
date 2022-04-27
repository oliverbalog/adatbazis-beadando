create or replace view utvonal_indulas --INSERT: úgy insertel, hogy a vegállomás megálló mindig budapest keleti
    as select nev, telepules_nev
    from utvonal inner join megallo on megallo.id = utvonal.indulas_id;
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
create or replace trigger utvonal_indulas_insert_trigger
instead of insert on utvonal_indulas
for each row
 declare 
    mar_letezo_utvonal exception;
    nemletezo_utvonal_megallo exception;
    van_megalloja    exception;
    indulas_beszur   utvonal.indulas_id%type;
    x1  number(5);
    x2  number(5);
    x3  number(5);
begin
select count(*) into x1 from utvonal where nev = :new.nev;
select count(*) into x2 from megallo where telepules_nev = :new.telepules_nev;
select count(*) into x3 from utvonal inner join megallo on megallo.id = utvonal.indulas_id
         where telepules_nev = :new.telepules_nev;
    if
        x1 > 0
                then raise mar_letezo_utvonal;
    elsif
        x1 < 1 and x2 < 1
                then raise nemletezo_utvonal_megallo;
    elsif 
        x3 > 0
                then raise van_megalloja;
    else
        select id into indulas_beszur from megallo where telepules_nev = :new.telepules_nev;
        insert into utvonal (ar, nev, hossz, vegallomas_id, indulas_id) values ('1000', :new.nev, 50, 6, indulas_beszur);
    end if;
exception
    when mar_letezo_utvonal
        then dbms_output.put_line('A beszúrni kívánt útvonal már létezik: ' || :new.nev);
    when nemletezo_utvonal_megallo
        then dbms_output.put_line('A megadott település név nem létezik: ' || :new.telepules_nev);
    when van_megalloja
        then dbms_output.put_line('A beszúrni kívánt útvonalhoz már tartozik megálló: ' || :new.nev);
end utvonal_indulas_insert_trigger;
/
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
create or replace trigger utvonal_indulas_update_trigger
instead of update on utvonal_indulas
for each row
    declare
        is_utvonal_nev_change boolean;
        nemletezo_utvonal   exception;
        van_megalloja    exception;
         x1  number(5);
        x2  number(5);
        x3  number(5);
begin
    select count(*) into x1 from utvonal where nev = :new.nev;
    select count(*) into x2 from megallo where telepules_nev = :new.telepules_nev;
    select count(*) into x3 from utvonal inner join megallo on megallo.id = utvonal.indulas_id