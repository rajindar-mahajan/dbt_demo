{% macro usd_to_gbp(column_name) -%}
ROUND({{ column_name }} / 1.2, 2)
{%- endmacro %}