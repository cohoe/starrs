/* API - get_firewall_default */
CREATE OR REPLACE FUNCTION "api"."get_firewall_default"(input_address inet) RETURNS boolean AS $$
	BEGIN
		RETURN (SELECT "deny" FROM "firewall"."defaults" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_default"(inet) IS 'Get the default firewall action of an address';