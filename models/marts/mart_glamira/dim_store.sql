SELECT
    store_id
    ,store_name
FROM {{ ref ('stg_glamira_store')}}