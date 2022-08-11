{{ config(materialized='sink') }}

CREATE SINK IF NOT EXISTS snk_usernames_grouping
FROM {{ ref('usernames_grouping') }}
INTO KAFKA BROKER 'kafka1:19092' TOPIC 'u08rmoa8-usernames-grouping'
WITH (
    partition_count=1,
    replication_factor=1
)
FORMAT JSON