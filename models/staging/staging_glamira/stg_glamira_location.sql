SELECT DISTINCT
    country_short AS country_name_short
    ,country_long AS country_name_long
    ,region AS region_name
    ,city AS city_name
FROM {{ source('glamira_raw', 'ip_location') }}