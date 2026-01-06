SELECT
    product_id
    ,product_name
    ,product_type
    ,category_name
    ,collection_name
    ,gender
FROM {{ ref ('stg_glamira_product')}}
WHERE product_id IS NOT NULL

UNION ALL

SELECT
    -1 product_id
    ,'Unknown' product_name
    ,'Unknown' product_type
    ,'Unknown' category_name
    ,'Unknown' collection_name
    ,'Unknown' gender