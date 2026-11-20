select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select DATE
from PROJECT_DB.RAW.API_WEATHER_BHATTARAI_A
where DATE is null



      
    ) dbt_internal_test