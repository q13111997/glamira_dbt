SELECT DISTINCT
    product_id
    ,name AS product_name
    ,product_type
    ,category
    ,category_name
    ,collection_id
    ,collection
    ,gender
FROM {{ source('glamira_raw', 'products_info') }}