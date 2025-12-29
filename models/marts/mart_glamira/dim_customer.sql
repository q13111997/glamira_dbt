SELECT DISTINCT
    FARM_FINGERPRINT(CONCAT(user_id_db,'|',email_address)) AS customer_id
    ,user_id_db
    ,email_address
FROM {{ ref ('stg_glamira_customer')}}
WHERE user_id_db IS NOT NULL
AND email_address IS NOT NULL