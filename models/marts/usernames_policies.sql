{{ config(materialized='materializedview') }}

select
    codsog,
    concat(name, surname) as username,
    codpol,
    policy_details
from
    {{ ref('user_policies') }}