{{
    config(
        materialized='incremental',
        unique_key = 'order_id'
    )
}}
    -- REQUIREMENTS
    -- 1. cannot trigger as a full refresh
    -- 2. midel must already exist
    -- 3. table in DB must already exist - Otherwise it gets created as part of full refresh
    -- 4. materialzed set to incremental

with

orders as (

    select * from {{ ref('stg_tech_store__orders') }}

    {% if is_incremental() %}

    where created_at_est > (
        COALESCE( (select max(created_at_est) from {{ this }} ), '1900-01-01')
        )

    {% endif %}

),

transactions as (

    select * from {{ ref('stg_payment_app__transactions') }}

),

products as (

    select * from {{ ref('stg_tech_store__products') }}

),

customers as (

    select * from {{ ref('stg_tech_store__customers') }}
),

-- sale_dates as (

--     select * from {{ ref('sale_dates') }}

-- ),


final as (

    select
        orders.order_id,
        transactions.transaction_id,
        customers.customer_id,
        customers.customer_name,
        products.product_name,
        products.category,
        products.price,
        products.currency,
        orders.quantity,
        --sale_dates.sale_date is not null as is_sale_order,
        --nvl(sale_dates.discount_percent, 0) as discount_percent, 
        transactions.cost_per_unit_in_usd,
        transactions.amount_in_usd,
        {{ usd_to_gbp('transactions.amount_in_usd') }} as amount_in_gbp,
        transactions.tax_in_usd,
        transactions.total_charged_in_usd,
        orders.created_at,
        orders.created_at_est

    from orders

    left join transactions
        on orders.order_id = transactions.order_id

    left join products
        on orders.product_id = products.product_id

    left join customers
        on orders.customer_id = customers.customer_id

    -- left join sale_dates
        -- on orders.created_at_dt = sale_dates.sale_date

)

select * from final