select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    SYMBOL as unique_field,
    count(*) as n_records

from PROJECT_DB.MODELED.dim_symbols_BHATTARAI_A
where SYMBOL is not null
group by SYMBOL
having count(*) > 1



      
    ) dbt_internal_test