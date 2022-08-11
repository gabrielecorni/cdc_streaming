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

## Example of interaction

Within `postgres` shell (`docker exec -it cdc_streaming-db-1 bash`):

1. login to the `datalake` db (`psql -U postgres -d datalake`)
2. execute the following SQL statements:
```bash
datalake=# INSERT INTO SOURCE.USERS(ID, NAME, SURNAME) VALUES
datalake-# (4, 'CAIO', 'MARIO');
INSERT 0 1
datalake=# INSERT INTO SOURCE.POLICIES(ID, POLICY_DETAILS, USER_ID) VALUES
datalake-# (5672, 'ANTI THEFT', 4),
datalake-# (5559, 'MOTO INSURANCE', 4);
INSERT 0 2
datalake=# UPDATE SOURCE.POLICIES SET POLICY_DETAILS='HOME INSURANCE' WHERE ID = 5559;
UPDATE 1
datalake=# DELETE FROM SOURCE.POLICIES WHERE ID=5559;
DELETE 1
datalake=# DELETE FROM SOURCE.USERS WHERE ID=4;
DELETE 1
```

The correspondent Kafka messages on topics are:
+ usernames_grouping
```json
[
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 1,
        "nb_policies": 2
      }
    }
  },
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 3,
        "nb_policies": 1
      }
    }
  },
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 4,
        "nb_policies": 2
      }
    }
  },
  {
    "before": {
      "row": {
        "codsog": 4,
        "nb_policies": 2
      }
    },
    "after": {
      "row": {
        "codsog": 4,
        "nb_policies": 1
      }
    }
  },
  {
    "before": {
      "row": {
        "codsog": 4,
        "nb_policies": 1
      }
    },
    "after": null
  }
]
```
+ usernames_policies
```json
[
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 3,
        "username": "CARLOVERDI",
        "codpol": 5555,
        "policy_details": "CAR INSURANCE"
      }
    }
  },
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 1,
        "username": "MARIOROSSI",
        "codpol": 1234,
        "policy_details": "HOME INSURANCE"
      }
    }
  },
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 1,
        "username": "MARIOROSSI",
        "codpol": 5678,
        "policy_details": "ANTI THEFT"
      }
    }
  },
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 4,
        "username": "CAIOMARIO",
        "codpol": 5672,
        "policy_details": "ANTI THEFT"
      }
    }
  },
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 4,
        "username": "CAIOMARIO",
        "codpol": 5559,
        "policy_details": "MOTO INSURANCE"
      }
    }
  },
  {
    "before": {
      "row": {
        "codsog": 4,
        "username": "CAIOMARIO",
        "codpol": 5559,
        "policy_details": "MOTO INSURANCE"
      }
    },
    "after": null
  },
  {
    "before": null,
    "after": {
      "row": {
        "codsog": 4,
        "username": "CAIOMARIO",
        "codpol": 5559,
        "policy_details": "HOME INSURANCE"
      }
    }
  },
  {
    "before": {
      "row": {
        "codsog": 4,
        "username": "CAIOMARIO",
        "codpol": 5559,
        "policy_details": "HOME INSURANCE"
      }
    },
    "after": null
  },
  {
    "before": {
      "row": {
        "codsog": 4,
        "username": "CAIOMARIO",
        "codpol": 5672,
        "policy_details": "ANTI THEFT"
      }
    },
    "after": null
  }
]
```