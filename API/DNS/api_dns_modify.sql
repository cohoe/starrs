/* api_dns_modify.sql
	1) modify_dns_key
	2) modify_dns_zone
	3) modify_dns_address
	4) modify_dns_mailserver
	5) modify_dns_nameserver
	6) modify_dns_srv
	7) modify_dns_cname
	8) modify_dns_txt
	9) modify_dns_soa
*/

/* API - modify_dns_key
	1) Check privileges
	2) Check allowed fields
	3) Validate input
	4) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_key"(input_old_keyname text, input_field text, input_new_value text) RETURNS SETOF "dns"."keys" AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."keys" WHERE "keyname" = input_old_keyname) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit key % denied. You are not owner',input_old_keyname;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'keyname|key|comment|owner' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Validate input
		IF input_field ~* 'keyname' THEN 
			input_new_value := api.validate_nospecial(input_new_value);
		END IF;

		-- Update record
		EXECUTE 'UPDATE "dns"."keys" SET ' || quote_ident($2) || ' = $3, 
		date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
		WHERE "keyname" = $1' 
		USING input_old_keyname, input_field, input_new_value;

		-- Done
		IF input_field ~* 'keyname' THEN
			RETURN QUERY (SELECT "keyname","key","comment","owner","date_created","date_modified","last_modifier"
			FROM "dns"."keys" WHERE "keyname" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."keys" WHERE "keyname" = input_old_keyname);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_key"(text,text,text) IS 'Modify an existing DNS key';

/* API - modify_dns_zone
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_zone"(input_old_zone text, input_field text, input_new_value text) RETURNS SETOF "dns"."zones" AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_old_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit zone % denied. You are not owner',input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'zone|forward|keyname|owner|comment|shared|ddns' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		IF input_field ~* 'forward|shared|ddns' THEN
			EXECUTE 'UPDATE "dns"."zones" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "zone" = $1' 
			USING input_old_zone, input_field, bool(input_new_value);
		ELSE
			EXECUTE 'UPDATE "dns"."zones" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "zone" = $1' 
			USING input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "dns"."zones" WHERE "zone" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."zones" WHERE "zone" = input_old_zone);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_zone"(text, text, text) IS 'Modify an existing DNS zone';

/* API - modify_dns_address
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_address"(input_old_address inet, input_old_zone text, input_field text, input_new_value text) RETURNS SETOF "dns"."a" AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."a" WHERE "address" = input_old_address AND "zone" = input_old_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit address % denied. You are not owner',input_old_address;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'hostname|zone|address|owner|ttl' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;
		
		IF input_field ~* 'ttl' THEN
			-- User can only specify TTL if address is static
			IF (SELECT "config" FROM "systems"."interface_addresses" WHERE "address" = input_old_address) !~* 'static' AND input_new_value::integer != (SELECT "value"::integer/2 AS "ttl" FROM "dhcp"."subnet_options" WHERE "option"='default-lease-time' AND "subnet" >> input_old_address) THEN
				RAISE EXCEPTION 'You can only specify a TTL other than the default if your address is configured statically';
			END IF;
		END IF;

		-- Lower
		IF input_field ~* 'hostname' THEN
			input_new_value := lower(input_new_value);
		END IF;

		-- Update record

		IF input_field ~* 'address' THEN
			EXECUTE 'UPDATE "dns"."a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "address" = $1 AND "zone" = $2' 
			USING input_old_address, input_old_zone, input_field, inet(input_new_value);		
		ELSIF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "address" = $1 AND "zone" = $2' 
			USING input_old_address, input_old_zone, input_field, cast(input_new_value as int);
		ELSE
			EXECUTE 'UPDATE "dns"."a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "address" = $1 AND "zone" = $2' 
			USING input_old_address, input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'address' THEN
			RETURN QUERY (SELECT * FROM "dns"."a" WHERE "address" = inet(input_new_value) AND "zone" = input_old_zone);
		ELSEIF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "dns"."a" WHERE "address" = input_old_address AND "zone" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."a" WHERE "address" = input_old_address AND "zone" = input_old_zone);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_address"(inet,text,text,text) IS 'Modify an existing DNS address';

/* API - modify_dns_mailserver
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_mailserver"(input_old_hostname text, input_old_zone text, input_field text, input_new_value text) RETURNS SETOF "dns"."mx" AS $$
	BEGIN
		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."mx" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit mailserver (%.%) denied. You are not owner',input_old_address,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|preference|owner|ttl' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Lower
		IF input_field ~* 'hostname' THEN
			input_new_value := lower(input_new_value);
		END IF;

		-- Update record

		IF input_field ~* 'preference|ttl' THEN
			EXECUTE 'UPDATE "dns"."mx" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2'
			USING input_old_hostname, input_old_zone, input_field, cast(input_new_value as int);
		ELSEIF input_field ~* 'hostname' THEN
			EXECUTE 'UPDATE "dns"."mx" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user(), address = (SELECT "address" FROM "dns"."a" WHERE "hostname" = $4 AND "zone" = $2) 
			WHERE "hostname" = $1 AND "zone" = $2'
			USING input_old_hostname, input_old_zone, input_field, input_new_value;
		ELSE
			EXECUTE 'UPDATE "dns"."mx" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2'
			USING input_old_hostname, input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'hostname' THEN
			RETURN QUERY (SELECT * FROM "dns"."mx" WHERE "hostname" = input_new_value AND "zone" = input_old_zone);
		ELSEIF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "dns"."mx" WHERE "hostname" = input_old_hostname AND "zone" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."mx" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_mailserver"(text, text, text, text) IS 'Modify an existing DNS MX record';

/* API - modify_dns_nameserver
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_ns"(input_old_zone text, input_old_nameserver text, input_field text, input_new_value text) RETURNS SETOF "dns"."ns" AS $$
	BEGIN
		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_old_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit nameserver (%.%) denied. You are not owner',input_old_nameserver,input_old_zone;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'nameserver|zone|ttl|address' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Lower
		IF input_field ~* 'nameserver' THEN
			input_new_value := lower(input_new_value);
		END IF;

		-- Update record
		IF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."ns" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "zone" = $1 AND "nameserver" = $2'
			USING input_old_zone, input_old_nameserver, input_field, cast(input_new_value as int);
			
			-- Update TTLs of other zone records since they all need to be the same
			UPDATE "dns"."ns" SET "ttl" = cast(input_new_value as int) WHERE "zone" = input_old_zone;
			
		ELSEIF input_field ~* 'address' THEN
			EXECUTE 'UPDATE "dns"."ns" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "zone" = $1 AND "nameserver" = $2'
			USING input_old_zone, input_old_nameserver, input_field, cast(input_new_value as inet);
		ELSE
			EXECUTE 'UPDATE "dns"."ns" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "zone" = $1 AND "nameserver" = $2'
			USING input_old_zone, input_old_nameserver, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'input_old_zone' THEN		
			RETURN QUERY (SELECT * FROM "dns"."ns" WHERE "zone" = input_new_value AND "nameserver" = input_old_nameserver);
		ELSEIF input_field ~* 'nameserver' THEN
			RETURN QUERY (SELECT * FROM "dns"."ns" WHERE "zone" = input_old_zone AND "nameserver" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."ns" WHERE "zone" = input_old_zone AND "nameserver" = input_old_nameserver);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_ns"(text, text, text, text) IS 'Modify an existing DNS NS record';

/* API - modify_dns_srv
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_srv"(input_old_alias text, input_old_zone text, input_old_priority integer, input_old_weight integer, input_old_port integer, input_field text, input_new_value text) RETURNS SETOF "dns"."srv" AS $$
	BEGIN
		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."srv" WHERE "alias" = input_old_alias AND "zone" = input_old_zone AND "priority" = input_old_priority AND "weight" = input_old_weight AND "port" = input_old_port) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit alias (%.%) denied. You are not owner',input_old_alias,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|alias|owner|ttl|priority|weight|port' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Lower
		IF input_field ~* 'hostname|alias' THEN
			input_new_value := lower(input_new_value);
		END IF;
			
		-- Update record
		IF input_field ~* 'ttl|priority|weight|port' THEN
			EXECUTE 'UPDATE "dns"."srv" SET ' || quote_ident($6) || ' = $7,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "alias" = $1 AND "zone" = $2 AND "priority" = $3 AND "weight" = $4 AND "port" = $5'
			USING input_old_alias, input_old_zone, input_old_priority, input_old_weight, input_old_port, input_field, cast(input_new_value as int);
		ELSEIF input_field ~* 'hostname' THEN
			RAISE EXCEPTION 'test';
			EXECUTE 'UPDATE "dns"."srv" SET ' || quote_ident($6) || ' = $7,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user(), address = (SELECT "address" FROM "dns"."a" WHERE "hostname" = $7 AND "zone" = $2) 
			WHERE "alias" = $1 AND "zone" = $2 AND "priority" = $3 AND "weight" = $4 AND "port" = $5'
			USING input_old_alias, input_old_zone, input_old_priority, input_old_weight, input_old_port, input_field, input_new_value;
		ELSE
			EXECUTE 'UPDATE "dns"."srv" SET ' || quote_ident($6) || ' = $7,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "alias" = $1 AND "zone" = $2 AND "priority" = $3 AND "weight" = $4 AND "port" = $5'
			USING input_old_alias, input_old_zone, input_old_priority, input_old_weight, input_old_port, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'alias' THEN
			RETURN QUERY (SELECT * FROM "dns"."srv" 
			WHERE "alias" = input_new_value AND "zone" = input_old_zone AND "priority" = input_old_priority AND "weight" = input_old_weight AND "port" = input_old_port);
		ELSEIF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "dns"."srv" 
			WHERE "alias" = input_old_alias AND "zone" = input_new_value AND "priority" = input_old_priority AND "weight" = input_old_weight AND "port" = input_old_port);
		ELSEIF input_field ~* 'priority' THEN
			RETURN QUERY (SELECT * FROM "dns"."srv" 
			WHERE "alias" = input_old_alias AND "zone" = input_old_zone AND "priority" = input_new_value::integer AND "weight" = input_old_weight AND "port" = input_old_port);
		ELSEIF input_field ~* 'weight' THEN
			RETURN QUERY (SELECT * FROM "dns"."srv" 
			WHERE "alias" = input_old_alias AND "zone" = input_old_zone AND "priority" = input_old_priority AND "weight" = input_new_value::integer AND "port" = input_old_port);
		ELSEIF input_field ~* 'port' THEN
			RETURN QUERY (SELECT * FROM "dns"."srv" 
			WHERE "alias" = input_old_alias AND "zone" = input_old_zone AND "priority" = input_old_priority AND "weight" = input_old_weight AND "port" = input_new_value::integer);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."srv" 
			WHERE "alias" = input_old_alias AND "zone" = input_old_zone AND "priority" = input_old_priority AND "weight" = input_old_weight AND "port" = input_old_port);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_srv"(text, text, integer, integer, integer, text, text) IS 'Modify an existing DNS SRV record';

/* API - modify_dns_cname
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_cname"(input_old_alias text, input_old_zone text, input_field text, input_new_value text) RETURNS SETOF "dns"."cname" AS $$
	BEGIN

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."cname" WHERE "alias" = input_old_alias AND "zone" = input_old_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit alias (%.%) denied. You are not owner',input_old_alias,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|alias|owner|ttl' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Lower
		IF input_field ~* 'hostname|alias' THEN
			input_new_value := lower(input_new_value);
		END IF;

		-- Update record
		IF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."cname" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "alias" = $1 AND "zone" = $2'
			USING input_old_alias, input_old_zone, input_field, cast(input_new_value as int);
		ELSEIF input_field ~* 'hostname' THEN
			EXECUTE 'UPDATE "dns"."cname" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user(), address = (SELECT "address" FROM "dns"."a" WHERE "hostname" = $4 AND "zone" = $2) 
			WHERE "alias" = $1 AND "zone" = $2'
			USING input_old_alias, input_old_zone, input_field, input_new_value;
		ELSE
			EXECUTE 'UPDATE "dns"."cname" SET ' || quote_ident($3) || ' = $4,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "alias" = $1 AND "zone" = $2'
			USING input_old_alias, input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'alias' THEN
			RETURN QUERY (SELECT * FROM "dns"."cname" WHERE "alias" = input_new_value AND "zone" = input_old_zone);
		ELSEIF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "dns"."cname" WHERE "alias" = input_old_alias AND "zone" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."cname" WHERE "alias" = input_old_alias AND "zone" = input_old_zone);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_cname"(text, text, text, text) IS 'Modify an existing DNS CNAME record';

/* API - modify_dns_txt
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_txt"(input_old_hostname text, input_old_zone text, input_old_text text, input_field text, input_new_value text) RETURNS SETOF "dns"."txt" AS $$
	BEGIN
		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."txt" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone AND "text" = input_old_text) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit alias (%.%) denied. You are not owner',input_old_hostname,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|text|owner|ttl' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Lower
		IF input_zone ~* 'hostname' THEN
			input_new_value := lower(input_new_value);
		END IF;

		-- Update record
		IF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."txt" SET ' || quote_ident($4) || ' = $5,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2 AND "text" = $3'
			USING input_old_hostname, input_old_zone, input_old_text, input_field, cast(input_new_value as int);
		ELSE
			EXECUTE 'UPDATE "dns"."txt" SET ' || quote_ident($4) || ' = $5,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2 AND "text" = $3'
			USING input_old_hostname, input_old_zone, input_old_text, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'hostname' THEN
			RETURN QUERY (SELECT * FROM "dns"."txt" WHERE "hostname" = input_new_value AND "zone" = input_old_zone AND "text" = input_old_text);
		ELSEIF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "dns"."txt" WHERE "hostname" = input_old_hostname AND "zone" = input_new_value AND "text" = input_old_text);
		ELSEIF input_field ~* 'text' THEN
			RETURN QUERY (SELECT * FROM "dns"."txt" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone AND "text" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."txt" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone AND "text" = input_old_text);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_txt"(text, text, text, text, text) IS 'Modify an existing DNS TXT record';

/* API - modify_dns_soa
	1) Check privileges
	2) Check allowed fields
	3) Validate
	4) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_soa"(input_old_zone text, input_field text, input_new_value text) RETURNS SETOF "dns"."soa" AS $$
	BEGIN

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_old_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit SOA % denied. You are not owner',input_old_zone;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'zone|ttl|nameserver|contact|serial|refresh|retry|expire|minimum' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Validate
		IF input_field ~* 'contact' THEN
			IF api.validate_soa_contact(input_new_value) IS FALSE THEN
				RAISE EXCEPTION 'Invalid SOA contact given (%)',input_contact;
			END IF;
		END IF;

		-- Update record
		IF input_field ~* 'ttl|refresh|retry|expire|minimum' THEN
			EXECUTE 'UPDATE "dns"."soa" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "zone" = $1' 
			USING input_old_zone, input_field, cast(input_new_value as integer);
		ELSE
			EXECUTE 'UPDATE "dns"."soa" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "zone" = $1' 
			USING input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "dns"."soa" WHERE "zone" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."soa" WHERE "zone" = input_old_zone);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_soa"(text, text, text) IS 'Modify an existing DNS SOA record';

CREATE OR REPLACE FUNCTION "api"."modify_dns_zone_txt"(input_old_hostname text, input_old_zone text, input_old_text text, input_field text, input_new_value text) RETURNS SETOF "dns"."zone_txt" AS $$
	BEGIN
		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_old_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit alias (%.%) denied. You are not owner',input_old_hostname,input_old_zone;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|text|ttl' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Lower
		IF input_zone ~* 'hostname' THEN
			input_new_value := lower(input_new_value);
		END IF;

		-- Update record
		IF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."zone_txt" SET ' || quote_ident($4) || ' = $5,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2 AND "text" = $3'
			USING input_old_hostname, input_old_zone, input_old_text, input_field, cast(input_new_value as int);
			
			-- Update other zone-only records if needed
			IF input_old_hostname IS NULL THEN
				UPDATE "dns"."zone_txt" SET "ttl" = cast(input_new_value as int) WHERE "hostname" IS NULL AND "zone" = input_old_zone;
			END IF;
		ELSE
			EXECUTE 'UPDATE "dns"."zone_txt" SET ' || quote_ident($4) || ' = $5,
			date_modified = localtimestamp(0), last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2 AND "text" = $3'
			USING input_old_hostname, input_old_zone, input_old_text, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'hostname' THEN
			IF input_new_value IS NULL THEN
				RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" IS NULL AND "zone" = input_old_zone AND "text" = input_old_text);
			ELSE
				RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" = input_new_value AND "zone" = input_old_zone AND "text" = input_old_text);
			END IF;
		ELSEIF input_field ~* 'zone' THEN
			IF input_old_hostname IS NULL THEN
				RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" IS NULL AND "zone" = input_new_value AND "text" = input_old_text);
			ELSE
				RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" = input_old_hostname AND "zone" = input_new_value AND "text" = input_old_text);
			END IF;
		ELSEIF input_field ~* 'text' THEN
			IF input_old_hostname IS NULL THEN
				RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" IS NULL AND "zone" = input_old_zone AND "text" = input_new_value);
			ELSE
				RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone AND "text" = input_new_value);
			END IF;
		ELSE
			IF input_old_hostname IS NULL THEN
				RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" IS NULL AND "zone" = input_old_zone AND "text" = input_old_text);
			ELSE
				RETURN QUERY (SELECT * FROM "dns"."zone_txt" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone AND "text" = input_old_text);
			END IF;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_zone_txt"(text, text, text, text, text) IS 'Modify an existing DNS zone_txt record';

CREATE OR REPLACE FUNCTION "api"."modify_dns_zone_a"(input_old_zone text, input_old_address inet, input_field text, input_new_value text) RETURNS SETOF "dns"."zone_a" AS $$
	BEGIN
		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_old_zone) != api.get_current_user() THEN
				RAISE EXCEPTION 'Permission to edit zone % denied. You are not owner',input_old_zone;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'zone|address|ttl' THEN
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		IF input_field ~* 'address' THEN
			IF input_new_value::inet << api.get_site_configuration('DYNAMIC_SUBNET')::cidr THEN
				RAISE EXCEPTION 'Zone A cannot be dynamic';
			END IF;
		END IF;


		-- Update record
		IF input_field ~* 'address' THEN
			EXECUTE 'UPDATE "dns"."zone_a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "zone" = $1 AND "address" = $2' 
			USING input_old_zone, input_old_address, input_field, inet(input_new_value);		
		ELSIF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."zone_a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "zone" = $1 AND "address" = $2' 
			USING input_old_zone, input_old_address, input_field, cast(input_new_value as int);
		ELSE
			EXECUTE 'UPDATE "dns"."zone_a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "zone" = $1 AND "address" = $2' 
			USING input_old_zone, input_old_address, input_field, input_new_value;
		END IF;

		-- Done
		IF input_field ~* 'zone' THEN
			RETURN QUERY (SELECT * FROM "dns"."zone_a" WHERE "zone" = input_new_value AND "address" = input_old_address);
		ELSEIF input_field ~* 'address' THEN
			RETURN QUERY (SELECT * FROM "dns"."zone_a" WHERE "zone" = input_old_zone AND "address" = inet(input_new_value));
		ELSE
			RETURN QUERY (SELECT * FROM "dns"."zone_a" WHERE "zone" = input_old_zone AND "address" = input_old_address);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_zone_a"(text,inet,text,text) IS 'Modify an existing DNS address';
