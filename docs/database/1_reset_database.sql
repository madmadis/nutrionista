-- Kustutab public schema (mis põhimõtteliselt kustutab kõik tabelid)
DROP SCHEMA IF EXISTS nutrionista CASCADE;
-- Loob uue public schema vajalikud õigused
CREATE SCHEMA nutrionista
-- taastab vajalikud andmebaasi õigused
    GRANT ALL ON SCHEMA nutrionista TO postgres;
GRANT ALL ON SCHEMA nutrionista TO PUBLIC;