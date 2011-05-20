/*Trigger Function API - create_subnet*/
CREATE OR REPLACE FUNCTION "api"."create_subnet"(input_subnet cidr, input_name text, input_comment text, input_autogen boolean) RETURNS VOID AS $$
	DECLARE
		RowCount	INTEGER;
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_subnet');
		input_subnet := api.sanitize_general(input_subnet);
		input_name := api.sanitize_general(input_name);
		input_comment := api.sanitize_general(input_comment);
		input_autogen  := api.sanitize_general(input_autogen);

		SELECT api.create_log_entry('API', 'INFO', 'creating new subnet');
		INSERT INTO "ip"."subnets" 
			("subnet","name","comment","autogen","last_modifier") VALUES
			(input_subnet,input_name,input_comment,input_autogen,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_subnet"() IS 'Create/activate a new subnet';

/*Trigger Function API - delete_subnet*/
CREATE OR REPLACE FUNCTION "api"."delete_subnet"(input_subnet cidr) RETURNS VOID AS $$
	DECLARE
		RowCount	INTEGER;
		WasAuto		BOOLEAN;
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_subnet');
		input_subnet := api.sanitize_general(input_subnet);

		SELECT api.create_log_entry('API', 'INFO', 'Deleting subnet');
		DELETE FROM "ip"."subnets" WHERE "subnet" = input_subnet;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."delete_subnet"() IS 'Delete/deactivate an existing subnet';

/*Trigger Function API - create_ip_range*/
CREATE OR REPLACE FUNCTION "api"."create_ip_range"(input_first_ip inet, input_last_ip inet, input_subnet cidr, input_use varchar(4), input_comment text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.create_ip_range');
		input_first_ip := api.sanitize_general(input_first_ip);
		input_last_ip := api.sanitize_general(input_last_ip);
		input_subnet := api.sanitize_general(input_subnet);
		input_use := api.sanitize_general(input_use);
		input_comment := api.sanitize_general(input_comment);
		
		SELECT api.create_log_entry('API', 'INFO', 'creating new range');
		INSERT INTO "ip"."ranges" 
		("first_ip", "last_ip", "subnet", "use", "comment", "last_modifier")
		VALUES (input_first_ip,input_last_ip,input_subnet,input_use,input_comment,api.get_current_user());
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_ip_range"() IS 'Create a new range of IP addresses';

/*Trigger Function API - delete_ip_range*/
CREATE OR REPLACE FUNCTION "api"."delete_ip_range"(input_first_ip inet, input_last_ip inet) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API', 'DEBUG', 'Begin api.delete_ip_range');
		input_first_ip := api.sanitize_general(input_first_ip);
		input_last_ip := api.sanitize_general(input_last_ip);
		SELECT api.create_log_entry('API', 'INFO', 'Deleting range');
		DELETE FROM "ip"."ranges" WHERE "first_ip" = input_first_ip AND "last_ip" = input_last_ip;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."delete_ip_range"() IS 'Delete an existing IP range';