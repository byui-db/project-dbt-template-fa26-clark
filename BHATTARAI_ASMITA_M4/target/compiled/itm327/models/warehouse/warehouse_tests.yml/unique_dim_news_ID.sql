
    
    

select
    ID as unique_field,
    count(*) as n_records

from PROJECT_DB.MODELED.dim_news_BHATTARAI_A
where ID is not null
group by ID
having count(*) > 1


