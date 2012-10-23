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

CREATE OR REPLACE FUNCTION "dns"."ns_query_insert"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT; -- Return code from the nsupdate function
		DnsKeyName TEXT; -- The DNS keyname to sign with
		DnsKey TEXT; -- The DNS key to sign with
		DnsServer INET; -- The nameserver to send the update to
		DnsRecord TEXT; -- The formatted string that is the record
	BEGIN
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = NEW."zone") IS FALSE THEN
			RETURN NEW;
		END IF;
		
		-- If this is a forward zone:
		IF (SELECT "forward" FROM "dns"."zones" WHERE "zone" = NEW."zone") IS TRUE THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key","address" 
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns" 
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone" 
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			WHERE "dns"."ns"."zone" = NEW."zone" AND "dns"."ns"."nameserver" IN (SELECT "nameserver" FROM "dns"."soa" WHERE "dns"."soa"."zone" = NEW."zone");
		-- If this is a reverse zone:
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key","dns"."ns"."address"
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."ns"
			JOIN "dns"."zones" ON "dns"."ns"."zone" = "dns"."zones"."zone"
			JOIN "dns"."keys" ON "dns"."zones"."keyname" = "dns"."keys"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."ns"."zone"
			WHERE "dns"."ns"."nameserver" = "dns"."soa"."nameserver"
			AND "dns"."ns"."zone" = (SELECT "ip"."subnets"."zone" FROM "ip"."subnets" WHERE api.get_reverse_domain("subnet") = NEW."zone");
		END IF;
		
		-- Just make sure no-one is forcing a bogus type
		IF NEW."type" !~* '^NS$' THEN
			RAISE EXCEPTION 'Trying to create a non-NS record in an NS table!';
		END IF;
		
		-- Create and fire off the update
		DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."nameserver";
		ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
		
		-- Check for result
		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
		END IF;
		
		-- Done!
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."ns_query_insert"() IS 'Update the nameserver with a new NS record';

CREATE OR REPLACE FUNCTION "dns"."ns_query_update"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT; -- Return code from the nsupdate function
		DnsKeyName TEXT; -- The DNS keyname to sign with
		DnsKey TEXT; -- The DNS key to sign with
		DnsServer INET; -- The nameserver to send the update to
		DnsRecord TEXT; -- The formatted string that is the record
	BEGIN
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = OLD."zone") IS FALSE THEN
			RETURN NEW;
		END IF;
		
		-- If this is a forward zone:
		IF (SELECT "forward" FROM "dns"."zones" WHERE "zone" = NEW."zone") IS TRUE THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = NEW."zone";
		-- If this is a reverse zone:
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."ns"."zone" = (SELECT "ip"."subnets"."zone" FROM "ip"."subnets" WHERE api.get_reverse_domain("subnet") = NEW."zone");
		END IF;
		
		-- Just make sure no-one is forcing a bogus type
		IF NEW."type" !~* '^NS$' THEN
			RAISE EXCEPTION 'Trying to create a non-NS record in an NS table!';
		END IF;
		
		-- Delete the record first
		DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."nameserver";
		ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
		
		-- Check for result
		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing NS-UPDATE-DELETE %',ReturnCode,DnsRecord;
		END IF;
		
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = NEW."zone") IS FALSE THEN
			RETURN NEW;
		END IF;
		
		-- Create and fire off the update
		DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."nameserver";
		ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
		
		-- Check for result
		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing NS-UPDATE-INSERT %',ReturnCode,DnsRecord;
		END IF;
		
		-- Done!
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."ns_query_update"() IS 'Update the nameserver with a new NS record';

