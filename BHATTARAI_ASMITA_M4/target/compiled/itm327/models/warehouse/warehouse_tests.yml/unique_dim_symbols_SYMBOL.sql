
    
    

select
    SYMBOL as unique_field,
    count(*) as n_records

from PROJECT_DB.MODELED.dim_symbols_BHATTARAI_A
where SYMBOL is not null
group by SYMBOL
having count(*) > 1


