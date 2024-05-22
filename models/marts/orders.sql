WITH

ORDERS AS (

    SELECT * FROM {{ ref('stg_tech_store__orders') }}

),

TRANSACTIONS AS (

    SELECT * FROM {{ ref('stg_payment_app__transactions') }}

),

PRODUCTS AS (

    SELECT * FROM {{ ref('stg_tech_store__products') }}

),

CUSTOMERS AS (

    SELECT * FROM {{ ref('stg_tech_store__customers') }}
),

-- sale_dates as (

--     select * from {{ ref('sale_dates') }}

-- ),


FINAL AS (

    SELECT
        ORDERS.ORDER_ID,
        TRANSACTIONS.TRANSACTION_ID,
        CUSTOMERS.CUSTOMER_ID,
        CUSTOMERS.CUSTOMER_NAME,
        PRODUCTS.PRODUCT_NAME,
        PRODUCTS.CATEGORY,
        PRODUCTS.PRICE,
        PRODUCTS.CURRENCY,
        ORDERS.QUANTITY,
        --sale_dates.sale_date is not null as is_sale_order,
        --nvl(sale_dates.discount_percent, 0) as discount_percent, 
        TRANSACTIONS.COST_PER_UNIT_IN_USD,
        TRANSACTIONS.AMOUNT_IN_USD,
        {{ usd_to_gbp('transactions.amount_in_usd') }} AS AMOUNT_IN_GBP,
        {{ usd_to_currency('transactions.amount_in_usd', 'GBP') }} AS AMOUNT_IN_GBP_2,
        TRANSACTIONS.TAX_IN_USD,
        TRANSACTIONS.TOTAL_CHARGED_IN_USD,
        ORDERS.CREATED_AT,
        ORDERS.CREATED_AT_EST

    FROM ORDERS

    LEFT JOIN TRANSACTIONS
        ON ORDERS.ORDER_ID = TRANSACTIONS.ORDER_ID

    LEFT JOIN PRODUCTS
        ON ORDERS.PRODUCT_ID = PRODUCTS.PRODUCT_ID

    LEFT JOIN CUSTOMERS
        ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID

-- left join sale_dates
-- on orders.created_at_dt = sale_dates.sale_date

)

SELECT * FROM FINAL
