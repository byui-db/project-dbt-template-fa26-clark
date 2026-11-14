select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select published_at
from PROJECT_DB.STAGING.raw_news_BHATTARAI_A
where published_at is null



      
    ) dbt_internal_test