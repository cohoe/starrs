/*View Log - Master Debug*/
CREATE OR REPLACE VIEW "management"."log_master_debug" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'DEBUG';

COMMENT ON VIEW "management"."log_master_debug" IS 'View all DEBUG level data (all function calls and data)';

/*View Log - Master Info*/
CREATE OR REPLACE VIEW "management"."log_master_info" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'INFO';

COMMENT ON VIEW "management"."log_master_info" IS 'View all INFO level data (when something happens)';

/*View Log - Master Error*/
CREATE OR REPLACE VIEW "management"."log_master_error" AS SELECT * FROM "management"."log_master" WHERE "severity" LIKE 'ERROR';

COMMENT ON VIEW "management"."log_master_error" IS 'View all ERROR level data (there was an exception in some function)';