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
		LEFT JOIN "dns"."a" ON "dns"."a"."address" = "systems"."interface_addresses"."address"
		JOIN "systems"."interfaces" ON "systems"."interfaces"."mac" = "systems"."interface_addresses"."mac"
		JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
		WHERE "systems"."interface_addresses"."config"='dhcp'
		AND NOT "systems"."interface_addresses"."address" << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET')))
		AND ("dns"."a"."zone" IN (SELECT DISTINCT "zone" FROM "ip"."subnets" WHERE "dhcp_enable" IS TRUE ORDER BY "zone")
		OR "dns"."a"."zone" IS NULL) ORDER BY "systems"."systems"."owner");	
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_static_hosts"() IS 'Get all information for a host block of the dhcpd.conf file';

/* API - get_dhcpd_dynamic_hosts */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_dynamic_hosts"() RETURNS SETOF "dhcp"."dhcpd_dynamic_hosts" AS $$
	BEGIN
		RETURN QUERY (SELECT "dns"."a"."hostname","dns"."a"."zone",
		"systems"."interface_addresses"."mac","systems"."systems"."owner","systems"."interface_addresses"."class"
		FROM "systems"."interface_addresses"
		LEFT JOIN "dns"."a" ON "dns"."a"."address" = "systems"."interface_addresses"."address"
		JOIN "systems"."interfaces" ON "systems"."interfaces"."mac" = "systems"."interface_addresses"."mac"
		JOIN "systems"."systems" ON "systems"."systems"."system_name" = "systems"."interfaces"."system_name"
		WHERE "systems"."interface_addresses"."config"='dhcp'
		AND "systems"."interface_addresses"."address" << (SELECT cidr(api.get_site_configuration('DYNAMIC_SUBNET')))
		AND ("dns"."a"."zone" IN (SELECT DISTINCT "zone" FROM "ip"."subnets" WHERE "dhcp_enable" IS TRUE ORDER BY "zone")
		OR "dns"."a"."zone" IS NULL) ORDER BY "systems"."systems"."owner");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_dynamic_hosts"() IS 'Get all information for a host block of the dhcpd.conf file';

/* API - get_dhcpd_subnets */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_subnets"() RETURNS SETOF CIDR AS $$
	BEGIN
		RETURN QUERY (SELECT "subnet" FROM "ip"."subnets" WHERE "dhcp_enable" = TRUE AND family("subnet") = 4 ORDER BY "subnet");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_subnets"() IS 'Get a list of all DHCP enabled subnets for DHCPD';

/* API - get_dhcpd_subnet_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_subnet_options"(input_subnet cidr) RETURNS SETOF "dhcp"."dhcpd_subnet_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."subnet_options" WHERE "subnet" = input_subnet ORDER BY "option");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_subnet_options"(cidr) IS 'Get all subnet options for dhcpd.conf';

/* API - get_dhcpd_range_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_range_options"(input_range text) RETURNS SETOF "dhcp"."dhcpd_range_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."range_options" WHERE "name" = input_range ORDER BY "option");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_range_options"(text) IS 'Get all range options for dhcpd.conf';

/* API - get_dhcpd_subnet_ranges */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_subnet_ranges"(input_subnet cidr) RETURNS SETOF "dhcp"."dhcpd_subnet_ranges" AS $$
	BEGIN
		RETURN QUERY (SELECT "name","first_ip","last_ip","class" FROM "ip"."ranges" WHERE "subnet" = input_subnet AND "use" = 'ROAM' AND family("subnet") = 4 ORDER BY "subnet");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_subnet_ranges"(cidr) IS 'Get a list of all dynamic ranges in a subnet';

