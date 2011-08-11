/* Trigger a_insert 
	1) Check for zone mismatch
	2) Autofill type
*/
CREATE OR REPLACE FUNCTION "dns"."a_insert"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		/*
		-- Check for zone mismatch
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."subnets"
		WHERE "ip"."subnets"."zone" = NEW."zone"
		AND NEW."address" << "ip"."subnets"."subnet";
		IF (RowCount < 1) THEN 
			RAISE EXCEPTION 'IP address and DNS Zone do not match (%, %)',NEW."address",NEW."zone";
		END IF;
		*/
		-- Autofill type
		IF family(NEW."address") = 4 THEN
			NEW."type" := 'A';
		ELSIF family(NEW."address") = 6 THEN
			NEW."type" := 'AAAA';
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."a_insert"() IS 'Creating a new A or AAAA record';

/* Trigger a_update 
	1) New address
	2) New zone
*/
CREATE OR REPLACE FUNCTION "dns"."a_update"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Address/Zone mismatch
		IF NEW."address" != OLD."address" THEN
			SELECT COUNT(*) INTO RowCount
			FROM "ip"."subnets"
			WHERE "ip"."subnets"."zone" = NEW."zone"
			AND NEW."address" << "ip"."subnets"."subnet";
			IF (RowCount < 1) THEN 
				RAISE EXCEPTION 'IP address and DNS Zone do not match (%, %)',NEW."address",NEW."zone";
			END IF;
			
			-- Autofill Type
			IF family(NEW."address") = 4 THEN
				NEW."type" := 'A';
			ELSIF family(NEW."address") = 6 THEN
				NEW."type" := 'AAAA';
			END IF;
		END IF;
		
		-- New zone mismatch
		IF NEW."zone" != OLD."zone" THEN
			SELECT COUNT(*) INTO RowCount
			FROM "ip"."subnets"
			WHERE "ip"."subnets"."zone" = NEW."zone"
			AND NEW."address" << "ip"."subnets"."subnet";
			IF (RowCount < 1) THEN 
				RAISE EXCEPTION 'IP address and DNS Zone do not match (%, %)',NEW."address",NEW."zone";
			END IF;
		END IF;

		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."a_update"() IS 'Update an existing A or AAAA record';

/* Trigger - pointers_insert 
	1) Check if alias name already exists
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."pointers_insert"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Check if alias name already exists
		SELECT COUNT(*) INTO RowCount
		FROM "dns"."a"
		WHERE "dns"."a"."hostname" = NEW."alias";
		IF (RowCount > 0) THEN
			RAISE EXCEPTION 'Alias name (%) already exists',NEW."alias";
		END IF;
		
		-- Autopopulate address
		NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."pointers_insert"() IS 'Check if the alias already exists as an address record';

/* Trigger - pointers_update 
	1) Check if alias name already exists
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."pointers_update"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Check if alias name already exists
		IF NEW."alias" != OLD."alias" THEN	
			SELECT COUNT(*) INTO RowCount
			FROM "dns"."a"
			WHERE "dns"."a"."hostname" = NEW."alias";
			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'Alias name (%) already exists',NEW."alias";
			END IF;
		END IF;
		
		-- Autopopulate address
		IF NEW."address" != OLD."address" THEN
			NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."pointers_update"() IS 'Check if the new alias already exists as an address record';

/* Trigger - ns_insert 
	1) Check for primary NS existance
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."ns_insert"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Check for existing primary NS for zone
		SELECT COUNT(*) INTO RowCount
		FROM "dns"."ns"
		WHERE "dns"."ns"."zone" = NEW."zone" AND "dns"."ns"."isprimary" = TRUE;
		IF NEW."isprimary" = TRUE AND RowCount > 0 THEN
			RAISE EXCEPTION 'Primary NS for zone already exists';
		ELSIF NEW."isprimary" = FALSE AND RowCount = 0 THEN
			RAISE EXCEPTION 'No primary NS for zone exists, and this is not primary. You must specify a primary NS for a zone';
		END IF;

		-- Autopopulate address
		NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");

		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."ns_insert"() IS 'Check that there is only one primary NS registered for a given zone';

/* Trigger - ns_update 
	1) Check for primary NS
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."ns_update"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Check for existing primary NS for zone
		IF (NEW."isprimary" != OLD."isprimary") OR (NEW."zone" != OLD."zone") THEN
			SELECT COUNT(*) INTO RowCount
			FROM "dns"."ns"
			WHERE "dns"."ns"."zone" = NEW."zone" AND "dns"."ns"."isprimary" = TRUE;
			IF NEW."isprimary" = TRUE AND RowCount > 0 THEN
				RAISE EXCEPTION 'Primary NS for zone already exists';
			ELSIF NEW."isprimary" = FALSE AND RowCount = 0 THEN
				RAISE EXCEPTION 'No primary NS for zone exists, and this is not primary. You must specify a primary NS for a zone';
			END IF;
		END IF;
		
		-- Autopopulate address
		IF NEW."address" != OLD."address" THEN
			NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."ns_update"() IS 'Check that the new settings provide for a primary nameserver for the zone';

/* Trigger - mx_insert
	1) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."mx_insert"() RETURNS TRIGGER AS $$
	BEGIN
		NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."mx_insert"() IS 'Create new MX record';

/* Trigger - mx_update
	1) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."mx_update"() RETURNS TRIGGER AS $$
	BEGIN
		IF NEW."address" != OLD."address" THEN
			NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."mx_update"() IS 'Modify a MX record';

/* Trigger - txt_insert
	1) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."txt_insert"() RETURNS TRIGGER AS $$
	BEGIN
		NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."txt_insert"() IS 'Create new TXT record';

/* Trigger - txt_update
	1) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."txt_update"() RETURNS TRIGGER AS $$
	BEGIN
		IF NEW."address" != OLD."address" THEN
			NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."txt_update"() IS 'Modify a TXT record';

/* Trigger - dns_autopopulate_address */
CREATE OR REPLACE FUNCTION "dns"."dns_autopopulate_address"(input_hostname text, input_zone text) RETURNS INET AS $$
	BEGIN
		RETURN (SELECT "dns"."a"."address"
		FROM "dns"."a"
		WHERE "dns"."a"."hostname" = input_hostname
		AND "dns"."a"."zone" = input_zone LIMIT 1);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."dns_autopopulate_address"(text, text) IS 'Fill in the address portion of the foreign key relationship';