CREATE OR REPLACE FUNCTION "dns"."ns_query_delete"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT; -- Return code from the nsupdate function
		DnsKeyName TEXT; -- The DNS keyname to sign with
		DnsKey TEXT; -- The DNS key to sign with
		DnsServer INET; -- The nameserver to send the update to
		DnsRecord TEXT; -- The formatted string that is the record
	BEGIN
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = OLD."zone") IS FALSE THEN
			RETURN OLD;
		END IF;
		
		-- If this is a forward zone:
		IF (SELECT "forward" FROM "dns"."zones" WHERE "zone" = OLD."zone") IS TRUE THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = OLD."zone";
		-- If this is a reverse zone:
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."ns"."zone" = (SELECT "ip"."subnets"."zone" FROM "ip"."subnets" WHERE api.get_reverse_domain("subnet") = OLD."zone");
		END IF;
		
		-- Just make sure no-one is forcing a bogus type
		IF OLD."type" !~* '^NS$' THEN
			RAISE EXCEPTION 'Trying to create a non-NS record in an NS table!';
		END IF;
		
		-- Create and fire off the update
		DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."nameserver";
		ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
		
		-- Check for result
		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing NS-DELETE %',ReturnCode,DnsRecord;
		END IF;
		
		-- Done!
		RETURN OLD;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."ns_query_delete"() IS 'Delete an old NS record from the server';

CREATE OR REPLACE FUNCTION "dns"."txt_query_insert"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT; -- Return code from the nsupdate function
		DnsKeyName TEXT; -- The DNS keyname to sign with
		DnsKey TEXT; -- The DNS key to sign with
		DnsServer INET; -- The nameserver to send the update to
		DnsRecord TEXT; -- The formatted string that is the record
	BEGIN
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = NEW."zone") IS FALSE THEN
			RETURN NEW;
		END IF;
		
		-- If this is a forward zone:
		IF (SELECT "forward" FROM "dns"."zones" WHERE "zone" = NEW."zone") IS TRUE THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = NEW."zone";
		-- If this is a reverse zone:
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."ns"."zone" = (SELECT "ip"."subnets"."zone" FROM "ip"."subnets" WHERE api.get_reverse_domain("subnet") = NEW."zone");
		END IF;
		
		-- Just make sure no-one is forcing a bogus type
		IF NEW."type" !~* '^TXT$' THEN
			RAISE EXCEPTION 'Trying to create a non-TXT record in a TXT table!';
		END IF;
		
		-- Create and fire off the update
		-- For zone TXT records
		IF NEW."hostname" IS NULL THEN
			DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
		ELSE
			DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
		END IF;
		ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
		
		-- Check for result
		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing TXT-INSERT %',ReturnCode,DnsRecord;
		END IF;
		
		-- Done!
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."txt_query_insert"() IS 'Update the nameserver with a new TXT record';

CREATE OR REPLACE FUNCTION "dns"."txt_query_update"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT; -- Return code from the nsupdate function
		DnsKeyName TEXT; -- The DNS keyname to sign with
		DnsKey TEXT; -- The DNS key to sign with
		DnsServer INET; -- The nameserver to send the update to
		DnsRecord TEXT; -- The formatted string that is the record
	BEGIN
		-- If this is a forward zone:
		IF (SELECT "forward" FROM "dns"."zones" WHERE "zone" = NEW."zone") IS TRUE THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = NEW."zone";
		-- If this is a reverse zone:
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."ns"."zone" = (SELECT "ip"."subnets"."zone" FROM "ip"."subnets" WHERE api.get_reverse_domain("subnet") = NEW."zone");
		END IF;
		
		-- Just make sure no-one is forcing a bogus type
		IF NEW."type" !~* '^TXT$' THEN
			RAISE EXCEPTION 'Trying to update a non-TXT record in a TXT table!';
		END IF;
		
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = OLD."zone") IS FALSE THEN
			RETURN NEW;
		END IF;
		
		-- Delete the record first
		IF OLD."hostname" IS NULL THEN
			DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
		ELSE
			DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
		END IF;
		ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
		
		-- Check for result
		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing TXT-UPDATE-DELETE %',ReturnCode,DnsRecord;
		END IF;
		
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = NEW."zone") IS FALSE THEN
			RETURN NEW;
		END IF;
	
		-- Create and fire off the update
		IF NEW."hostname" IS NULL THEN
			DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
		ELSE
			DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
		END IF;
		ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
		
		-- Check for result
		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing TXT-UPDATE-INSERT %',ReturnCode,DnsRecord;
		END IF;
		
		-- Done!
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."txt_query_update"() IS 'Update the nameserver with a new TXT record';

