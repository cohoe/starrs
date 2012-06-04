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
	DECLARE
		address INET;
	BEGIN
		SELECT "dns"."a"."address" INTO address
		FROM "dns"."a"
		WHERE "dns"."a"."hostname" = input_hostname
		AND "dns"."a"."zone" = input_zone LIMIT 1;
		
		IF address IS NULL THEN
			RAISE EXCEPTION 'Unable to find address for given host % and zone %',input_hostname,input_zone;
		ELSE
			RETURN address;
		END IF;
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
		RevSubnet CIDR;
	BEGIN
		IF (SELECT "config" FROM api.get_system_interface_address(NEW."address")) ~* 'static' THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns" 
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			WHERE "dns"."ns"."zone" = NEW."zone" AND "isprimary" IS TRUE;

			IF NEW."type" ~* '^A|AAAA$' THEN
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

				-- Get the subnet
				SELECT "subnet" INTO RevSubnet
				FROM "ip"."subnets"
				WHERE NEW."address" << "subnet";

				-- If it is in this domain, add the reverse entry
				IF RevZone = NEW."zone" THEN
					DnsRecord := api.get_reverse_domain(NEW."address")||' '||NEW."ttl"||' PTR '||NEW."hostname"||'.'||NEW."zone"||'.';
					ReturnCode := api.nsupdate(api.get_reverse_domain(RevSubnet),DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
				END IF;

			ELSEIF NEW."type" ~* '^NS$' THEN
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||host(NEW."address");
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^MX$' THEN
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||host(NEW."address");
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^SRV|CNAME$' THEN
				IF NEW."extra" IS NULL THEN
					DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."hostname"||'.'||NEW."zone";
				ELSE	
					DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."extra"||' '||NEW."hostname"||'.'||NEW."zone";
				END IF;
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^TXT$' THEN
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."text";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			END IF;

			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
			END IF;
		ELSE 
			SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns" 
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			WHERE "dns"."ns"."zone" = NEW."zone" AND "isprimary" IS TRUE;

			IF NEW."type" ~* '^NS$' THEN
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||host(NEW."address");
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^MX$' THEN
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||host(NEW."address");
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^SRV|CNAME$' THEN
				IF NEW."extra" IS NULL THEN
					DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."hostname"||'.'||NEW."zone";
				ELSE	
					DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."extra"||' '||NEW."hostname"||'.'||NEW."zone";
				END IF;
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^TXT$' THEN
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."text";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			END IF;

			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
			END IF;
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."queue_insert"() IS 'Add an add directive to the queue';

CREATE OR REPLACE FUNCTION "dns"."queue_update"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT;
		DnsKeyName TEXT;
		DnsKey TEXT;
		DnsServer INET;
		DnsRecord TEXT;
		RevZone TEXT;
		RevSubnet CIDR;
	BEGIN
		IF (SELECT "config" FROM api.get_system_interface_address(NEW."address")) ~* 'static' THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns" 
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			WHERE "dns"."ns"."zone" = NEW."zone" AND "isprimary" IS TRUE;
			
			IF NEW."type" ~* '^A|AAAA$' THEN
				-- Do the forward record first
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||host(OLD."address");
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);

				-- Check for errors
				IF ReturnCode != '0' THEN
					RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
				END IF;	

				-- Get the proper zone for the reverse A record
				SELECT "zone" INTO RevZone
				FROM "ip"."subnets" 
				WHERE OLD."address" << "subnet";
				
				-- Get the subnet
				SELECT "subnet" INTO RevSubnet
				FROM "ip"."subnets"
				WHERE OLD."address" << "subnet";

				-- If it is in this domain, add the reverse entry
				IF RevZone = OLD."zone" THEN
					DnsRecord := api.get_reverse_domain(OLD."address")||' '||OLD."ttl"||' PTR '||OLD."hostname"||'.'||OLD."zone"||'.';
					ReturnCode := Returncode||api.nsupdate(api.get_reverse_domain(RevSubnet),DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				END IF;

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

				-- Get the subnet
				SELECT "subnet" INTO RevSubnet
				FROM "ip"."subnets"
				WHERE NEW."address" << "subnet";

				-- If it is in this domain, add the reverse entry
				IF RevZone = NEW."zone" THEN
					DnsRecord := api.get_reverse_domain(NEW."address")||' '||NEW."ttl"||' PTR '||NEW."hostname"||'.'||NEW."zone"||'.';
					ReturnCode := Returncode||api.nsupdate(api.get_reverse_domain(RevSubnet),DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
				END IF;

			ELSEIF NEW."type" ~* '^NS$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||host(OLD."address");
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||host(NEW."address");
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^MX$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."preference"||' '||host(OLD."address");
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||host(NEW."address");
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^SRV|CNAME$' THEN
				IF OLD."extra" IS NULL THEN
					DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."hostname"||'.'||OLD."zone";
				ELSE	
					DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."extra"||' '||OLD."hostname"||'.'||OLD."zone";
				END IF;
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			
				IF NEW."extra" IS NULL THEN
					DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."hostname"||'.'||NEW."zone";
				ELSE	
					DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."extra"||' '||NEW."hostname"||'.'||NEW."zone";
				END IF;
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^TXT$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."text";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."text";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			END IF;
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns" 
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			WHERE "dns"."ns"."zone" = NEW."zone" AND "isprimary" IS TRUE;

			IF NEW."type" ~* '^NS$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||host(OLD."address");
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||host(NEW."address");
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^MX$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."preference"||' '||host(OLD."address");
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||host(NEW."address");
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^SRV|CNAME$' THEN
				IF OLD."extra" IS NULL THEN
					DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."hostname"||'.'||OLD."zone";
				ELSE	
					DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."extra"||' '||OLD."hostname"||'.'||OLD."zone";
				END IF;
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			
				IF NEW."extra" IS NULL THEN
					DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."hostname"||'.'||NEW."zone";
				ELSE	
					DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."extra"||' '||NEW."hostname"||'.'||NEW."zone";
				END IF;
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^TXT$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."text";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."text";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			END IF;

			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
			END IF;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."queue_update"() IS 'Add a delete then add directive to the queue';

CREATE OR REPLACE FUNCTION "dns"."queue_delete"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT;
		DnsKeyName TEXT;
		DnsKey TEXT;
		DnsServer INET;
		DnsRecord TEXT;
		RevZone TEXT;
		RevSubnet CIDR;
	BEGIN
		IF (SELECT "config" FROM api.get_system_interface_address(OLD."address")) ~* 'static' THEN
	
			SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns" 
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			WHERE "dns"."ns"."zone" = OLD."zone" AND "isprimary" IS TRUE;

			IF OLD."type" ~* '^A|AAAA$' THEN
				-- Do the forward record first
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||host(OLD."address");
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);

				-- Check for errors
				IF ReturnCode != '0' THEN
					RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
				END IF;	

				-- Get the proper zone for the reverse A record
				SELECT "zone" INTO RevZone
				FROM "ip"."subnets" 
				WHERE OLD."address" << "subnet";
				
				-- Get the subnet
				SELECT "subnet" INTO RevSubnet
				FROM "ip"."subnets"
				WHERE OLD."address" << "subnet";

				-- If it is in this domain, add the reverse entry
				IF RevZone = OLD."zone" THEN
					DnsRecord := api.get_reverse_domain(OLD."address")||' '||OLD."ttl"||' PTR '||OLD."hostname"||'.'||OLD."zone"||'.';
					ReturnCode := api.nsupdate(api.get_reverse_domain(RevSubnet),DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				END IF;

			ELSEIF OLD."type" ~* '^NS$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||host(OLD."address");
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^MX$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."preference"||' '||host(OLD."address");
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^SRV|CNAME$' THEN
				IF OLD."extra" IS NULL THEN
					DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."hostname"||'.'||OLD."zone";
				ELSE	
					DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."extra"||' '||OLD."hostname"||'.'||OLD."zone";
				END IF;
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^TXT$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."text";
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			END IF;

			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
			END IF;
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns" 
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			WHERE "dns"."ns"."zone" = OLD."zone" AND "isprimary" IS TRUE;

			IF OLD."type" ~* '^NS$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||host(OLD."address");
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^MX$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."preference"||' '||host(OLD."address");
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^SRV|CNAME$' THEN
				IF OLD."extra" IS NULL THEN
					DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."hostname"||'.'||OLD."zone";
				ELSE	
					DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."extra"||' '||OLD."hostname"||'.'||OLD."zone";
				END IF;
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^TXT$' THEN
				DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."text";
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			END IF;

			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
			END IF;
		END IF;
		
		RETURN OLD;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."queue_delete"() IS 'Add a delete directive to the queue';

/* Trigger - srv_insert 
	1) Check if alias name already exists
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."srv_insert"() RETURNS TRIGGER AS $$
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
		
		SELECT COUNT(*) INTO RowCount
		FROM "dns"."cname"
		WHERE "dns"."cname"."alias" = NEW."alias";
		IF (RowCount > 0) THEN
			RAISE EXCEPTION 'Alias name (%) already exists as a CNAME',NEW."alias";
		END IF;
		
		-- Autopopulate address
		NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."srv_insert"() IS 'Check if the alias already exists as an address record';

/* Trigger - srv_update 
	1) Check if alias name already exists
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."srv_update"() RETURNS TRIGGER AS $$
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
			
			SELECT COUNT(*) INTO RowCount
			FROM "dns"."cname"
			WHERE "dns"."cname"."alias" = NEW."alias";
			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'Alias name (%) already exists as a CNAME',NEW."alias";
			END IF;
		END IF;
		
		-- Autopopulate address
		IF NEW."address" != OLD."address" THEN
			NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."srv_update"() IS 'Check if the new alias already exists as an address record';

/* Trigger - cname_insert 
	1) Check if alias name already exists
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."cname_insert"() RETURNS TRIGGER AS $$
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
		
		SELECT COUNT(*) INTO RowCount
		FROM "dns"."srv"
		WHERE "dns"."srv"."alias" = NEW."alias";
		IF (RowCount > 0) THEN
			RAISE EXCEPTION 'Alias name (%) already exists as a SRV',NEW."alias";
		END IF;
		
		-- Autopopulate address
		NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."cname_insert"() IS 'Check if the alias already exists as an address record';

/* Trigger - cname_update 
	1) Check if alias name already exists
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."cname_update"() RETURNS TRIGGER AS $$
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
			
			SELECT COUNT(*) INTO RowCount
			FROM "dns"."srv"
			WHERE "dns"."srv"."alias" = NEW."alias";
			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'Alias name (%) already exists as a SRV',NEW."alias";
			END IF;
		END IF;
		
		-- Autopopulate address
		IF NEW."address" != OLD."address" THEN
			NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."cname_update"() IS 'Check if the new alias already exists as an address record';