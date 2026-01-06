SELECT DISTINCT
    location_id
    ,country_name_short
    ,country_name_long
    ,region_name
    ,city_name
FROM {{ ref ('stg_glamira_location')}}

UNION ALL

SELECT
    -1 location_id
    ,'Unknown' country_name_short
    ,'Unknown' country_name_long
    ,'Unknown' region_name
    ,'Unknown' city_name