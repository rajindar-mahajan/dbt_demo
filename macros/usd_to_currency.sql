{% macro usd_to_currency(column_name, to_currency) -%}
    {% set return_exchange_rate_query %}
    select exchange_rate_to_usd from {{ ref('exchange_rate_to_usd') }}
    where to_currency = '{{ to_currency }}'
    {% endset %}

    {% set results = run_query(return_exchange_rate_query) %}

    {% if execute %}
    {# Return the first column #}
    {% set exchange_rate_to_usd = results[0][0] %}
    {% else %}
    {% set exchange_rate_to_usd = [] %}
    {% endif %}
    ROUND({{ column_name }} / {{ exchange_rate_to_usd }}, 2)
{%- endmacro %}