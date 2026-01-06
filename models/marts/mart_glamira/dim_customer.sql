SELECT DISTINCT
    FARM_FINGERPRINT(CONCAT(user_id_db,'|',email_address)) AS customer_id
    ,user_id_db
    ,email_address
FROM {{ ref ('stg_glamira_customer')}}

UNION ALL

SELECT
    -1 customer_id
    ,-1 user_id_db
    ,'Unknown' email_address