/* API - get_dhcpd_global_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_global_options"() RETURNS SETOF "dhcp"."dhcpd_global_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."global_options" ORDER BY CASE WHEN "option" = 'option space' THEN 1 ELSE 2 END);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_global_options"() IS 'Get all of the global DHCPD config directives';

/* API - get_dhcpd_dns_keys */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_dns_keys"() RETURNS SETOF "dhcp"."dhcpd_dns_keys" AS $$
	BEGIN
		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied on get_dhcpd_dns_keys: You are not admin.';
		END IF;
		
		-- Return data
		RETURN QUERY (SELECT DISTINCT "dns"."zones"."keyname","dns"."keys"."key","dns"."keys"."enctype" 
		FROM "ip"."subnets" 
		JOIN "dns"."zones" ON "dns"."zones"."zone" = "ip"."subnets"."zone" 
		JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname" 
		WHERE "dhcp_enable" = TRUE
		ORDER BY "dns"."zones"."keyname","dns"."keys"."key","dns"."keys"."enctype");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_dns_keys"() IS 'Get all of the dns keys for dhcpd';

/* API - get_dhcpd_forward_zones */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_forward_zones"() RETURNS SETOF "dhcp"."dhcpd_zones" AS $$
	BEGIN
		RETURN QUERY (SELECT DISTINCT "ip"."subnets"."zone","dns"."zones"."keyname","address"
		FROM "ip"."subnets"
		JOIN "dns"."zones" ON "dns"."zones"."zone" = "ip"."subnets"."zone" 
		JOIN "dns"."ns" ON "dns"."zones"."zone" = "dns"."ns"."zone" 
		WHERE "dns"."ns"."nameserver" IN (SELECT "nameserver" FROM "dns"."soa" WHERE "dns"."soa"."zone" = "ip"."subnets"."zone")
		ORDER BY "ip"."subnets"."zone");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_forward_zones"() IS 'Get all forward zone info for dhcpd';

/* API - get_dhcpd_reverse_zones */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_reverse_zones"() RETURNS SETOF "dhcp"."dhcpd_zones" AS $$
	BEGIN
		RETURN QUERY (SELECT DISTINCT api.get_reverse_domain("subnet") AS "zone","dns"."zones"."keyname","address" 
		FROM "ip"."subnets"
		JOIN "dns"."zones" ON "dns"."zones"."zone" = "ip"."subnets"."zone" 
		JOIN "dns"."ns" ON "dns"."zones"."zone" = "dns"."ns"."zone" 
		WHERE "dns"."ns"."nameserver" IN (SELECT "nameserver" FROM "dns"."soa" WHERE "dns"."soa"."zone" = "ip"."subnets"."zone") 
		AND "dhcp_enable" = TRUE AND family("subnet") = 4
		ORDER BY api.get_reverse_domain("subnet"),"dns"."zones"."keyname","address");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_reverse_zones"() IS 'Get all reverse zone info for dhcpd';

/* API - get_dhcpd_classes */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_classes"() RETURNS SETOF "dhcp"."dhcpd_classes" AS $$
	BEGIN
		RETURN QUERY (SELECT "class","comment" FROM "dhcp"."classes" ORDER BY "class");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_classes"() IS 'Get class information for the dhcpd.conf file';

/* API - get_dhcpd_class_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_class_options"(input_class text) RETURNS SETOF "dhcp"."dhcpd_class_options" AS $$
	BEGIN
		RETURN QUERY (SELECT "option","value" FROM "dhcp"."class_options" WHERE "class" = input_class ORDER BY "option");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_class_options"(text) IS 'Get class options for the dhcpd.conf file';

/* API - get_dhcp_classes*/
CREATE OR REPLACE FUNCTION "api"."get_dhcp_classes"() RETURNS SETOF "dhcp"."classes" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "dhcp"."classes" ORDER BY "class");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_classes"() IS 'Get all DHCP class information';

