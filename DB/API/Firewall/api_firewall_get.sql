/* API - get_firewall_site_default
	1) Get action
*/
CREATE OR REPLACE FUNCTION "api"."get_firewall_site_default"() RETURNS BOOLEAN AS $$
	DECLARE
		Action BOOLEAN;
	BEGIN
		-- Get action
		SELECT bool("value") INTO Action
		FROM "management"."configuration"
		WHERE "option" = 'FW_DEFAULT_ACTION';

		-- Done
		RETURN Action;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_firewall_site_default"() IS 'Return the value of the site firewall default configuration';
