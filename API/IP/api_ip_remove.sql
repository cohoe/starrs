/* api_ip_remove.sql
	1) remove_subnet
	2) remove_ip_range
*/

/* API - remove_ip_subnet
	1) Check privileges
	2) Delete RDNS zone
	3) Delete subnet record
*/
CREATE OR REPLACE FUNCTION "api"."remove_ip_subnet"(input_subnet cidr) RETURNS VOID AS $$
	DECLARE
		RowCount INTEGER;
		WasAuto BOOLEAN;
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "ip"."subnets" WHERE "subnet" = input_subnet) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to delete subnet % denied. Not owner',input_subnet;
			END IF;
		END IF;

		-- Delete RDNS zone
		PERFORM api.remove_dns_zone(api.get_reverse_domain(input_subnet));

		-- Delete subnet
		DELETE FROM "ip"."subnets" WHERE "subnet" = input_subnet;

		-- Done
		PERFORM api.syslog('remove_ip_subnet:"'||input_subnet||'"');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_ip_subnet"(cidr) IS 'Delete/deactivate an existing subnet';

/* API - remove_ip_range
	1) Check privileges
	2) Delete range
*/
CREATE OR REPLACE FUNCTION "api"."remove_ip_range"(input_name text) RETURNS VOID AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "ip"."subnets" WHERE "subnet" = 
			(SELECT "subnet" FROM "ip"."ranges" WHERE "name" = input_range)) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to delete range % denied. Not owner',input_name;
			END IF;
		END IF;

		-- Delete range		
		DELETE FROM "ip"."ranges" WHERE "name" = input_name;

		-- Done
		PERFORM api.syslog('remove_ip_range:"'||input_name||'"');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_ip_range"(text) IS 'Delete an existing IP range';

CREATE OR REPLACE FUNCTION "api"."remove_range_group"(input_range text, input_group text) RETURNS VOID AS $$
	BEGIN
		-- Privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Only admins can assign range resources to groups';
		END IF;

		-- Remove
		DELETE FROM "ip"."range_groups" WHERE "range_name" = input_range AND "group_name" = input_group;

		-- Done
		PERFORM api.syslog('remove_range_group:"'||input_range||'","'||input_group||'"');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_range_group"(text, text) IS 'Remove a range group';
