/* API - get_dns_mx */
CREATE OR REPLACE FUNCTION "api"."get_dns_mx"(input_address inet) RETURNS SETOF "dns"."mx" AS $$
	BEGIN
		IF input_address IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."mx" ORDER BY "preference");
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."mx" WHERE "address" = input_address ORDER BY "preference");
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_mx"(inet) IS 'Get all data pertanent to DNS MX records for an address';

/* API - get_dns_zone_ns */
CREATE OR REPLACE FUNCTION "api"."get_dns_zone_ns"(input_zone text) RETURNS SETOF "dns"."ns" AS $$
	BEGIN
		IF input_address IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."ns" ORDER BY "nameserver");
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."ns" WHERE "zone" = input_zone ORDER BY "nameserver");
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_zone_ns"(text) IS 'Get all DNS NS records for a zone';

/* API - get_dns_text */
CREATE OR REPLACE FUNCTION "api"."get_dns_txt"(input_address inet) RETURNS SETOF "dns"."txt" AS $$
	BEGIN
		IF input_address IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."txt" ORDER BY "text");
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."txt" WHERE "address" = input_address ORDER BY "text");
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_txt"(inet) IS 'Get all DNS TXT records for an address';

/* API - get_dns_srv */
CREATE OR REPLACE FUNCTION "api"."get_dns_srv"(input_address inet) RETURNS SETOF "dns"."srv" AS $$
	BEGIN
		IF input_address IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."srv" ORDER BY "alias");
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."srv" WHERE "address" = input_address ORDER BY "alias" ASC);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_srv"(inet) IS 'Get all DNS SRV records for an address';

/* API - get_dns_cname */
CREATE OR REPLACE FUNCTION "api"."get_dns_cname"(input_address inet) RETURNS SETOF "dns"."cname" AS $$
	BEGIN
		IF input_address IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."cname" ORDER BY "alias");
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."cname" WHERE "address" = input_address ORDER BY "alias" ASC);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_cname"(inet) IS 'Get all DNS CNAME records for an address';

/* API - get_dns_a */
CREATE OR REPLACE FUNCTION "api"."get_dns_a"(input_address inet, input_zone text) RETURNS SETOF "dns"."a" AS $$
	BEGIN
		IF input_zone IS NULL THEN
			IF input_address IS NULL THEN
				RETURN QUERY (SELECT * FROM "dns"."a" ORDER BY "address");
			ELSE
				RETURN QUERY (SELECT * FROM "dns"."a" WHERE "address" = input_address ORDER BY "zone" ASC);
			END IF;
		ELSE
			IF input_address IS NULL THEN
				RETURN QUERY (SELECT * FROM "dns"."a" ORDER BY "address");
			ELSE
				RETURN QUERY (SELECT * FROM "dns"."a" WHERE "address" = input_address AND "zone" = input_zone ORDER BY "zone");
			END IF;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_a"(inet,text) IS 'Get all DNS address records for an address';

/* API - get_record_types */
CREATE OR REPLACE FUNCTION "api"."get_record_types"() RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN QUERY (SELECT "type" FROM "dns"."types" ORDER BY "type" ASC);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_record_types"() IS 'Get all of the valid DNS types for this application';

/* API - get_dns_zones*/
CREATE OR REPLACE FUNCTION "api"."get_dns_zones"(input_username text) RETURNS SETOF "dns"."zones" AS $$
	BEGIN
		IF input_username IS NULL THEN
			RETURN QUERY(SELECT * FROM "dns"."zones" WHERE "forward" = TRUE ORDER BY "zone" ASC);
		ELSE
			RETURN QUERY(SELECT * FROM "dns"."zones" WHERE "forward" = TRUE AND ("shared" = TRUE OR "owner" = input_username) ORDER BY "zone" ASC);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_zones"(text) IS 'Get the available zones to a user';


/* API - get_dns_zone*/
CREATE OR REPLACE FUNCTION "api"."get_dns_zone"(input_zone text) RETURNS SETOF "dns"."zones" AS $$
	BEGIN
		IF input_zone IS NULL THEN
			RETURN QUERY(SELECT * FROM "dns"."zones" ORDER BY "zone");
		ELSE
			RETURN QUERY(SELECT * FROM "dns"."zones" WHERE "zone" = input_zone ORDER BY "zone");
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_zone"(text) IS 'Get detailed dns zone information';

/* API - get_dns_keys */
CREATE OR REPLACE FUNCTION "api"."get_dns_keys"(input_username text) RETURNS SETOF "dns"."keys" AS $$
	BEGIN
		IF input_username IS NULL THEN
			IF api.get_current_user_level() !~* 'ADMIN' THEN
				RAISE EXCEPTION 'Permission to get DNS keys denied: You are not admin';
			END IF;
			RETURN QUERY (SELECT * FROM "dns"."keys" ORDER BY "keyname");
		ELSE
			IF api.get_current_user_level() !~* 'ADMIN' THEN
				IF input_username != api.get_current_user() THEN
					RAISE EXCEPTION 'Permission to get DNS keys denied: You are not admin or owner';
				END IF;
			END IF;
			RETURN QUERY (SELECT * FROM "dns"."keys" WHERE "owner" = input_username ORDER BY "keyname" ASC);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_keys"(text) IS 'Get DNS key data';

/* API - get_dns_key */
CREATE OR REPLACE FUNCTION "api"."get_dns_key"(input_keyname text) RETURNS SETOF "dns"."keys" AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF (SELECT "owner" FROM "dns"."keys" WHERE "keyname" = input_keyname) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to get DNS key denied: You are not admin or owner';
			END IF;
		END IF;
		RETURN QUERY (SELECT * FROM "dns"."keys" WHERE "keyname" = input_keyname);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_key"(text) IS 'Get DNS key data';

CREATE OR REPLACE FUNCTION "api"."get_dns_soa"(input_zone text) RETURNS SETOF "dns"."soa" AS $$
	BEGIN
		IF input_address IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."soa" ORDER BY "zone");
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."soa" WHERE "dns"."soa"."zone" = input_zone);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_soa"(text) IS 'Get the SOA record of a DNS zone';

/* API - get_dns_text */
CREATE OR REPLACE FUNCTION "api"."get_dns_zone_txt"(input_zone text) RETURNS SETOF "dns"."zone_txt" AS $$
	BEGIN
		IF input_address IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."zone_txt" ORDER BY "hostname");
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "zone" = input_zone ORDER BY "hostname" ASC);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_zone_txt"(text) IS 'Get all DNS TXT records specifically for a zone';

CREATE OR REPLACE FUNCTION "api"."get_dns_zone_a"(input_zone text) RETURNS SETOF "dns"."zone_a" AS $$
	BEGIN
		IF input_address IS NULL THEN
			RETURN QUERY (SELECT * FROM "dns"."zone_a" ORDER BY "address");
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."zone_a" WHERE "zone" = input_zone ORDER BY "address");
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_dns_zone_a"(text) IS 'Get all DNS address records for a zone';