select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        DIRECTION as value_field,
        count(*) as n_records

    from PROJECT_DB.MODELED.fct_daily_stocks_BHATTARAI_A
    group by DIRECTION

)

select *
from all_values
where value_field not in (
    'UP','DOWN','FLAT'
)



      
    ) dbt_internal_test