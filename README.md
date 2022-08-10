# cdc_streaming
Concept implementing a near real-time streaming architecture with postgres, dbt and Materialize.

## Setup

```bash
git clone https://github.com/gabrielecorni/cdc_streaming.git
```

or, if you want to reproduce the initial phases:

```bash
mkdir cdc_streaming
cd cdc_streaming
poetry init
# < interactively define dependencies by adding dbt-materialize >
dbt init cdc_streaming
# < move folders back to root >
# < delete some folders if unnecessary >
poetry shell
```

> Note: remember to update your `~/.dbt/profiles.yml` file as well.

## TL;DR
Open 3 different shells at folder `cdc_streaming`, named: dbt, postgres, materialize

+ `$dbt> docker compose up -d`
+ `$postgres> docker exec -it cdc_streaming-db-1 bash`
+ `$materialize> docker run -it --rm --network=cdc_streaming_default materialize/cli`
+ `$dbt> dbt run`
+ `$postgres> (run some psql queries like)`
    + `INSERT INTO ...`
    + `UPDATE ...`
    + `DELETE FROM ...`
+ `$materialize> (run some psql queries like)`
    + `\dv`
    + `show sources;`
    + `show views;`
    + `show materialized views;`
    + `select * from ...`
+ `$dbt> docker compose down`

