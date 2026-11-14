select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      





with validation_errors as (

    select
        city, date
    from PROJECT_DB.STAGING.raw_weather_BHATTARAI_A
    group by city, date
    having count(*) > 1

)

select *
from validation_errors



      
    ) dbt_internal_test