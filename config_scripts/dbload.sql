-- script to be executed on source PostgreSql database to setup CDC for replicated tables
-- in this example, it will be created a custom database and a custom schema to work with
-- ref: https://materialize.com/docs/integrations/cdc-postgres/#direct-postgres-source

-- source database
-- created at docker-compose level, named "datalake"
-- remember to run it with wal_level=logical (done at docker-compose level as well)

-- source schema (connect to source db first to create it there)
\c datalake postgres;
CREATE SCHEMA SOURCE;
ALTER ROLE "postgres" WITH REPLICATION;

-- source tables
CREATE TABLE SOURCE.USERS(
  ID INT NOT NULL PRIMARY KEY,
  NAME VARCHAR(200),
  SURNAME VARCHAR(200)
);
ALTER TABLE SOURCE.USERS REPLICA IDENTITY FULL;

CREATE TABLE SOURCE.POLICIES(
  ID INT NOT NULL PRIMARY KEY,
  POLICY_DETAILS VARCHAR(200),
  USER_ID INT
);
ALTER TABLE SOURCE.POLICIES REPLICA IDENTITY FULL;

-- source publication
CREATE PUBLICATION mz_source FOR TABLE SOURCE.USERS, SOURCE.POLICIES;

-- initial data (after the publication)
INSERT INTO SOURCE.USERS(ID, NAME, SURNAME) VALUES
    (1, 'MARIO', 'ROSSI'),
    (2, 'PINA', 'BRUNI'),
    (3, 'CARLO', 'VERDI')
;
INSERT INTO SOURCE.POLICIES(ID, POLICY_DETAILS, USER_ID) VALUES
    (1234, 'HOME INSURANCE', 1),
    (5678, 'ANTI THEFT', 1),
    (5555, 'CAR INSURANCE', 3)
;

-- check everything's fine on source postgres db
-- psql -U postgres -d datalake
-- show wal_level;
-- select * from pg_publication;