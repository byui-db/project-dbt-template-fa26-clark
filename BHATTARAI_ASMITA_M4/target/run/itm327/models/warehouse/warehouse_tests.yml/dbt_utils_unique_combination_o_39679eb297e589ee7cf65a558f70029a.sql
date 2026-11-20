select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      





with validation_errors as (

    select
        CITY, DATE
    from PROJECT_DB.MODELED.fct_daily_weather_BHATTARAI_A
    group by CITY, DATE
    having count(*) > 1

)

select *
from validation_errors



      
    ) dbt_internal_test