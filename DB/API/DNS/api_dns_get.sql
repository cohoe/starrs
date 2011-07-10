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