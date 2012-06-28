/* api_dns_remove.sql
	1) remove_dns_key
	2) remove_dns_zone
	3) remove_dns_address
	4) remove_dns_mailserver
	5) remove_dns_nameserver
	6) remove_dns_srv
	7) remove_dns_cname
	8) remove_dns_txt
	9) remove_dns_soa
*/

/* API - remove_dns_key
	1) Check privileges
	2) Remove dns key
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_key"(input_keyname text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_key');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."keys" WHERE "keyname" = input_keyname) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on key %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_keyname;
			END IF;
		END IF;

		-- Remove key		
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dns key');
		DELETE FROM "dns"."keys" WHERE "keyname" = input_keyname;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_key');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_key"(text) IS 'Delete existing DNS key';

/* API - remove_dns_zone
	1) Check privileges
	2) Delete zone
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_zone"(input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_zone');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on zone %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_zone;
			END IF;
		END IF;

		-- Delete zone
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dns zone');
		DELETE FROM "dns"."zones"
		WHERE "zone" = input_zone;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_zone');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_zone"(text) IS 'Delete existing DNS zone';

/* API - remove_dns_address
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_address"(input_address inet, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.remove_dns_address');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."a" WHERE "address" = input_address AND "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on DNS address %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_address;
			END IF;
		END IF;

		-- Remove record
		PERFORM api.create_log_entry('API', 'INFO', 'deleting address record');
		DELETE FROM "dns"."a" WHERE "address" = input_address AND "zone" = input_zone;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_address"(inet,text) IS 'delete an A or AAAA record';

/* API - remove_dns_mailserver 
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_mailserver"(input_hostname text, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_mailserver');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."mx" WHERE "hostname" = input_hostname AND "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on DNS MX %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_hostname||'.'||input_zone;
			END IF;
		END IF;

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','deleting mailserver (MX)');
		DELETE FROM "dns"."mx" WHERE "hostname" = input_hostname AND "zone" = input_zone;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_mailserver');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_mailserver"(text, text) IS 'Delete an existing MX record for a zone';

/* API - remove_dns_nameserver
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_ns"(input_zone text, input_nameserver text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_ns');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on DNS NS %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_nameserver;
			END IF;
		END IF;

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove NS record');
		DELETE FROM "dns"."ns" WHERE "zone" = input_zone AND "nameserver" = input_nameserver;

		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_ns');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_ns"(text, text) IS 'Remove a DNS NS record from the zone';

/* API - remove_dns_srv
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_srv"(input_alias text, input_zone text, input_priority integer, input_weight integer, input_port integer) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_srv');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."srv" WHERE "alias" = input_alias AND "zone" = input_zone AND "priority" = input_priority AND "weight" = input_weight AND "port" = input_port) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on DNS SRV %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_alias||'.'||input_zone;
			END IF;
		END IF;

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove SRV record');
		DELETE FROM "dns"."srv" WHERE "alias" = input_alias AND "zone" = input_zone AND "priority" = input_priority AND "weight" = input_weight AND "port" = input_port;

		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_srv');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_srv"(text, text, integer, integer, integer) IS 'remove a dns srv record';

/* API - remove_dns_cname
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_cname"(input_alias text, input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_cname');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."cname" WHERE "alias" = input_alias AND "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on DNS CNAME %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_alias||'.'||input_zone;
			END IF;
		END IF;

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove CNAME record');
		DELETE FROM "dns"."cname" WHERE "alias" = input_alias AND "zone" = input_zone;

		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_cname');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_cname"(text, text) IS 'remove a dns cname record for a host';

/* API - remove_dns_txt
	1) Check privileges
	2) Remove record
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_txt"(input_hostname text, input_zone text, input_text text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_txt');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."txt" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "text" = input_text) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on DNS TXT %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_hostname||'.'||input_zone;
			END IF;
		END IF;

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove TXT record');
		DELETE FROM "dns"."txt" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "text" = input_text;

		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_txt');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_txt"(text, text, text) IS 'remove a dns text record for a host';

/* API - remove_dns_soa
	1) Check privileges
	2) Delete soa
*/
CREATE OR REPLACE FUNCTION "api"."remove_dns_soa"(input_zone text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'Begin api.remove_dns_soa');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on zone %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_soa;
			END IF;
		END IF;

		-- Delete soa
		PERFORM api.create_log_entry('API', 'INFO', 'Deleting dns soa');
		DELETE FROM "dns"."soa"
		WHERE "zone" = input_zone;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_soa');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_soa"(text) IS 'Delete existing DNS soa';

CREATE OR REPLACE FUNCTION "api"."remove_dns_zone_txt"(input_hostname text, input_zone text, input_text text) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.remove_dns_zone_txt');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on DNS zone_txt %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_hostname||'.'||input_zone;
			END IF;
		END IF;

		-- Remove record
		PERFORM api.create_log_entry('API','INFO','remove zone_txt record');
		IF input_hostname IS NULL THEN
			DELETE FROM "dns"."zone_txt" WHERE "hostname" IS NULL AND "zone" = input_zone AND "text" = input_text;
		ELSE
			DELETE FROM "dns"."zone_txt" WHERE "hostname" = input_hostname AND "zone" = input_zone AND "text" = input_text;
		END IF;

		PERFORM api.create_log_entry('API','DEBUG','finish api.remove_dns_zone_txt');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_zone_txt"(text, text, text) IS 'remove a dns text record for a host';

CREATE OR REPLACE FUNCTION "api"."remove_dns_zone_a"(input_zone text, input_address inet) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API', 'DEBUG', 'begin api.remove_dns_zone_a');

		-- Check privileges
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			IF (SELECT "owner" FROM "dns"."zones" WHERE "zone" = input_zone) != api.get_current_user() THEN
				PERFORM api.create_log_entry('API','ERROR','Permission denied');
				RAISE EXCEPTION 'Permission denied for % (%) on DNS zone %. You are not owner.',api.get_current_user(),api.get_current_user_level(),input_zone;
			END IF;
		END IF;

		-- Remove record
		PERFORM api.create_log_entry('API', 'INFO', 'deleting zone address record');
		DELETE FROM "dns"."zone_a" WHERE "address" = input_address AND "zone" = input_zone;

		PERFORM api.create_log_entry('API','DEBUG','Finish api.remove_dns_zone_a');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."remove_dns_zone_a"(text, inet) IS 'delete a zone A or AAAA record';