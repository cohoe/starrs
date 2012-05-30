/* api_management_utility
	1) validate_nospecial
	2) validate_name
	3) renew_system
	4) lock_process
	5) unlock_process
	6) intialize
	7) deinitialize
	8) reset_database
	9) exec
*/

/* API - validate_nospecial */
CREATE OR REPLACE FUNCTION "api"."validate_nospecial"(input text) RETURNS TEXT AS $$
	DECLARE
		BadCrap TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9]*', '', 'gi');
		IF BadCrap != '' THEN
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		RETURN input;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."validate_nospecial"(text) IS 'Block all special characters';

/* API - validate_name */
CREATE OR REPLACE FUNCTION "api"."validate_name"(input text) RETURNS TEXT AS $$
	DECLARE
		BadCrap TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\:\_\/ ]*\-*', '', 'gi');
		IF BadCrap != '' THEN
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		IF input = '' THEN
			RAISE EXCEPTION 'Name cannot be blank';
		END IF;
		RETURN input;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."validate_name"(text) IS 'Allow certain characters for names';

/* API - renew_system
	1) Check privileges
	2) Renew system
*/
CREATE OR REPLACE FUNCTION "api"."renew_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.renew_system');

		-- Check privileges
		IF api.get_current_user_level() ~* 'PROGRAM|USER' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied. Only admins can create site directives';
			END IF;
		END IF;

		-- Renew system
		PERFORM api.create_log_entry('API','INFO','renewing system');
		UPDATE "systems"."systems" SET "renew_date" = date(current_date + interval '1 year');

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.renew_system');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."renew_system"(text) IS 'Renew a registered system for the next year';

/* API - lock_process
	1) Check privileges
	2) Get current status
	3) Update status
*/
CREATE OR REPLACE FUNCTION "api"."lock_process"(input_process text) RETURNS VOID AS $$
	DECLARE
		Status BOOLEAN;
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.lock_process');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can control processes';
		END IF;

		-- Get current status
		SELECT "locked" INTO Status
		FROM "management"."processes"
		WHERE "management"."processes"."process" = input_process;
		IF Status IS TRUE THEN
			RAISE EXCEPTION 'Process is locked';
		END IF;

		-- Update status
		PERFORM api.create_log_entry('API','INFO','locking process '||input_process);
		UPDATE "management"."processes" SET "locked" = TRUE WHERE "management"."processes"."process" = input_process;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.lock_process');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."lock_process"(text) IS 'Lock a process for a job';

/* API - unlock_process
	1) Check privileges
	2) Update status
*/
CREATE OR REPLACE FUNCTION "api"."unlock_process"(input_process text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.unlock_process');

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can control processes';
		END IF;

		-- Update status
		PERFORM api.create_log_entry('API','INFO','unlocking process '||input_process);
		UPDATE "management"."processes" SET "locked" = FALSE WHERE "management"."processes"."process" = input_process;

		-- Done
		PERFORM api.create_log_entry('API','DEBUG','finish api.unlock_process');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."unlock_process"(text) IS 'Unlock a process for a job';

/* API - initialize
	1) Get level
	2) Create privilege table
	3) Populate privileges
	4) Set level
*/
CREATE OR REPLACE FUNCTION "api"."initialize"(input_username text) RETURNS TEXT AS $$
	DECLARE
		Level TEXT;
	BEGIN
		-- Get level
		SELECT api.get_ldap_user_level(input_username) INTO Level;
		--IF input_username ~* 'cohoe|clockfort|russ|dtyler|worr|benrr101' THEN
			--Level := 'ADMIN';
		--ELSE
			--Level := 'USER';
		--END IF;
		IF Level='NONE' THEN
			RAISE EXCEPTION 'Could not identify "%".',input_username;
		END IF;

		-- Create privilege table
		DROP TABLE IF EXISTS "user_privileges";

		CREATE TEMPORARY TABLE "user_privileges"
		(username text NOT NULL,privilege text NOT NULL,
		allow boolean NOT NULL DEFAULT false);

		-- Populate privileges
		INSERT INTO "user_privileges" VALUES (input_username,'USERNAME',TRUE);
		INSERT INTO "user_privileges" VALUES (input_username,'ADMIN',FALSE);
		INSERT INTO "user_privileges" VALUES (input_username,'PROGRAM',FALSE);
		INSERT INTO "user_privileges" VALUES (input_username,'USER',FALSE);
		ALTER TABLE "user_privileges" ALTER COLUMN "username" SET DEFAULT api.get_current_user();

		-- Set level
		UPDATE "user_privileges" SET "allow" = TRUE WHERE "privilege" = Level;

		PERFORM api.create_log_entry('API','INFO','User "'||input_username||'" ('||Level||') has successfully initialized.');
		RETURN 'Greetings '||lower(Level)||'!';
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."initialize"(text) IS 'Setup user access to the database';

/* API - deinitialize */
CREATE OR REPLACE FUNCTION "api"."deinitialize"() RETURNS VOID AS $$
	BEGIN
		DROP TABLE IF EXISTS "user_privileges";
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."deinitialize"() IS 'Reset user permissions to activate a new user';

/* API - reset_database */
CREATE OR REPLACE FUNCTION "api"."reset_database"() RETURNS VOID AS $$
	DECLARE
		tables RECORD;
	BEGIN
		FOR tables IN (SELECT "table_schema","table_name" 
		FROM "information_schema"."tables" 
		WHERE "table_schema" !~* 'information_schema|pg_catalog'
		AND "table_type" ~* 'BASE TABLE'
		ORDER BY "table_schema" ASC) LOOP
			PERFORM (SELECT api.exec('DROP TABLE '||tables.table_schema||'.'||tables.table_name||' CASCADE'));
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
ALTER FUNCTION api.reset_database() OWNER TO impulse_admin;
GRANT EXECUTE ON FUNCTION api.initialize(text) TO impulse_admin;
REVOKE ALL PRIVILEGES ON FUNCTION api.reset_database() FROM public;

COMMENT ON FUNCTION "api"."reset_database"() IS 'Drop all tables to reset the database to only functions';

/* API - exec */
CREATE OR REPLACE FUNCTION "api"."exec"(text) RETURNS VOID AS $$
	BEGIN
		EXECUTE $1;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."exec"(text) IS 'Execute a query in a plpgsql context';
