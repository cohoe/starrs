/* api_dns_utility.sql
	1) get_reverse_domain
	2) validate_domain
	3) validate_srv
*/



/* API - dns_resolve */
CREATE OR REPLACE FUNCTION "api"."dns_resolve"(input_hostname text, input_zone text, input_family integer) RETURNS INET AS $$
	BEGIN
		IF input_family IS NULL THEN
			RETURN (SELECT "address" FROM "dns"."a" WHERE "hostname" = input_hostname AND "zone" = input_zone LIMIT 1);
		ELSE
			RETURN (SELECT "address" FROM "dns"."a" WHERE "hostname" = input_hostname AND "zone" = input_zone AND family("address") = input_family);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."dns_resolve"(text, text, integer) IS 'Resolve a hostname/zone to its IP address';


/* API - check_dns_hostname */
CREATE OR REPLACE FUNCTION "api"."check_dns_hostname"(input_hostname text, input_zone text) RETURNS BOOLEAN AS $$
	DECLARE
		RowCount INTEGER := 0;
	BEGIN
		RowCount := RowCount + (SELECT COUNT(*) FROM "dns"."a" WHERE "hostname" = input_hostname AND "zone" = input_zone);
		RowCount := RowCount + (SELECT COUNT(*) FROM "dns"."srv" WHERE "alias" = input_hostname AND "zone" = input_zone);
		RowCount := RowCount + (SELECT COUNT(*) FROM "dns"."cname" WHERE "alias" = input_hostname AND "zone" = input_zone);

		IF RowCount = 0 THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."check_dns_hostname"(text, text) IS 'Check if a hostname is available in a given zone';

