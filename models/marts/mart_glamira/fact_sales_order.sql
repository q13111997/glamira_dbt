SELECT
    FARM_FINGERPRINT(CONCAT(SO.order_id,'|',SO.product_id)) AS order_key
    ,COALESCE(CT.customer_id,-1) AS customer_id
    ,COALESCE(LO.location_id,-1) AS location_id
    ,COALESCE(SO.date_id,19000101) AS date_id
    ,COALESCE(SO.store_id,-1) AS store_id
    ,COALESCE(SO.product_id,-1) AS product_id
    ,COALESCE(SO.order_id,-1) AS order_id
    ,SO.order_ts_utc
    ,SO.currency_code
    ,SO.unit_price
    ,SO.quantity
    ,SO.revenue
FROM {{ ref ('stg_glamira_sales_order')}} SO
LEFT JOIN {{ ref ('dim_customer')}} CT ON SO.user_id_db = CT.user_id_db
                                                AND SO.email_address = CT.email_address
LEFT JOIN {{ ref ('stg_glamira_location')}} LO ON SO.ip_address = LO.ip_address