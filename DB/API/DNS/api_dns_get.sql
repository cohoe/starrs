/* API - get_dns_mx */
CREATE OR REPLACE FUNCTION "api"."get_dns_mx"(input_address inet) RETURNS SETOF "dns"."mx_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "hostname","zone","address","type","preference","ttl","owner","date_created","date_modified","last_modifier"
			FROM "dns"."mx" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_mx"(inet) IS 'Get all data pertanent to DNS MX records for an address';

/* API - get_dns_mx */
CREATE OR REPLACE FUNCTION "api"."get_dns_ns"(input_address inet) RETURNS SETOF "dns"."ns_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "hostname","zone","address","type","isprimary","ttl","owner","date_created","date_modified","last_modifier"
			FROM "dns"."ns" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_ns"(inet) IS 'Get all data pertanent to DNS NS records for an address';

/* API - get_dns_txt */
CREATE OR REPLACE FUNCTION "api"."get_dns_txt"(input_address inet) RETURNS SETOF "dns"."txt_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "hostname","zone","address","type","text","ttl","owner","date_created","date_modified","last_modifier"
			FROM "dns"."txt" WHERE "address" = input_address ORDER BY "hostname" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_txt"(inet) IS 'Get all DNS TXT records for an address';

/* API - get_dns_pointers */
CREATE OR REPLACE FUNCTION "api"."get_dns_pointers"(input_address inet) RETURNS SETOF "dns"."pointer_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "alias","hostname","zone","address","type","extra","ttl","owner","date_created","date_modified","last_modifier"
			FROM "dns"."pointers" WHERE "address" = input_address ORDER BY "alias" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_pointers"(inet) IS 'Get all DNS pointer (SRV,CNAME) records for an address';

/* API - get_dns_a */
CREATE OR REPLACE FUNCTION "api"."get_dns_a"(input_address inet) RETURNS SETOF "dns"."a_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "hostname","zone","address","type","ttl","owner","date_created","date_modified","last_modifier"
			FROM "dns"."a" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_a"(inet) IS 'Get all DNS address records for an address';

/* API - get_dns_types */
CREATE OR REPLACE FUNCTION "api"."get_dns_types"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "type" FROM "dns"."types");
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_types"() IS 'Get all of the valid DNS types for this application';