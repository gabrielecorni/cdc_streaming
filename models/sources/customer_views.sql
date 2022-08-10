{{ config(materialized='source') }}

CREATE VIEWS FROM SOURCE {{ source('customer_data', 'customer_data_raw') }}
(source.users AS users, source.policies as policies)