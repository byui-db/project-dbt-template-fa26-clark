select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select TICKER
from PROJECT_DB.RAW.SFTP_NEWS_BHATTARAI_A
where TICKER is null



      
    ) dbt_internal_test