/* API - remove_subnet
	1) Check privileges
	2) Delete RDNS zone
	3) Delete subnet record
*/
CREATE OR REPLACE FUNCTION "api"."remove_subnet"(input_subnet cidr) RETURNS VOID AS $$
	DECLARE
		RowCount INTEGER;
		WasAuto BOOLEAN;
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_subnet');

		-- Delete RDNS zone
		PERFORM api.create_log_entry('API', 'INFO', 'removing rdns zone for subnet');
		PERFORM api.remove_dns_zone(api.get_reverse_domain(input_subnet));

		-- Delete subnet
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting subnet');
		DELETE FROM "ip"."subnets" WHERE "subnet" = input_subnet;

		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_subnet');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_subnet"(cidr) IS 'Delete/deactivate an existing subnet';

/* API - remove_ip_range
	1) Check privileges
	2) Delete range
*/
CREATE OR REPLACE FUNCTION "api"."remove_ip_range"(input_name text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_ip_range');
		
		-- Delete range		
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting range');
		DELETE FROM "ip"."ranges" WHERE "name" = input_name;

		PERFORM api.create_log_entry('API', 'DEBUG', 'Finish api.remove_ip_range');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_ip_range"(text) IS 'Delete an existing IP range';
