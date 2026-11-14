select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select city
from PROJECT_DB.STAGING.raw_weather_BHATTARAI_A
where city is null



      
    ) dbt_internal_test