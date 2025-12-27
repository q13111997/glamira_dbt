SELECT
    product_id
    ,product_name
    ,product_type
    ,category
    ,category_name
    ,collection
    ,gender
FROM {{ ref ('stg_glamira_product')}}