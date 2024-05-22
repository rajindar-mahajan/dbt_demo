{{
    config(
        materialized='incremental',
        unique_key = 'customer_id'
    )
}}
    -- REQUIREMENTS
    -- 1. cannot trigger as a full refresh
    -- 2. midel must already exist
    -- 3. table in DB must already exist - Otherwise it gets created as part of full refresh
    -- 4. materialzed set to incremental

with

customers as (

    select * from {{ ref('stg_tech_store__customers') }}

    {% if is_incremental() %}

    where created_at_est > (
        COALESCE( (select max(created_at_est) from {{ this }} ), '1900-01-01')
        )
        OR updated_at_est > (
        COALESCE( (select max(updated_at_est) from {{ this }} ), '1900-01-01')
        )
    {% endif %}
),

customers_and_locations_joined as (

    select * from {{ ref('int_customers_and_locations_joined') }}

),

employees as (

    select * from {{ ref('stg_tech_store__employees') }}

),

order_amounts_by_customer as (

    select * from {{ ref('int_order_amounts_agg_by_customer') }}

),

final as (

    select
        customers.customer_id,
        customers.customer_name,
        customers_and_locations_joined.city_name,
        customers_and_locations_joined.state_name,
        customers_and_locations_joined.zip_code,
        nvl(employees.full_name, 'None') as main_employee,
        employees.is_active as main_employee_is_active,
        nvl(order_amounts_by_customer.total_revenue_in_usd, 0) 
            as total_revenue_in_usd,
        nvl(order_amounts_by_customer.total_quantity, 0) as total_quantity,
        customers.created_at,
        customers.created_at_est, -- new
        customers.updated_at,
        customers.updated_at_est, -- new
        customers.is_active

    from customers

    left join customers_and_locations_joined
        on customers.customer_id = customers_and_locations_joined.customer_id
    
    left join employees
        on customers.main_employee_id = employees.employee_id

    left join order_amounts_by_customer
        on customers.customer_id = order_amounts_by_customer.customer_id

)

select * from final