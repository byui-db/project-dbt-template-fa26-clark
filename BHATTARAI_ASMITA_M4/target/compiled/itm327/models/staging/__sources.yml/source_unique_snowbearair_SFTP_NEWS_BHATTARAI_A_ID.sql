
    
    

select
    ID as unique_field,
    count(*) as n_records

from PROJECT_DB.RAW.SFTP_NEWS_BHATTARAI_A
where ID is not null
group by ID
having count(*) > 1


