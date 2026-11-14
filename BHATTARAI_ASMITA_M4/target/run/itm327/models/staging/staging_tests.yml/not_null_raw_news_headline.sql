select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select headline
from PROJECT_DB.STAGING.raw_news_BHATTARAI_A
where headline is null



      
    ) dbt_internal_test