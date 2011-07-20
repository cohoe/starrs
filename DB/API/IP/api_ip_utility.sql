/* API - ip_arp */
CREATE OR REPLACE FUNCTION "api"."ip_arp"(input_address inet) RETURNS macaddr AS $$
	BEGIN
		RETURN (SELECT "mac" FROM "systems"."interface_addresses" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."ip_arp"(inet) IS 'Get the MAC address assiciated with an IP address';