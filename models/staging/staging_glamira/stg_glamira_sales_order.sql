SELECT
    order_key
    ,customer_id
    ,location_id
    ,date_id
    ,store_id
    ,product_id
    ,option_label
    ,option_value
    ,order_id
    ,order_ts_utc
    ,currency
    ,unit_price
    ,quantity
    ,revenue
FROM {{ source('glamira_raw', 'summary') }} SUMMARY
LEFT JOIN
WHERE collection = 'checkout_success'