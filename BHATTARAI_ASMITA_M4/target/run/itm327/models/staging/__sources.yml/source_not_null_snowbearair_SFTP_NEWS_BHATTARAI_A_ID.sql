select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ID
from PROJECT_DB.RAW.SFTP_NEWS_BHATTARAI_A
where ID is null



      
    ) dbt_internal_test