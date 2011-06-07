/* API - remove_switchport
	1) Check privileges
	2) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."remove_switchport"(input_port_name text, input_system_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_switchport');

		-- Check privileges
		IF api.get_current_user_level() ~* 'USER|PROGRAM' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on system %. You are not owner.',input_system_name;
			END IF;
		END IF;

		-- Create directive
		PERFORM api.create_log_entry('API','INFO','removing switchport');
		DELETE FROM "network"."switchports" WHERE "port_name" = input_port_name AND "system_name" = input_system_name;

		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_switchport');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_switchport"(text, text) IS 'Remove a network switchport';

/* API - remove_switchport_range
	1) Validate input
	2) Check privileges
	3) Remove ports
*/
CREATE OR REPLACE FUNCTION "api"."remove_switchport_range"(input_prefix text, first_port integer, last_port integer, input_system_name text) RETURNS VOID AS $$
	DECLARE
		Counter INTEGER;
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_switchport_range');

		-- Validate input
		Counter := first_port;

		-- Check privileges
		IF api.get_current_user_level() ~* 'USER|PROGRAM' THEN
			IF (SELECT "owner" FROM "systems"."systems" WHERE "system_name" = input_system_name) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission denied on system %. You are not owner.',input_system_name;
			END IF;
		END IF;

		-- Remove ports
		PERFORM api.create_log_entry('API','INFO','removing lots of switchports');
		WHILE Counter != last_port + 1 LOOP
			PERFORM api.remove_switchport(input_prefix||Counter, input_system_name);
			Counter := Counter + 1;
		END LOOP;

		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_switchport_range');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_switchport_range"(text, integer, integer, text) IS 'Remove a range of switchports from a system';