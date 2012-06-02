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
CREATE OR REPLACE FUNCTION "api"."modify_dns_key"(input_old_keyname text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_key');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."keys" WHERE "keyname" = input_old_keyname) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned key');
				RAISE EXCEPTION 'Permission to edit key % denied. You are not owner',input_old_keyname;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'keyname|key|comment|owner' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Validate input
		IF input_field ~* 'keyname' THEN 
			input_new_value := api.validate_nospecial(input_new_value);
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		EXECUTE 'UPDATE "dns"."keys" SET ' || quote_ident($2) || ' = $3, 
		date_modified = current_timestamp, last_modifier = api.get_current_user() 
		WHERE "keyname" = $1' 
		USING input_old_keyname, input_field, input_new_value;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_key"(text,text,text) IS 'Modify an existing DNS key';

/* API - modify_dns_zone
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_zone"(input_old_zone text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_zone');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_old_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned zone');
				RAISE EXCEPTION 'Permission to edit zone % denied. You are not owner',input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'zone|forward|keyname|owner|comment|shared' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		IF input_field ~* 'forward|shared' THEN
			EXECUTE 'UPDATE "dns"."zones" SET ' || quote_ident($2) || ' = $3, 
			date_modified = current_timestamp, last_modifier = api.get_current_user() 
			WHERE "zone" = $1' 
			USING input_old_zone, input_field, bool(input_new_value);
		ELSE
			EXECUTE 'UPDATE "dns"."zones" SET ' || quote_ident($2) || ' = $3, 
			date_modified = current_timestamp, last_modifier = api.get_current_user() 
			WHERE "zone" = $1' 
			USING input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_zone');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_zone"(text, text, text) IS 'Modify an existing DNS zone';

/* API - modify_dns_address
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_address"(input_old_address inet, input_old_zone text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_address');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."a" WHERE "address" = input_old_address AND "zone" = input_old_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned address');
				RAISE EXCEPTION 'Permission to edit address % denied. You are not owner',input_old_address;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'hostname|zone|address|owner|ttl' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		IF input_field ~* 'address' THEN
			EXECUTE 'UPDATE "dns"."a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = current_timestamp, last_modifier = api.get_current_user() 
			WHERE "address" = $1 AND "zone" = $2' 
			USING input_old_address, input_old_zone, input_field, inet(input_new_value);		
		ELSIF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = current_timestamp, last_modifier = api.get_current_user() 
			WHERE "address" = $1 AND "zone" = $2' 
			USING input_old_address, input_old_zone, input_field, cast(input_new_value as int);
		ELSE
			EXECUTE 'UPDATE "dns"."a" SET ' || quote_ident($3) || ' = $4, 
			date_modified = current_timestamp, last_modifier = api.get_current_user() 
			WHERE "address" = $1 AND "zone" = $2' 
			USING input_old_address, input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_address"(inet,text,text,text) IS 'Modify an existing DNS address';

/* API - modify_dns_mailserver
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_mailserver"(input_old_hostname text, input_old_zone text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_mailserver');

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."mx" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned mailserver');
				RAISE EXCEPTION 'Permission to edit mailserver (%.%) denied. You are not owner',input_old_address,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|preference|owner|ttl' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		IF input_field ~* 'preference|ttl' THEN
			EXECUTE 'UPDATE "dns"."mx" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2'
			USING input_old_hostname, input_old_zone, input_field, cast(input_new_value as int);
		ELSE
			EXECUTE 'UPDATE "dns"."mx" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2'
			USING input_old_hostname, input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_mailserver"(text, text, text, text) IS 'Modify an existing DNS MX record';

/* API - modify_dns_nameserver
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_nameserver"(input_old_hostname text, input_old_zone text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_nameserver');

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."ns" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned nameserver');
				RAISE EXCEPTION 'Permission to edit nameserver (%.%) denied. You are not owner',input_old_address,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|isprimary|owner|ttl' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		IF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."ns" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2'
			USING input_old_hostname, input_old_zone, input_field, cast(input_new_value as int);
		ELSIF input_field ~* 'isprimary' THEN
			EXECUTE 'UPDATE "dns"."ns" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2'
			USING input_old_hostname, input_old_zone, input_field, bool(input_new_value);
		ELSE
			EXECUTE 'UPDATE "dns"."ns" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2'
			USING input_old_hostname, input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_nameserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_nameserver"(text, text, text, text) IS 'Modify an existing DNS ns record';

/* API - modify_dns_srv
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_srv"(input_old_alias text, input_old_zone text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_srv');

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."pointers" WHERE "alias" = input_old_alias AND "zone" = input_old_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned SRV');
				RAISE EXCEPTION 'Permission to edit alias (%.%) denied. You are not owner',input_old_alias,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|alias|owner|ttl|extra' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		IF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."pointers" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "alias" = $1 AND "zone" = $2 AND "type" = $5'
			USING input_old_alias, input_old_zone, input_field, cast(input_new_value as int), 'SRV';
		ELSE
			EXECUTE 'UPDATE "dns"."pointers" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "alias" = $1 AND "zone" = $2 AND "type" = $5'
			USING input_old_alias, input_old_zone, input_field, input_new_value, 'SRV';
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_srv');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_srv"(text, text, text, text) IS 'Modify an existing DNS SRV record';

/* API - modify_dns_cname
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_cname"(input_old_alias text, input_old_zone text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_cname');

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."pointers" WHERE "alias" = input_old_alias AND "zone" = input_old_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned alias');
				RAISE EXCEPTION 'Permission to edit alias (%.%) denied. You are not owner',input_old_alias,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|alias|owner|ttl' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		IF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."pointers" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "alias" = $1 AND "zone" = $2 AND "type" = $5'
			USING input_old_alias, input_old_zone, input_field, cast(input_new_value as int), 'CNAME';
		ELSE
			EXECUTE 'UPDATE "dns"."pointers" SET ' || quote_ident($3) || ' = $4,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "alias" = $1 AND "zone" = $2 AND "type" = $5'
			USING input_old_alias, input_old_zone, input_field, input_new_value, 'CNAME';
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_cname');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_cname"(text, text, text, text) IS 'Modify an existing DNS CNAME record';

/* API - modify_dns_txt
	1) Check privileges
	2) Check allowed fields
	3) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_text"(input_old_hostname text, input_old_zone text, input_type text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_text');

		 -- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."txt" WHERE "hostname" = input_old_hostname AND "zone" = input_old_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned TXT');
				RAISE EXCEPTION 'Permission to edit alias (%.%) denied. You are not owner',input_old_hostname,input_old_zone;
			END IF;

			IF input_field ~* 'owner' AND input_new_value != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Only administrators can define a different owner (%).',input_new_value;
			END IF;
		END IF;

		 -- Check allowed fields
		IF input_field !~* 'hostname|zone|text|owner|ttl|type' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		IF input_field ~* 'ttl' THEN
			EXECUTE 'UPDATE "dns"."txt" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2 AND "type" = $3'
			USING input_old_hostname, input_old_zone, input_type, input_field, cast(input_new_value as int);
		ELSE
			EXECUTE 'UPDATE "dns"."txt" SET ' || quote_ident($4) || ' = $5,
			date_modified = current_timestamp, last_modifier = api.get_current_user()
			WHERE "hostname" = $1 AND "zone" = $2 AND "type" = $3'
			USING input_old_hostname, input_old_zone, input_type, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_text');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_text"(text, text, text, text, text) IS 'Modify an existing DNS TXT record';

/* API - modify_dns_soa
	1) Check privileges
	2) Check allowed fields
	3) Validate
	4) Update record
*/
CREATE OR REPLACE FUNCTION "api"."modify_dns_soa"(input_old_zone text, input_field text, input_new_value text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.modify_dns_soa');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_old_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied on non-owned soa');
				RAISE EXCEPTION 'Permission to edit SOA % denied. You are not owner',input_old_zone;
			END IF;
 		END IF;

		-- Check allowed fields
		IF input_field !~* 'zone|ttl|nameserver|contact|serial|refresh|retry|expire|minimum' THEN
			PERFORM api.create_log_entry('API','ERROR','Invalid field');
			RAISE EXCEPTION 'Invalid field % specified',input_field;
		END IF;
		
		-- Validate
		IF input_field ~* 'contact' THEN
			IF api.validate_soa_contact(input_new_value) IS FALSE THEN
				PERFORM api.create_log_entry('API','ERROR','Invalid SOA contact given');
				RAISE EXCEPTION 'Invalid SOA contact given (%)',input_contact;
			END IF;
		END IF;

		-- Update record
		PERFORM api.create_log_entry('API','INFO','update record');

		IF input_field ~* 'ttl|refresh|retry|expire|minimum' THEN
			EXECUTE 'UPDATE "dns"."soa" SET ' || quote_ident($2) || ' = $3, 
			date_modified = current_timestamp, last_modifier = api.get_current_user() 
			WHERE "zone" = $1' 
			USING input_old_zone, input_field, cast(input_new_value as integer);
		ELSE
			EXECUTE 'UPDATE "dns"."soa" SET ' || quote_ident($2) || ' = $3, 
			date_modified = current_timestamp, last_modifier = api.get_current_user() 
			WHERE "zone" = $1' 
			USING input_old_zone, input_field, input_new_value;
		END IF;

		-- Done
		PERFORM api.create_log_entry('API', 'DEBUG', 'finish api.modify_dns_soa');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_dns_soa"(text, text, text) IS 'Modify an existing DNS SOA record';