/* API - get_dhcp_class */
CREATE OR REPLACE FUNCTION "api"."get_dhcp_class"(input_class text) RETURNS SETOF "dhcp"."classes" AS $$
	BEGIN
		IF input_class IS NULL THEN
			RETURN QUERY (SELECT * FROM "dhcp"."classes" ORDER BY "class");
		ELSE
			RETURN QUERY (SELECT * FROM "dhcp"."classes" WHERE "class" = input_class ORDER BY "class");
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_class"(text) IS 'Get all DHCP class information for a specific class';

/* API - get_dhcp_config_types */
CREATE OR REPLACE FUNCTION "api"."get_dhcp_config_types"(input_family integer) RETURNS SETOF "dhcp"."config_types" AS $$
	BEGIN
		IF input_family IS NULL THEN
			RETURN QUERY (SELECT * FROM "dhcp"."config_types" ORDER BY CASE WHEN "config" = api.get_site_configuration('DEFAULT_CONFIG_TYPE') THEN 1 ELSE 2 END);
		ELSE
			RETURN QUERY (SELECT * FROM "dhcp"."config_types" WHERE "family" = input_family ORDER BY CASE WHEN "config" = api.get_site_configuration('DEFAULT_CONFIG_TYPE') THEN 1 ELSE 2 END);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_config_types"(integer) IS 'Get all DHCP config information';

/* API - get_dhcp_global_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcp_global_options"() RETURNS SETOF "dhcp"."global_options" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "dhcp"."global_options" ORDER BY "option");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_global_options"() IS 'Get all DHCP global option data';

/* API - get_dhcp_class_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcp_class_options"(input_class text) RETURNS SETOF "dhcp"."class_options" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "dhcp"."class_options" WHERE "class" = input_class ORDER BY "option");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_class_options"(text) IS 'Get all DHCP class option data';

/* API - get_dhcp_range_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcp_range_options"(input_range text) RETURNS SETOF "dhcp"."range_options" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "dhcp"."range_options" WHERE "name" = input_range ORDER BY "option");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_range_options"(text) IS 'Get all DHCP range option data';

/* API - get_dhcp_subnet_options */
CREATE OR REPLACE FUNCTION "api"."get_dhcp_subnet_options"(input_subnet cidr) RETURNS SETOF "dhcp"."subnet_options" AS $$
	BEGIN
		RETURN QUERY (SELECT * FROM "dhcp"."subnet_options" WHERE "subnet" = input_subnet ORDER BY "option");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcp_subnet_options"(cidr) IS 'Get all DHCP subnet option data';

/* API - get_dhcpd_config */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd_config"() RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "value" FROM "management"."output" WHERE "file"='dhcpd.conf' ORDER BY "timestamp" DESC LIMIT 1);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_config"() IS 'Get the latest DHCPD configuration file';

/* API - get_dhcpd6_config */
CREATE OR REPLACE FUNCTION "api"."get_dhcpd6_config"() RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "value" FROM "management"."output" WHERE "file"='dhcpd6.conf' ORDER BY "timestamp" DESC LIMIT 1);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd6_config"() IS 'Get the latest DHCPD6 configuration file';

CREATE OR REPLACE FUNCTION "api"."get_dhcpd_shared_networks"() RETURNS SETOF TEXT AS $$
	BEGIN
	   	RETURN QUERY (SELECT "name" FROM "network"."vlans" WHERE "datacenter" = api.get_site_configuration('DEFAULT_DATACENTER') ORDER BY "name");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_shared_networks"() IS 'Get DHCPD shared networks';

CREATE OR REPLACE FUNCTION "api"."get_dhcpd_shared_network_subnets"(input_name text) RETURNS SETOF CIDR AS $$
	BEGIN
	   	RETURN QUERY (SELECT "subnet" FROM "network"."vlans" JOIN "ip"."subnets" ON "network"."vlans"."vlan" = "ip"."subnets"."vlan" WHERE "network"."vlans"."name" = input_name AND "dhcp_enable" IS TRUE);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dhcpd_shared_network_subnets"(text) IS 'Get the subnets for DHCPD';
