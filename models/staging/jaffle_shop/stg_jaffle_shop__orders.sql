select
    id as order_id,
    user_id as customer_id,
    order_date,
    status
from project-480502.raw_jaffle_shop.orders
