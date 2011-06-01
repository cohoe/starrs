set search_path TO "public";

/*Schema firewall*/
CREATE SCHEMA "firewall";

/*Schema systems*/
CREATE SCHEMA "systems";

/*Schema dhcp*/
CREATE SCHEMA "dhcp";

/*Schema ip*/
CREATE SCHEMA "ip";

/*Schema dns*/
CREATE SCHEMA "dns";

/*Schema management*/
CREATE SCHEMA "management";

/*Schema network*/
CREATE SCHEMA "network";

/*Schema api*/
CREATE SCHEMA "api";

/*Sequence Output ID*/
CREATE SEQUENCE "management"."output_id_seq";

/*Language plperl*/
CREATE LANGUAGE "plperl";

/*Language plperlu*/
CREATE LANGUAGE "plperlu";

/*View Log - Master Debug*/
CREATE OR REPLACE VIEW "management"."log_master_debug" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'DEBUG';

COMMENT ON VIEW "management"."log_master_debug" IS 'View all DEBUG level data (all function calls and data)';

/*View Log - Master Info*/
CREATE OR REPLACE VIEW "management"."log_master_info" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'INFO';

COMMENT ON VIEW "management"."log_master_info" IS 'View all INFO level data (when something happens)';

/*View Log - Master Error*/
CREATE OR REPLACE VIEW "management"."log_master_error" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'ERROR';

COMMENT ON VIEW "management"."log_master_error" IS 'View all ERROR level data (there was an exception in some function)';