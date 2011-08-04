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

/* API - get_dns_text */
CREATE OR REPLACE FUNCTION "api"."get_dns_text"(input_address inet) RETURNS SETOF "dns"."txt_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "hostname","zone","address","type","text","ttl","owner","date_created","date_modified","last_modifier"
			FROM "dns"."txt" WHERE "address" = input_address ORDER BY "hostname" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_text"(inet) IS 'Get all DNS TXT records for an address';

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

/* API - get_record_types */
CREATE OR REPLACE FUNCTION "api"."get_record_types"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "type" FROM "dns"."types" ORDER BY "type" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_record_types"() IS 'Get all of the valid DNS types for this application';

/* API - get_dns_zones*/
CREATE OR REPLACE FUNCTION "api"."get_dns_zones"(input_username text) RETURNS SETOF "dns"."zone_data" AS $$
	BEGIN
		IF input_username IS NULL THEN
			RETURN QUERY(SELECT "zone","keyname","forward","shared","owner","comment","date_created","date_modified","last_modifier"
			FROM "dns"."zones" WHERE "forward" = TRUE ORDER BY "zone" ASC);
		ELSE
			RETURN QUERY(SELECT "zone","keyname","forward","shared","owner","comment","date_created","date_modified","last_modifier"
			FROM "dns"."zones" WHERE "forward" = TRUE AND ("shared" = TRUE OR "owner" = input_username) ORDER BY "zone" ASC);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_zones"(text) IS 'Get the available zones to a user';


/* API - get_dns_zone*/
CREATE OR REPLACE FUNCTION "api"."get_dns_zone"(input_zone text) RETURNS SETOF "dns"."zone_data" AS $$
	BEGIN
		RETURN QUERY(SELECT "zone","keyname","forward","shared","owner","comment","date_created","date_modified","last_modifier"
		FROM "dns"."zones" WHERE "zone" = input_zone);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_zone"(text) IS 'Get detailed dns zone information';

/* API - get_dns_keys */
CREATE OR REPLACE FUNCTION "api"."get_dns_keys"(input_username text) RETURNS SETOF "dns"."key_data" AS $$
	BEGIN
		IF input_username IS NULL THEN
			RETURN QUERY (SELECT "keyname","key","comment","owner","date_created","date_modified","last_modifier"
			FROM "dns"."keys");
		ELSE
			RETURN QUERY (SELECT "keyname","key","comment","owner","date_created","date_modified","last_modifier"
			FROM "dns"."keys" WHERE "owner" = input_username ORDER BY "keyname" ASC);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_keys"(text) IS 'Get DNS key data';

/* API - get_dns_key */
CREATE OR REPLACE FUNCTION "api"."get_dns_key"(input_keyname text) RETURNS SETOF "dns"."key_data" AS $$
	BEGIN
		RETURN QUERY (SELECT "keyname","key","comment","owner","date_created","date_modified","last_modifier"
		FROM "dns"."keys" WHERE "keyname" = input_keyname);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_key"(text) IS 'Get DNS key data';