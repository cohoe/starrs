/* API - create_switchport
	1) Sanitize input
	2) Check privileges
	3) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."create_switchport"(input_port_name text, input_system_name text, input_port_type text, input_description text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_switchport');
		
		-- Sanitize input
		input_port_name := api.sanitize_general(input_port_name);
		input_system_name := api.sanitize_general(input_system_name);
		input_port_type := api.sanitize_general(input_port_type);
		input_description := api.sanitize_general(input_description);
		
		-- Create directive
		PERFORM api.create_log_entry('API','INFO','creating switchport');
		INSERT INTO "network"."switchports" ("port_name","system_name","type","description") VALUES 
		(input_port_name, input_system_name, input_port_type, input_description);
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_switchport');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_switchport"(text, text, text, text) IS 'Create a new network switchport';

/* API - remove_switchport
	1) Sanitize input
	2) Check privileges
	3) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."remove_switchport"(input_port_name text, input_system_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_switchport');
		
		-- Sanitize input
		input_port_name := api.sanitize_general(input_port_name);
		input_system_name := api.sanitize_general(input_system_name);
		
		-- Create directive
		PERFORM api.create_log_entry('API','INFO','removing switchport');
		DELETE FROM "network"."switchports" WHERE "port_name" = input_port_name AND "system_name" = input_system_name;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_switchport');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_switchport"(text, text) IS 'Remove a network switchport';

/* API - create_switchport_range
	1) Sanitize input
	2) Check privileges
	3) Create ports
*/
CREATE OR REPLACE FUNCTION "api"."create_switchport_range"(input_prefix text, first_port integer, last_port integer, input_system_name text, input_port_type text, input_description text) RETURNS VOID AS $$
	DECLARE
		Counter INTEGER;
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.create_switchport_range');

		-- Sanitize input
		input_prefix := api.sanitize_general(input_prefix);
		input_system_name := api.sanitize_general(input_system_name);
		input_port_type := api.sanitize_general(input_port_type);
		input_description := api.sanitize_general(input_description);
		Counter := first_port;

		-- Create ports
		PERFORM api.create_log_entry('API','INFO','creating lots of switchports');
		WHILE Counter != last_port + 1 LOOP
			PERFORM api.create_switchport(input_prefix||Counter, input_system_name, input_port_type, input_description);
			Counter := Counter + 1;
		END LOOP;
		
		PERFORM api.create_log_entry('API','DEBUG','finish api.create_switchport_range');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_switchport_range"(text, integer, integer, text, text, text) IS 'Create a range of switchports';