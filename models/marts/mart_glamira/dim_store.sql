SELECT DISTINCT
    store_id
    ,store_name
FROM {{ ref ('stg_glamira_store')}}
WHERE store_id IS NOT NULL

UNION ALL

SELECT
    -1 store_id
    ,'Unknown' store_name