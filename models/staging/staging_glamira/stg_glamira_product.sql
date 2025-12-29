SELECT
    SAFE_CAST(product_id AS INT64) AS product_id
    ,name AS product_name
    ,product_type
    ,category
    ,category_name
    ,collection
    ,gender
FROM {{ source('glamira_raw', 'products_info') }}