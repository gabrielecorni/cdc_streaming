{{ config(materialized='view') }}

with source_data as (
    select
        p.id as codpol,
        u.id as codsog,
        u.surname,
        u.name,
        p.policy_details
    from
        {{ source('customer_views', 'users') }} u inner join {{ source('customer_views', 'policies') }} p on u.id = p.user_id
)

select *
from source_data