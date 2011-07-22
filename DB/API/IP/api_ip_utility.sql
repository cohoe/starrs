/* API - ip_arp */
CREATE OR REPLACE FUNCTION "api"."ip_arp"(input_address inet) RETURNS macaddr AS $$
	BEGIN
		RETURN (SELECT "mac" FROM "systems"."interface_addresses" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."ip_arp"(inet) IS 'Get the MAC address assiciated with an IP address';

/* API - ip_in_subnet */
CREATE OR REPLACE FUNCTION "api"."ip_in_subnet"(input_address inet, input_subnet cidr) RETURNS BOOLEAN AS $$
	BEGIN
		IF input_address << input_subnet THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."ip_in_subnet"(inet, cidr) IS 'True or False if an address is contained within a given subnet';