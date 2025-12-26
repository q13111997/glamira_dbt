SELECT DISTINCT
    FARM_FINGERPRINT(CONCAT(country_name_short,'|',region_name,'|',city_name)) AS location_id
    ,country_name_short
    ,country_name_long
    ,region_name
    ,city_name
FROM {{ ref ('stg_glamira_location')}}