CREATE OR REPLACE FUNCTION "dns"."txt_query_delete"() RETURNS TRIGGER AS $$
	DECLARE
		ReturnCode TEXT; -- Return code from the nsupdate function
		DnsKeyName TEXT; -- The DNS keyname to sign with
		DnsKey TEXT; -- The DNS key to sign with
		DnsServer INET; -- The nameserver to send the update to
		DnsRecord TEXT; -- The formatted string that is the record
	BEGIN
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = OLD."zone") IS FALSE THEN
			RETURN OLD;
		END IF;
		
		-- If this is a forward zone:
		IF (SELECT "forward" FROM "dns"."zones" WHERE "zone" = OLD."zone") IS TRUE THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = OLD."zone";
		-- If this is a reverse zone:
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."ns"."zone" = (SELECT "ip"."subnets"."zone" FROM "ip"."subnets" WHERE api.get_reverse_domain("subnet") = OLD."zone");
		END IF;
		
		-- Just make sure no-one is forcing a bogus type
		IF OLD."type" !~* '^TXT$' THEN
			RAISE EXCEPTION 'Trying to delete a non-TXT record in a TXT table!';
		END IF;
		
		-- Create and fire off the update
		-- For zone TXT records
		IF OLD."hostname" IS NULL THEN
			DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
		ELSE
			DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
		END IF;
		ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
		
		-- Check for result
		IF ReturnCode != '0' THEN
			RAISE EXCEPTION 'DNS Error: % when performing TXT-DELETE %',ReturnCode,DnsRecord;
		END IF;
		
		-- Done!
		RETURN OLD;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."txt_query_delete"() IS 'Delete an old TXT record from the server';

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
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = NEW."zone") IS FALSE THEN
			RETURN NEW;
		END IF;
		
		IF (SELECT "config" FROM api.get_system_interface_address(NEW."address")) ~* 'static|autoconf' THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = NEW."zone";

			IF NEW."type" ~* '^A|AAAA$' THEN
				--NULL hostname means zone address
				IF NEW."hostname" IS NULL THEN
					DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||host(NEW."address");
					ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
				ELSE
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
					IF RevZone = NEW."zone" AND NEW."reverse" IS TRUE THEN
						DnsRecord := api.get_reverse_domain(NEW."address")||' '||NEW."ttl"||' PTR '||NEW."hostname"||'.'||NEW."zone"||'.';
						ReturnCode := api.nsupdate(api.get_reverse_domain(RevSubnet),DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
					END IF;
				END IF;

			ELSEIF NEW."type" ~* '^NS$' THEN
				DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."nameserver";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^MX$' THEN
				DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^SRV$' THEN	
				DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."priority"||' '||NEW."weight"||' '||NEW."port"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^CNAME$' THEN
				DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^TXT$' THEN
				-- For zone TXT records
				IF NEW."hostname" IS NULL THEN
					DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
				ELSE
					DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
				END IF;
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			END IF;

			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
			END IF;
		ELSE 
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = NEW."zone";

			IF NEW."type" ~* '^NS$' THEN
				DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."nameserver";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^MX$' THEN
				DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^SRV$' THEN	
				DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."priority"||' '||NEW."weight"||' '||NEW."port"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^CNAME$' THEN
				DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^TXT$' THEN
				-- For zone TXT records
				IF NEW."hostname" IS NULL THEN
					DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
				ELSE
					DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
				END IF;
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
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = NEW."zone") IS FALSE THEN
			RETURN NEW;
		END IF;
		
		IF (SELECT "config" FROM api.get_system_interface_address(NEW."address")) ~* 'static|autoconf' THEN
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = NEW."zone";
			
			IF NEW."type" ~* '^A|AAAA$' THEN
				--NULL hostname means zone address
				IF NEW."hostname" IS NULL THEN
					DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||host(OLD."address");
					ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
					DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||host(NEW."address");
					ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
				ELSE
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
					IF RevZone = OLD."zone" AND OLD."reverse" IS TRUE THEN
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
					IF RevZone = NEW."zone" AND NEW."reverse" IS TRUE THEN
						DnsRecord := api.get_reverse_domain(NEW."address")||' '||NEW."ttl"||' PTR '||NEW."hostname"||'.'||NEW."zone"||'.';
						ReturnCode := Returncode||api.nsupdate(api.get_reverse_domain(RevSubnet),DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
					END IF;
				END IF;

			ELSEIF NEW."type" ~* '^NS$' THEN
				DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."nameserver";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."nameserver";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^MX$' THEN
				DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."preference"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^SRV$' THEN
				DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."priority"||' '||OLD."weight"||' '||OLD."port"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			
				DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."priority"||' '||NEW."weight"||' '||NEW."port"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^CNAME$' THEN
				DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			
				DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^TXT$' THEN
				-- For zone TXT records
				IF OLD."hostname" IS NULL THEN
					DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
				ELSE
					DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
				END IF;
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			
				IF NEW."hostname" IS NULL THEN
					DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
				ELSE
					DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
				END IF;
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			END IF;
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = NEW."zone";

			IF NEW."type" ~* '^NS$' THEN
				DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."nameserver";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."nameserver";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^MX$' THEN
				DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."preference"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				
				DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."preference"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^SRV$' THEN
				DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."priority"||' '||OLD."weight"||' '||OLD."port"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			
				DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."priority"||' '||NEW."weight"||' '||NEW."port"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^CNAME$' THEN
				DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			
				DnsRecord := NEW."alias"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' '||NEW."hostname"||'.'||NEW."zone";
				ReturnCode := Returncode||api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
			ELSEIF NEW."type" ~* '^TXT$' THEN
				-- For zone TXT records
				IF OLD."hostname" IS NULL THEN
					DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
				ELSE
					DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
				END IF;
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			
				IF NEW."hostname" IS NULL THEN
					DnsRecord := NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
				ELSE
					DnsRecord := NEW."hostname"||'.'||NEW."zone"||' '||NEW."ttl"||' '||NEW."type"||' "'||NEW."text"||'"';
				END IF;
				ReturnCode := api.nsupdate(NEW."zone",DnsKeyName,DnsKey,DnsServer,'ADD',DnsRecord);
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
		IF (SELECT "ddns" FROM "dns"."zones" WHERE "dns"."zones"."zone" = OLD."zone") IS FALSE THEN
			RETURN OLD;
		END IF;


	     -- This needs cleaned up a lot. See github bug #211 for more details. This fix works but is
		-- not exactly great.
		IF true THEN
	
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = OLD."zone";

			IF OLD."type" ~* '^A|AAAA$' THEN
				--NULL hostname means zone address
				IF OLD."hostname" IS NULL THEN
					DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||host(OLD."address");
					ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
				ELSE
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
					IF RevZone = OLD."zone" AND OLD."reverse" IS TRUE AND OLD."address" !<< api.get_site_configuration('DYNAMIC_SUBNET') THEN
						DnsRecord := api.get_reverse_domain(OLD."address")||' '||OLD."ttl"||' PTR '||OLD."hostname"||'.'||OLD."zone"||'.';
						ReturnCode := api.nsupdate(api.get_reverse_domain(RevSubnet),DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
					END IF;
				END IF;

			ELSEIF OLD."type" ~* '^NS$' THEN
				DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."nameserver";
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^MX$' THEN
				DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."preference"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^SRV$' THEN
				DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."priority"||' '||OLD."weight"||' '||OLD."port"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^CNAME$' THEN
				DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^TXT$' THEN
				-- For zone TXT records
				IF OLD."hostname" IS NULL THEN
					DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
				ELSE
					DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
				END IF;
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			END IF;

			IF ReturnCode != '0' THEN
				RAISE EXCEPTION 'DNS Error: % when performing %',ReturnCode,DnsRecord;
			END IF;
		ELSE
			SELECT "dns"."keys"."keyname","dns"."keys"."key",api.resolve("dns"."soa"."nameserver")
			INTO DnsKeyName, DnsKey, DnsServer
			FROM "dns"."zones"
			JOIN "dns"."keys" ON "dns"."keys"."keyname" = "dns"."zones"."keyname"
			JOIN "dns"."soa" ON "dns"."soa"."zone" = "dns"."zones"."zone"
			WHERE "dns"."zones"."zone" = OLD."zone";

			IF OLD."type" ~* '^NS$' THEN
				DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."nameserver";
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^MX$' THEN
				DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."preference"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^SRV$' THEN
				DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."priority"||' '||OLD."weight"||' '||OLD."port"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^CNAME$' THEN
				DnsRecord := OLD."alias"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' '||OLD."hostname"||'.'||OLD."zone";
				ReturnCode := Returncode||api.nsupdate(OLD."zone",DnsKeyName,DnsKey,DnsServer,'DELETE',DnsRecord);
			ELSEIF OLD."type" ~* '^TXT$' THEN
				-- For zone TXT records
				IF OLD."hostname" IS NULL THEN
					DnsRecord := OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
				ELSE
					DnsRecord := OLD."hostname"||'.'||OLD."zone"||' '||OLD."ttl"||' '||OLD."type"||' "'||OLD."text"||'"';
				END IF;
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

/* Trigger - zone_txt_insert 
	1) Check if hostname name already exists
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."zone_txt_insert"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;

	BEGIN
		IF NEW."hostname" IS NOT NULL THEN
			-- Check if hostname name already exists as an A
			SELECT COUNT(*) INTO RowCount
			FROM "dns"."a"
			WHERE "dns"."a"."hostname" = NEW."hostname";
			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'Hostname (%) already exists',NEW."hostname";
			END IF;
			
			-- Check if hostname name already exists as an SRV
			SELECT COUNT(*) INTO RowCount
			FROM "dns"."srv"
			WHERE "dns"."srv"."alias" = NEW."hostname";
			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'hostname (%) already exists as a SRV',NEW."hostname";
			END IF;
			
			-- Check if hostname name already exists as an CNAME
			SELECT COUNT(*) INTO RowCount
			FROM "dns"."cname"
			WHERE "dns"."cname"."alias" = NEW."hostname";
			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'hostname (%) already exists as a CNAME',NEW."hostname";
			END IF;
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."zone_txt_insert"() IS 'Check if the hostname already exists in other tables and insert the zone TXT record';

/* Trigger - zone_txt_update 
	1) Check if hostname name already exists
	2) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."zone_txt_update"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
		
	BEGIN
		-- Check if hostname name already exists
		IF NEW."hostname" != OLD."hostname" THEN	
			IF NEW."hostname" IS NOT NULL THEN
				-- Check if hostname name already exists as an A
				SELECT COUNT(*) INTO RowCount
				FROM "dns"."a"
				WHERE "dns"."a"."hostname" = NEW."hostname";
				IF (RowCount > 0) THEN
					RAISE EXCEPTION 'Hostname (%) already exists',NEW."hostname";
				END IF;
				
				-- Check if hostname name already exists as an SRV
				SELECT COUNT(*) INTO RowCount
				FROM "dns"."srv"
				WHERE "dns"."srv"."alias" = NEW."hostname";
				IF (RowCount > 0) THEN
					RAISE EXCEPTION 'hostname (%) already exists as a SRV',NEW."hostname";
				END IF;
				
				-- Check if hostname name already exists as an CNAME
				SELECT COUNT(*) INTO RowCount
				FROM "dns"."cname"
				WHERE "dns"."cname"."alias" = NEW."hostname";
				IF (RowCount > 0) THEN
					RAISE EXCEPTION 'hostname (%) already exists as a CNAME',NEW."hostname";
				END IF;
			END IF;
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."zone_txt_update"() IS 'Check if the new hostname already exists in other tables and update the zone TXT record';

CREATE OR REPLACE FUNCTION "dns"."zone_a_insert"() RETURNS TRIGGER AS $$
	BEGIN
		IF family(NEW."address") = 4 THEN
			NEW."type" = 'A';
		ELSE
			NEW."type" = 'AAAA';
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."zone_a_insert"() IS 'Auto-fill the type based on the address family.';

CREATE OR REPLACE FUNCTION "dns"."zone_a_update"() RETURNS TRIGGER AS $$
	BEGIN
		IF family(NEW."address") = 4 THEN
			NEW."type" = 'A';
		ELSE
			NEW."type" = 'AAAA';
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."zone_a_update"() IS 'Auto-fill the type based on the address family.';

CREATE OR REPLACE FUNCTION "dns"."zone_a_delete"() RETURNS TRIGGER AS $$
	BEGIN
		IF family(OLD."address") = 4 THEN
			OLD."type" = 'A';
		ELSE
			OLD."type" = 'AAAA';
		END IF;
		RETURN OLD;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."zone_a_delete"() IS 'Auto-fill the type based on the address family.';
