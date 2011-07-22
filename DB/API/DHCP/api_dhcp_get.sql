/* api_dhcp_get.sql
	1) get_dhcpd_static_hosts
	2) get_dhcpd_dynamic_hosts
	3) get_dhcpd_subnets
	4) get_dhcpd_subnet_options
	5) get_dhcpd_subnet_settings
	6) get_dhcpd_range_options
	7) get_dhcpd_range_settings
	8) get_dhcpd_ranges
	9) get_dhcpd_global_options
	10) get_dhcpd_dns_keys
	11) get_dhcpd_forward_zones
	12) get_dhcpd_reverse_zones
	13) get_dhcpd_classes
	14) get_dhcpd_class_options
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

/* API - get_dhcpd_range_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_range_options"(input_range text) RETURNS SETOF "dhcp"."dhcpd_range_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."range_options" WHERE "name" = input_range);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_range_options"(text) IS 'Get all range options for dhcpd.conf';

/* API - get_dhcpd_subnet_ranges */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_subnet_ranges"(input_subnet cidr) RETURNS SETOF "dhcp"."dhcpd_subnet_ranges" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","first_ip","last_ip","class" FROM "ip"."ranges" WHERE "subnet" = input_subnet AND "use" = 'ROAM' AND family("subnet") = 4);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_subnet_ranges"(cidr) IS 'Get a list of all dynamic ranges in a subnet';

/* API - get_dhcpd_global_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_global_options"() RETURNS SETOF "dhcp"."dhcpd_global_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."global_options");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_global_options"() IS 'Get all of the global DHCPD config directives';

/* API - get_dhcpd_dns_keys */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_dns_keys"() RETURNS SETOF "dhcp"."dhcpd_dns_keys" AS $$
	BEGIN
		RETURN QUERY (SELECT DISTINCT "dns"."zones"."keyname","dns"."keys"."key",api.get_site_configuration('DNS_KEY_ENCTYPE') AS "enctype" 
		FROM "ip"."subnets" 
		JOIN "dns"."zones" ON "dns"."zones"."zone" = "ip"."subnets"."zone" 
		JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname" 
		WHERE "dhcp_enable" = TRUE);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_dns_keys"() IS 'Get all of the dns keys for dhcpd';

/* API - get_dhcpd_forward_zones */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_forward_zones"() RETURNS SETOF "dhcp"."dhcpd_zones" AS $$
	BEGIN
		RETURN QUERY (SELECT DISTINCT "ip"."subnets"."zone","dns"."zones"."keyname","address" FROM "ip"."subnets"
		JOIN "dns"."zones" ON "dns"."zones"."zone" = "ip"."subnets"."zone" 
		JOIN "dns"."ns" ON "dns"."zones"."zone" = "dns"."ns"."zone" 
		WHERE "isprimary" = TRUE);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_forward_zones"() IS 'Get all forward zone info for dhcpd';

/* API - get_dhcpd_reverse_zones */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_reverse_zones"() RETURNS SETOF "dhcp"."dhcpd_zones" AS $$
	BEGIN
		RETURN QUERY (SELECT DISTINCT api.get_reverse_domain("subnet") AS "zone","dns"."zones"."keyname","address" FROM "ip"."subnets"
		JOIN "dns"."zones" ON "dns"."zones"."zone" = "ip"."subnets"."zone" 
		JOIN "dns"."ns" ON "dns"."zones"."zone" = "dns"."ns"."zone" 
		WHERE "isprimary" = TRUE AND "dhcp_enable" = TRUE AND family("subnet") = 4);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_reverse_zones"() IS 'Get all reverse zone info for dhcpd';

/* API - get_dhcpd_classes */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_classes"() RETURNS SETOF "dhcp"."dhcpd_classes" AS $$
	BEGIN
		RETURN QUERY (SELECT "class","comment" FROM "dhcp"."classes");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_classes"() IS 'Get class information for the dhcpd.conf file';

/* API - get_dhcpd_class_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_class_options"(input_class text) RETURNS SETOF "dhcp"."dhcpd_class_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."class_options" WHERE "class" = input_class);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_class_options"(text) IS 'Get class options for the dhcpd.conf file';

/* API - get_dhcp_classes*/
CREATE OR REPLACE FUNCTION "api"."get_dhcp_classes"() RETURNS SETOF "dhcp"."class_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "class","comment","date_created","date_modified","last_modifier" FROM "dhcp"."classes");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_classes"() IS 'Get all DHCP class information';

/* API - get_dhcp_config_types */
CREATE OR REPLACE FUNCTION "api"."get_dhcp_config_types"(input_family integer) RETURNS SETOF "dhcp"."config_type_data" AS $$
	BEGIN
		IF input_family IS NULL THEN
			RETURN QUERY (SELECT "config","family","comment","date_created","date_modified","last_modifier" FROM "dhcp"."config_types");
		ELSE
			RETURN QUERY (SELECT * FROM "dhcp"."config_types" WHERE "family" = input_family);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_config_types"(integer) IS 'Get all DHCP config information';