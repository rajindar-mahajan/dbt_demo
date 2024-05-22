WITH

CUSTOMERS AS (

    SELECT * FROM {{ source('tech_store', 'customer') }}

),

FINAL AS (

    SELECT
        ID AS CUSTOMER_ID,
        NAME AS CUSTOMER_NAME,
        CITYID AS CITY_ID,
        MAINSALESREPID AS MAIN_EMPLOYEE_ID,
        CREATEDATETIME AS CREATED_AT,
        {{ utc_to_est('createdatetime') }} AS CREATED_AT_EST,
        UPDATEDATETIME AS UPDATED_AT,
        {{ utc_to_est('updatedatetime') }} AS UPDATED_AT_EST,
        IFF(ACTIVE = 'yes', TRUE, FALSE) AS IS_ACTIVE

    FROM CUSTOMERS

)

SELECT * FROM FINAL
