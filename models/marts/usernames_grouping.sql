{{ config(materialized='materializedview') }}

select
    codsog,
    count(*) as nb_policies
from
    {{ ref('user_policies') }}
group by
    codsog