use banca;
show tables ;

# MOSTRO I DATI DI CIASCUNA TABELLA 

select * from cliente;
select * from conto;
select * from tipo_conto;
select * from tipo_transazione;
select * from transazioni;

# 1 - Eta di ogni cliente

select year(current_date()) - year(data_nascita) as eta_cliente
from cliente;

# 2 - Numero di transazioni in uscita su tutti i conti

select id_cliente, count(data) as numero_transazioni_uscite 
from (select data, transazioni.id_conto
		from transazioni join tipo_transazione on (transazioni.id_tipo_trans=tipo_transazione.id_tipo_transazione)
		where segno='-') as a join conto on (a.id_conto=conto.id_conto)
group by id_cliente; 



# 3 - Numero di transazioni in entrata su tutti i conti


select id_cliente, count(data) as numero_transazioni_entrate 
from (select data, transazioni.id_conto
		from transazioni join tipo_transazione on (transazioni.id_tipo_trans=tipo_transazione.id_tipo_transazione)
		where segno='+') as a join conto on (a.id_conto=conto.id_conto)
group by id_cliente
order by id_cliente asc ; 

# 4 - Importo transato in uscita su tutti i conti

select sum(importo) as importo_transato_uscita   
from transazioni
where importo < 0;


# 5 - Importo transato in entrata su tutti i conti

select sum(importo) as importo_transato_entrata   
from transazioni
where importo > 0;

# 6 - Numero totale di conti posseduti


select cliente.id_cliente, COUNT(conto.id_conto) as numero_conti
from cliente
left join conto on cliente.id_cliente = conto.id_cliente
group by cliente.id_cliente
order by id_cliente;



# 7 - Numero di conti posseduti per tipologia (un indicatore per tipo)


select cliente.id_cliente,
count(case when conto.id_tipo_conto = 0 then conto.id_cliente end) as conti_base,
count(case when conto.id_tipo_conto = 1 then conto.id_cliente end) as conti_business,
count(case when conto.id_tipo_conto = 2 then conto.id_cliente end) as conti_privati,
count(case when conto.id_tipo_conto = 3 then conto.id_cliente end) as conti_famiglie
from conto
left join cliente on conto.id_cliente = cliente.id_cliente
group by cliente.id_cliente
order by cliente.id_cliente;



# 8 - Numero di conti transazioni in uscita per tipologia (un indicatore per tipo)



select conto.id_cliente,
    sum(case when a.desc_tipo_trans='Acquisto su Amazon' then 1 else 0 end) as N_Acquisto_su_Amazon,
    sum(case when a.desc_tipo_trans='Rata mutuo' then 1 else 0 end) as N_Rata_mutuo,
    sum(case when a.desc_tipo_trans='Hotel' then 1 else 0 end) as N_Hotel,
    sum(case when a.desc_tipo_trans='Biglietto aereo' then 1 else 0 end) as N_Biglietto_aereo,
    sum(case when a.desc_tipo_trans='Supermercato' then 1 else 0 end) as N_Supermercato
from 
    conto
left join
    (select id_conto, desc_tipo_trans as desc_tipo_trans
    from tipo_transazione as tipo 
    join transazioni as trans on tipo.id_tipo_transazione=trans.id_tipo_trans
    where segno='-') as a on conto.id_conto=a.id_conto
group by 
    conto.id_cliente
order by 
    conto.id_cliente;





# 9 - Numero di transazioni in entrata per tipologia(un indicatore tipo)



select conto.id_cliente,
    sum(case when a.desc_tipo_trans='Stipendio' then 1 else 0 end) as N_Stipendio,
    sum(case when a.desc_tipo_trans='Pensione' then 1 else 0 end) as N_Pensione,
    sum(case when a.desc_tipo_trans='Dividendi' then 1 else 0 end) as N_Dividendi
from 
    conto
left join
    (select id_conto, desc_tipo_trans as desc_tipo_trans
    from tipo_transazione as tipo 
    join transazioni as trans on tipo.id_tipo_transazione=trans.id_tipo_trans
    where segno='+') as a on conto.id_conto=a.id_conto
group by 
    conto.id_cliente
order by 
    conto.id_cliente;

# 10 - Importo transato in uscita per tipologia di conto (un indicatore per tipo)


select 
    conto.id_cliente,
    ifnull(tot_Acquisto_su_Amazon, 0) as tot_Acquisto_su_Amazon,
    ifnull(tot_Rata_mutuo, 0) as tot_Rata_mutuo,
    ifnull(tot_Hotel, 0) as tot_Hotel,
    ifnull(tot_Biglietto_aereo, 0) as tot_Biglietto_aereo,
    ifnull(tot_Supermercato, 0) as tot_Supermercato
from 
    conto
left join (
    select 
        id_conto,
        sum(case when desc_tipo_trans = 'Acquisto su Amazon' then importo else 0 end) as Tot_Acquisto_su_Amazon,
        sum(case when desc_tipo_trans = 'Rata mutuo' then importo else 0 end) as Tot_Rata_mutuo,
        sum(case when desc_tipo_trans = 'Hotel' then importo else 0 end) as Tot_Hotel,
        sum(case when desc_tipo_trans = 'Biglietto aereo' then importo else 0 end) as Tot_Biglietto_aereo,
        sum(case when desc_tipo_trans = 'Supermercato' then importo else 0 end) as Tot_Supermercato
    from 
        tipo_transazione as tipo
    join 
        transazioni as trans on tipo.id_tipo_transazione = trans.id_tipo_trans
    where 
        segno = '-'
    group by 
        id_conto
) as totals on conto.id_conto = totals.id_conto
order by conto.id_cliente;



# 11 - Importo transato in entrata per tipologia di conto (un indicatore per tipo)


select 
    conto.id_cliente,
    ifnull(Tot_Stipendio, 0) as Tot_Stipendi,
    ifnull(Tot_Pensione, 0) as Tot_Pensione,
    ifnull(Tot_Dividendi, 0) as Tot_Dividendi
from conto
left join (
    select 
        id_conto,
        sum(CASE WHEN desc_tipo_trans = 'Stipendio' THEN importo ELSE 0 END) AS Tot_Stipendio,
        sum(CASE WHEN desc_tipo_trans = 'Rata mutuo' THEN importo ELSE 0 END) AS Tot_Pensione,
        sum(CASE WHEN desc_tipo_trans = 'Hotel' THEN importo ELSE 0 END) AS Tot_Dividendi
	
    FROM 
        tipo_transazione AS tipo
    JOIN 
        transazioni AS trans ON tipo.id_tipo_transazione = trans.id_tipo_trans
    WHERE 
        segno = '+'
    GROUP BY 
        id_conto
) AS totals ON conto.id_conto = totals.id_conto
ORDER BY 
    conto.id_cliente;