/* API - nslookup*/
CREATE OR REPLACE FUNCTION "api"."nslookup"(input_address inet) RETURNS TABLE(fqdn TEXT) AS $$
	BEGIN
		RETURN QUERY (SELECT "hostname"||'.'||"zone" FROM "dns"."a" WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."nslookup"(inet) IS 'Get the DNS name of an IP address in the database';



CREATE OR REPLACE FUNCTION "api"."dns_zone_audit"(input_zone text) RETURNS SETOF "dns"."zone_audit_data" AS $$
       BEGIN
			-- Create a temporary table to store record data in
            DROP TABLE IF EXISTS "audit";
            CREATE TEMPORARY TABLE "audit" (
			host TEXT, ttl INTEGER, type TEXT, address INET, port INTEGER, weight INTEGER, priority INTEGER, preference INTEGER, target TEXT, text TEXT, contact TEXT, serial TEXT, refresh INTEGER, retry INTEGER, expire INTEGER, minimum INTEGER);
				   
			-- Put AXFR data into the table
			IF (SELECT "forward" FROM "dns"."zones" WHERE "zone" = input_zone) IS TRUE THEN
				INSERT INTO "audit"
				(SELECT * FROM "api"."query_axfr"(input_zone, (SELECT "nameserver" FROM "dns"."soa" WHERE "zone" = input_zone)));
			ELSE
				INSERT INTO "audit" (SELECT * FROM "api"."query_axfr"(input_zone, (SELECT "nameserver" FROM "dns"."soa" WHERE "zone" = (SELECT "zone" FROM "ip"."subnets" WHERE api.get_reverse_domain("subnet") = input_zone))));
			END IF;
			
			-- Update the SOA table with the latest serial
			PERFORM api.modify_dns_soa(input_zone,'serial',(SELECT "api"."query_zone_serial"(input_zone)));
			
			IF (SELECT "forward" FROM "dns"."zones" WHERE "zone" = input_zone) IS TRUE THEN
				-- Remove all records that IMPULSE contains
				DELETE FROM "audit" WHERE ("host","ttl","type","address") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type","address" FROM "dns"."a");
				DELETE FROM "audit" WHERE ("host","ttl","type","target","port","weight","priority") IN (SELECT "alias"||'.'||"zone" AS "host","ttl","type","hostname"||'.'||"zone" as "target","port","weight","priority" FROM "dns"."srv");
				DELETE FROM "audit" WHERE ("host","ttl","type","target") IN (SELECT "alias"||'.'||"zone" AS "host","ttl","type","hostname"||'.'||"zone" as "target" FROM "dns"."cname");
				DELETE FROM "audit" WHERE ("host","ttl","type","preference") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type","preference" FROM "dns"."mx");
				DELETE FROM "audit" WHERE ("host","ttl","type") IN (SELECT "nameserver" AS "host","ttl","type" FROM "dns"."ns");
				DELETE FROM "audit" WHERE ("host","ttl","type","text") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type","text" FROM "dns"."txt");
				DELETE FROM "audit" WHERE ("host","ttl","type","target","contact","serial","refresh","retry","expire","minimum") IN 
				(SELECT "zone" as "host","ttl",'SOA'::text as "type","nameserver" as "target","contact","serial","refresh","retry","expire","minimum" FROM "dns"."soa");
				DELETE FROM "audit" WHERE ("host","ttl","type","text") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type","text" FROM "dns"."zone_txt");
				DELETE FROM "audit" WHERE ("host","ttl","type","text") IN (SELECT "zone" AS "host","ttl","type","text" FROM "dns"."zone_txt");
				DELETE FROM "audit" WHERE ("host","ttl","type","address") IN (SELECT "zone" AS "host","ttl","type","address" FROM "dns"."zone_a");
				
				-- DynamicDNS records have TXT data placed by the DHCP server. Don't count those.
				DELETE FROM "audit" WHERE ("host") IN (SELECT "hostname"||'.'||"zone" AS "host" FROM "api"."get_dhcpd_dynamic_hosts"() WHERE "hostname" IS NOT NULL) AND "type" = 'TXT';
				-- So do DHCP'd records;
				DELETE FROM "audit" WHERE ("host") IN (SELECT "hostname"||'.'||"zone" AS "host" FROM "dns"."a" JOIN "systems"."interface_addresses" ON "systems"."interface_addresses"."address" = "dns"."a"."address" WHERE "config"='dhcp') AND "type"='TXT';
			ELSE
				-- Remove constant address records
				DELETE FROM "audit" WHERE ("host","target","type") IN (SELECT api.get_reverse_domain("address") as "host","hostname"||'.'||"zone" as "target",'PTR'::text AS "type" FROM "dns"."a");
				-- Remove Dynamics
				DELETE FROM "audit" WHERE ("target","type") IN (SELECT "hostname"||'.'||"zone" as "target",'PTR'::text AS "type" FROM "dns"."a" JOIN "systems"."interface_addresses" ON "systems"."interface_addresses"."address" = "dns"."a"."address" WHERE "config"='dhcp');
				-- Remove NS records;
				DELETE FROM "audit" WHERE ("host","ttl","type") IN (SELECT "nameserver" AS "host","ttl","type" FROM "dns"."ns");
				-- Remove SOA;
				DELETE FROM "audit" WHERE ("host","ttl","type","target","contact","serial","refresh","retry","expire","minimum") IN 
				(SELECT "zone" as "host","ttl",'SOA'::text as "type","nameserver" as "target","contact","serial","refresh","retry","expire","minimum" FROM "dns"."soa" WHERE "zone" = input_zone);
				-- Remove TXT
				DELETE FROM "audit" WHERE ("host","ttl","type","text") IN (SELECT "hostname"||'.'||"zone" AS "host","ttl","type","text" FROM "dns"."zone_txt");
				DELETE FROM "audit" WHERE ("host","ttl","type","text") IN (SELECT "zone" AS "host","ttl","type","text" FROM "dns"."zone_txt");
			END IF;
            
			-- What's left is data that IMPULSE has no idea of
            RETURN QUERY (SELECT * FROM "audit");
       END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."dns_zone_audit"(text) IS 'Perform an audit of IMPULSE zone data against server zone data';


CREATE OR REPLACE FUNCTION "api"."dns_clean_zone_a"(input_zone text) RETURNS VOID AS $$
	DECLARE
		AuditData RECORD;
		DnsKeyName TEXT;
		DnsKey TEXT;
		DnsServer INET;
		DnsRecord TEXT;
		ReturnCode TEXT;
		
	BEGIN
		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Non-admin users are not allowed to clean zones';
		END IF;
		
		SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns" 
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			WHERE "dns"."ns"."zone" = input_zone AND "dns"."ns"."nameserver" IN (SELECT "nameserver" FROM "dns"."soa" WHERE "dns"."soa"."zone" = input_zone);
			
		FOR AuditData IN (
			SELECT 
				"audit_data"."address",
				"audit_data"."type",
				"host" AS "bind-forward", 
				"dns"."a"."hostname"||'.'||"dns"."a"."zone" AS "impulse-forward"
			FROM api.dns_zone_audit(input_zone) AS "audit_data" 
			LEFT JOIN "dns"."a" ON "dns"."a"."address" = "audit_data"."address" 
			WHERE "audit_data"."type" ~* '^A|AAAA$'
			ORDER BY "audit_data"."address"
		) LOOP
			-- Delete the forward
			DnsRecord := AuditData."bind-forward";
			ReturnCode := api.nsupdate(input_zone,DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when deleting forward %',ReturnCode,DnsRecord;
			END IF;
			
			-- If it's static, create the correct one
			IF (SELECT "config" FROM "systems"."interface_addresses" WHERE "address" = AuditData."address") ~* 'static' AND AuditData."impulse-forward" IS NOT NULL THEN
				-- Forward
				DnsRecord := AuditData."impulse-forward"||' '||AuditData."ttl"||' '||AuditData."type"||' '||host(AuditData."address");
				ReturnCode := api.nsupdate(input_zone,DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
				IF ReturnCode != '0' THEN
					RAISE EXCEPTION 'DNS Error: % when creating forward %',ReturnCode,DnsRecord;
				END IF;
			END IF;
		END LOOP;
		
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."dns_clean_zone_a"(text) IS 'Erase all non-IMPULSE controlled A records from a zone.';

CREATE OR REPLACE FUNCTION "api"."dns_clean_zone_ptr"(input_zone text) RETURNS VOID AS $$
	DECLARE
		AuditData RECORD;
		DnsKeyName TEXT;
		DnsKey TEXT;
		DnsServer INET;
		DnsRecord TEXT;
		ReturnCode TEXT;
		
	BEGIN
		
		IF (api.get_current_user_level() !~* 'ADMIN') THEN
			RAISE EXCEPTION 'Non-admin users are not allowed to clean zones';
		END IF;
		
		SELECT "dns"."keys"."keyname","dns"."keys"."key","dns"."ns"."address"
		INTO DnsKeyName, DnsKey, DnsServer
		FROM "dns"."ns"
		JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone"
		JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
		JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."ns"."zone"
		WHERE "dns"."ns"."nameserver" = "dns"."soa"."nameserver"
		AND "dns"."ns"."zone" = (SELECT "ip"."subnets"."zone" FROM "ip"."subnets" WHERE api.get_reverse_domain("subnet") = input_zone);
	
		FOR AuditData IN (
			SELECT 
			"audit_data"."host",
			"audit_data"."target" AS "bind-reverse",
			"dns"."a"."hostname"||'.'||"dns"."a"."zone" AS "impulse-reverse",
			"dns"."a"."ttl" AS "ttl",
			"audit_data"."type" AS "type"
			FROM api.dns_zone_audit(input_zone) AS "audit_data"
			LEFT JOIN "dns"."a" ON api.get_reverse_domain("dns"."a"."address") = "audit_data"."host"
			WHERE "audit_data"."type"='PTR'
		) LOOP
			DnsRecord := AuditData."host";
			ReturnCode := api.nsupdate(input_zone,DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when deleting reverse %',ReturnCode,DnsRecord;
			END IF;
			
			IF (SELECT "config" FROM "systems"."interface_addresses" WHERE api.get_reverse_domain("address") = AuditData."host") ~* 'static' AND AuditData."impulse-reverse" IS NOT NULL THEN
				DnsRecord := AuditData."host"||' '||AuditData."ttl"||' '||AuditData."type"||' '||AuditData."impulse-reverse";
				ReturnCode := api.nsupdate(input_zone,DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
				IF ReturnCode != '0' THEN
					RAISE EXCEPTION 'DNS Error: % when creating reverse %',ReturnCode,DnsRecord;
				END IF;
			END IF;
			
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."dns_clean_zone_ptr"(text) IS 'Clean all incorrect pointer records in a reverse zone';


