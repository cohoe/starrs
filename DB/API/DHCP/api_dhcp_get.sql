/* api_dhcp_get.sql
	1) get_dhcpd_static_hosts
	2) get_dhcpd_dynamic_hosts
	3) get_dhcpd_subnets
	4) get_dhcpd_subnet_options
	5) get_dhcpd_subnet_settings
	6) get_dhcpd_range_options
	7) get_dhcpd_range_settings
	8) get_dhcpd_ranges
*/

/* API - get_dhcpd_static_hosts */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_static_hosts"() RETURNS SETOF "dhcp"."dhcpd_static_hosts" AS $$
	BEGIN
		RETURN QUERY (SELECT "dns"."a"."hostname","dns"."a"."zone",
		"systems"."interface_addresses"."mac","systems"."interface_addresses"."address","systems"."systems"."owner",
		"systems"."interface_addresses"."class"
		FROM "systems"."interface_addresses"
		JOIN "dns"."a" ON "dns"."a"."address" = "systems"."interface_addresses"."address"
		JOIN "systems"."interfaces" ON "systems"."interfaces"."mac" = "systems"."interface_addresses"."mac"
		JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
		WHERE "systems"."interface_addresses"."config"='dhcp'
		AND NOT "systems"."interface_addresses"."address" << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET'))));
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_static_hosts"() IS 'Get all information for a host block of the dhcpd.conf file';

/* API - get_dhcpd_dynamic_hosts */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_dynamic_hosts"() RETURNS SETOF "dhcp"."dhcpd_dynamic_hosts" AS $$
	BEGIN
		RETURN QUERY (SELECT "dns"."a"."hostname","dns"."a"."zone",
		"systems"."interface_addresses"."mac","systems"."systems"."owner","systems"."interface_addresses"."class"
		FROM "systems"."interface_addresses"
		JOIN "dns"."a" ON "dns"."a"."address" = "systems"."interface_addresses"."address"
		JOIN "systems"."interfaces" ON "systems"."interfaces"."mac" = "systems"."interface_addresses"."mac"
		JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
		WHERE "systems"."interface_addresses"."config"='dhcp'
		AND "systems"."interface_addresses"."address" << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET'))));
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_dynamic_hosts"() IS 'Get all information for a host block of the dhcpd.conf file';

/* API - get_dhcpd_subnets */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_subnets"() RETURNS SETOF CIDR AS $$
	BEGIN
		RETURN QUERY (SELECT "subnet" FROM "ip"."subnets" WHERE "dhcp_enable" = TRUE AND family("subnet") = 4);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_subnets"() IS 'Get a list of all DHCP enabled subnets for DHCPD';

/* API - get_dhcpd_subnet_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_subnet_options"(input_subnet cidr) RETURNS SETOF "dhcp"."dhcpd_subnet_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."subnet_options" WHERE "subnet" = input_subnet);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_subnet_options"(cidr) IS 'Get all subnet options for dhcpd.conf';

/* API - get_dhcpd_subnet_settings */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_subnet_settings"(input_subnet cidr) RETURNS SETOF "dhcp"."dhcpd_subnet_settings" AS $$
	BEGIN
		RETURN QUERY (SELECT "setting","value" FROM "dhcp"."subnet_settings" WHERE "subnet" = input_subnet);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_subnet_settings"(cidr) IS 'Get all subnet settings for dhcpd.conf';

/* API - get_dhcpd_range_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_range_options"(input_range text) RETURNS SETOF "dhcp"."dhcpd_range_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."range_options" WHERE "name" = input_range);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_range_options"(text) IS 'Get all range options for dhcpd.conf';

/* API - get_dhcpd_range_settings */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_range_settings"(input_range text) RETURNS SETOF "dhcp"."dhcpd_range_settings" AS $$
	BEGIN
		RETURN QUERY (SELECT "setting","value" FROM "dhcp"."range_settings" WHERE "name" = input_range);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_range_settings"(text) IS 'Get all range settings for dhcpd.conf';

/* API - get_dhcpd_subnet_ranges */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_subnet_ranges"(input_subnet cidr) RETURNS SETOF "dhcp"."dhcpd_subnet_ranges" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","first_ip","last_ip","class" FROM "ip"."ranges" WHERE "subnet" = input_subnet AND "use" = 'ROAM');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_subnet_ranges"(cidr) IS 'Get a list of all dynamic ranges in a subnet';