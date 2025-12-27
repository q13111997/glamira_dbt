SELECT
    CAST(product_id AS INT64) AS product_id
    ,name AS product_name
    ,product_type
    ,category
    ,category_name
    ,CAST(collection_id AS INT64) AS collection_id
    ,collection
    ,gender
FROM {{ source('glamira_raw', 'products_info') }}