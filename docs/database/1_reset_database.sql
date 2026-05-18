-- Drops the entire nutrionista schema and everything in it.
-- WARNING: destroys all data. Only run in dev/local environments.
DROP SCHEMA IF EXISTS nutrionista CASCADE;

-- Recreate the schema (empty) with the right grants.
CREATE SCHEMA nutrionista;
GRANT ALL ON SCHEMA nutrionista TO postgres;
GRANT ALL ON SCHEMA nutrionista TO PUBLIC;

-- Force subsequent statements (in this same psql session) to default to nutrionista.
SET search_path TO nutrionista;