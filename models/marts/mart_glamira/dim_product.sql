SELECT
    CAST(product_id AS INT64) AS product_id
    ,product_name
    ,product_type
    ,category
    ,category_name
    ,collection
    ,gender
FROM {{ ref ('stg_glamira_product')}}