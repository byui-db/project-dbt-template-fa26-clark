





with validation_errors as (

    select
        city, date
    from PROJECT_DB.STAGING.raw_weather_BHATTARAI_A
    group by city, date
    having count(*) > 1

)

select *
from validation_errors


