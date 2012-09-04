/* api_dhcp_remove.sql
	1) remove_dhcp_class
	2) remove_dhcp_class_option
	3) remove_dhcp_subnet_option
	4) remove_dhcp_global_option
*/

/* API - remove_dhcp_class
	1) Check privileges
	2) Remove class
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_class"(input_class text) RETURNS VOID AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp class denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Remove class
		DELETE FROM "dhcp"."classes" WHERE "class" = input_class;

		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_class"(text) IS 'Delete an existing DHCP class';

/* API - remove_dhcp_class_option
	1) Check privileges
	2) Remove class option
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_class_option"(input_class text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp class option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Remove class option		
		DELETE FROM "dhcp"."class_options"
		WHERE "class" = input_class AND "option" = input_option AND "value" = input_value;

		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_class_option"(text, text, text) IS 'Delete an existing DHCP class option';

/* API - remove_dhcp_subnet_option
	1) Check privileges
	2) Remove subnet option
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_subnet_option"(input_subnet cidr, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp subnet option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Delete subnet option		
		DELETE FROM "dhcp"."subnet_options"
		WHERE "subnet" = input_subnet AND "option" = input_option AND "value" = input_value;

		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_subnet_option"(cidr, text, text) IS 'Delete an existing DHCP subnet option';

/* API - remove_dhcp_global_option
	1) Check privileges
	2) Remove global option
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_global_option"(input_option text, input_value text) RETURNS VOID AS $$
	BEGIN

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp global option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Delete global option		
		DELETE FROM "dhcp"."global_options"
		WHERE "option" = input_option AND "value" = input_value;

		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_global_option"(text, text) IS 'Delete an existing DHCP global option';

/* API - remove_dhcp_range_option
	1) Check privileges
	2) Remove range option
*/
CREATE OR REPLACE FUNCTION "api"."remove_dhcp_range_option"(input_range text, input_option text, input_value text) RETURNS VOID AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp range option denied for %. Not admin.',api.get_current_user();
		END IF;

		-- Remove range option		
		DELETE FROM "dhcp"."range_options"
		WHERE "name" = input_range AND "option" = input_option;

		-- Done
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_range_option"(text, text, text) IS 'Delete an existing DHCP range option';

CREATE OR REPLACE FUNCTION "api"."remove_dhcp_network"(input_name text) RETURNS VOID AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp network denied for %. Not admin.',api.get_current_user();
		END IF;

		DELETE FROM "dhcp"."networks" WHERE "name" = input_name;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_network"(text) IS 'Remove a dhcp network';

CREATE OR REPLACE FUNCTION "api"."remove_dhcp_network_subnet"(input_name text, input_subnet cidr) RETURNS VOID AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Permission to remove dhcp network subnet denied for %. Not admin.',api.get_current_user();
		END IF;

		DELETE FROM "dhcp"."network_subnets" WHERE "name" = input_name AND "subnet" = input_subnet;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dhcp_network_subnet"(text, cidr) IS 'Remove a dhcp network subnet';
