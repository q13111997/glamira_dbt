SELECT
    FARM_FINGERPRINT(CONCAT(SO.order_id,'|',SO.product_id,'|',SO.price)) AS order_key
    ,CT.customer_id
    ,FARM_FINGERPRINT(CONCAT(LO.country_name_short,'|',LO.region_name,'|',LO.city_name)) AS location_id
    ,SO.date_id
    ,SO.store_id
    ,SO.product_id
    ,SO.order_id
    ,SO.order_ts_utc
    ,SO.currency
    ,SO.price
    ,SO.quantity
    ,SO.revenue
FROM {{ ref ('stg_glamira_sales_order')}} SO
LEFT JOIN {{ ref ('dim_customer')}} CT ON SO.user_id_db = CT.user_id_db
                                                AND SO.email_address = CT.email_address
LEFT JOIN {{ ref ('stg_glamira_location')}} LO ON SO.ip = LO.ip