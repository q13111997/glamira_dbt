SELECT
    ip AS ip_address
    ,CASE
        WHEN country_short = 'IPV6 ADDRESS MISSING IN IPV4 BIN' THEN 'Unknown'
        ELSE COALESCE(country_short,'Unknown')
    END AS country_name_short
    ,CASE
        WHEN country_long = 'IPV6 ADDRESS MISSING IN IPV4 BIN' THEN 'Unknown'
        ELSE COALESCE(country_long,'Unknown') 
    END AS country_name_long
    ,CASE
        WHEN region = 'IPV6 ADDRESS MISSING IN IPV4 BIN' THEN 'Unknown'
        ELSE COALESCE(region,'Unknown') 
    END AS region_name
    ,CASE
        WHEN city = 'IPV6 ADDRESS MISSING IN IPV4 BIN' THEN 'Unknown'
        ELSE COALESCE(city,'Unknown') 
    END AS city_name
FROM {{ source('glamira_raw', 'ip_location') }}
WHERE country_short <> '-'
AND country_long <> '-'
AND region <> '-'
AND city <> '-'