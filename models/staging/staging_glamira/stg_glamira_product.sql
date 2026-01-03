SELECT
    SAFE_CAST(product_id AS INT64) AS product_id
    ,COALESCE(name,'Unknown') AS product_name
    ,CASE 
        WHEN product_type IN ('-1','--_select_--') THEN 'Unknown'
        ELSE COALESCE(product_type ,'Unknown')
    END AS product_type
    ,COALESCE(category_name,'Unknown') AS category_name
    ,CASE
        WHEN collection IN ('4380,6071') THEN '3_&_5_stones'
        ELSE COALESCE(collection,'Unknown') 
    END AS collection_name
    ,CASE 
        WHEN collection = 'False' THEN 'Unknown'
        ELSE COALESCE(gender,'Unknown') 
    END AS gender
FROM {{ source('glamira_raw', 'products_info') }}