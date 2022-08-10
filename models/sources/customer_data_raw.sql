{{ config(materialized='source') }}

{% set source_name %}
    {{ mz_generate_name('customer_data_raw') }}
{% endset %}

CREATE MATERIALIZED SOURCE IF NOT EXISTS {{ source_name }}
FROM POSTGRES
CONNECTION 'host=cdc_streaming-db-1 port=5432 user=postgres password=postgres dbname=datalake'
PUBLICATION 'mz_source'