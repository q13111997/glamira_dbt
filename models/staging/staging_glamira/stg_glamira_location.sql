WITH stg_location__source AS (
    SELECT *
    FROM {{ source('glamira_raw', 'ip_location') }}
    WHERE country_short <> '-'
    AND country_long <> '-'
    AND region <> '-'
    AND city <> '-'
), 
stg_location__cast_type AS (
    SELECT
        ip AS ip_address
        ,CASE
            WHEN country_short IN ('IPV6 ADDRESS MISSING IN IPV4 BIN','-') THEN 'Unknown'
            ELSE COALESCE(country_short,'Unknown')
        END AS country_name_short
        ,CASE
            WHEN country_long IN ('IPV6 ADDRESS MISSING IN IPV4 BIN','-') THEN 'Unknown'
            ELSE COALESCE(country_long,'Unknown') 
        END AS country_name_long
        ,CASE
            WHEN region IN ('IPV6 ADDRESS MISSING IN IPV4 BIN','-') THEN 'Unknown'
            ELSE COALESCE(region,'Unknown') 
        END AS region_name
        ,CASE
            WHEN city IN ('IPV6 ADDRESS MISSING IN IPV4 BIN','-') THEN 'Unknown'
            ELSE COALESCE(city,'Unknown') 
        END AS city_name
    FROM stg_location__source
)
SELECT
    ip_address
    ,FARM_FINGERPRINT(CONCAT(country_name_short,'|',region_name,'|',city_name)) AS location_id
    ,country_name_short
    ,country_name_long
    ,region_name
    ,city_name
FROM stg_location__cast_type
    