{{ config(materialized='sink') }}

CREATE SINK IF NOT EXISTS snk_usernames_policies
FROM {{ ref('usernames_policies') }}
INTO KAFKA BROKER 'kafka1:19092' TOPIC 'u08rmoa8-usernames-policies'
WITH (
    partition_count=1,
    replication_factor=1
)
FORMAT JSON