CREATE OR REPLACE FUNCTION "dns"."queue_insert"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT;
		DnsKeyName TEXT;
		DnsKey TEXT;
		DnsServer INET;
		DnsRecord TEXT;
		RevZone TEXT;
	BEGIN
		IF (SELECT "config" FROM api.get_system_interface_address(NEW."address")) !~* 'static' THEN
			RETURN NEW;
		END IF;
	
		SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
		INTO DnsKeyName, DnsKey, DnsServer
		FROM "dns"."ns" 
		JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
		JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
		WHERE "dns"."ns"."zone" = NEW."zone" AND "isprimary" IS TRUE;

		IF NEW."type" ~* 'A|AAAA' THEN
			-- Do the forward record first
			DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||host(NEW."address");
			ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);

			-- Check for errors
			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
			END IF;	

			-- Get the proper zone for the reverse A record
			SELECT "zone" INTO RevZone
			FROM "ip"."subnets" 
			WHERE NEW."address" << "subnet";

			-- If it is in this domain, add the reverse entry
			IF RevZone = NEW."zone" THEN
				DnsRecord := api.get_reverse_domain(NEW."address")||' '||NEW."ttl"||' PTR '||NEW."hostname"||'.'||NEW."zone"||'.';
				ReturnCode := api.nsupdate(RevZone,DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			END IF;

		ELSEIF NEW."type" ~* 'NS' THEN
			DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||host(NEW."address");
			ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
		ELSEIF NEW."type" ~* 'MX' THEN
			DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||host(NEW."address");
			ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
		ELSEIF NEW."type" ~* 'SRV|CNAME' THEN
			DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."extra"||' '||NEW."hostname";
			ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
		ELSEIF NEW."type" ~* 'TXT|SPF' THEN
			DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."text";
			ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
		END IF;

		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."queue_insert"() IS 'Add an add directive to the queue';

CREATE OR REPLACE FUNCTION "dns"."queue_update"() RETURNS TRIGGER AS $$
	BEGIN
		IF NEW."type" ~* 'A|AAAA|NS' THEN
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","target")
			VALUES ('DELETE',OLD."hostname",OLD."zone",OLD."ttl",OLD."type",host(OLD."address"));
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","target")
			VALUES ('ADD',NEW."hostname",NEW."zone",NEW."ttl",NEW."type",host(NEW."address"));
		ELSEIF NEW."type" ~* 'MX' THEN
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","extra","target")
			VALUES ('DELETE',OLD."hostname",OLD."zone",OLD."ttl",OLD."type",OLD."preference",host(OLD."address"));
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","extra","target")
			VALUES ('ADD',NEW."hostname",NEW."zone",NEW."ttl",NEW."type",NEW."preference",host(NEW."address"));
		ELSEIF NEW."type" ~* 'SRV|CNAME' THEN
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","extra","target")
			VALUES ('DELETE',OLD."alias",OLD."zone",OLD."ttl",OLD."type",OLD."extra",OLD."hostname");
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","extra","target")
			VALUES ('ADD',NEW."alias",NEW."zone",NEW."ttl",NEW."type",NEW."extra",NEW."hostname");
		ELSEIF NEW."type" ~* 'TXT|SPF' THEN
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","target")
			VALUES ('DELETE',OLD."hostname",OLD."zone",OLD."ttl",OLD."type",OLD."text");
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","target")
			VALUES ('ADD',NEW."hostname",NEW."zone",NEW."ttl",NEW."type",NEW."text");
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."queue_update"() IS 'Add a delete and add directive to the queue';

CREATE OR REPLACE FUNCTION "dns"."queue_delete"() RETURNS TRIGGER AS $$
	BEGIN
		IF OLD."type" ~* 'A|AAAA|NS' THEN
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","target")
			VALUES ('DELETE',OLD."hostname",OLD."zone",OLD."ttl",OLD."type",host(OLD."address"));
		ELSEIF OLD."type" ~* 'MX' THEN
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","extra","target")
			VALUES ('DELETE',OLD."hostname",OLD."zone",OLD."ttl",OLD."type",OLD."preference",host(OLD."address"));
		ELSEIF OLD."type" ~* 'SRV|CNAME' THEN
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","extra","target")
			VALUES ('DELETE',OLD."alias",OLD."zone",OLD."ttl",OLD."type",OLD."extra",OLD."hostname");
		ELSEIF OLD."type" ~* 'TXT|SPF' THEN
			INSERT INTO "dns"."queue" ("directive","hostname","zone","ttl","type","target")
			VALUES ('DELETE',OLD."hostname",OLD."zone",OLD."ttl",OLD."type",OLD."text");
		END IF;
		RETURN OLD;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."queue_delete"() IS 'Add a delete directive to the queue';