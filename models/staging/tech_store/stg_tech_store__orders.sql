WITH

ORDERS AS (

    SELECT * FROM {{ source('tech_store', 'orders') }}

),

FINAL AS (

    SELECT
        ID AS ORDER_ID,
        PRODUCTID AS PRODUCT_ID,
        QUANTITY,
        USERID AS EMPLOYEE_ID,
        CUSTOMERID AS CUSTOMER_ID,
        DATETIME AS CREATED_AT,
        {{ utc_to_est('datetime') }} AS CREATED_AT_EST

    FROM ORDERS

)

SELECT * FROM FINAL
