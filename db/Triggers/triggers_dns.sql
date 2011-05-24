/* Trigger a_insert 
	1) Check for zone mismatch
*/
CREATE OR REPLACE FUNCTION "dns"."a_insert"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Check for zone mismatch
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."subnets"
		WHERE "ip"."subnets"."zone" = NEW."zone"
		AND NEW."address" << "ip"."subnets"."subnet";
		IF (RowCount < 1) THEN 
			RAISE EXCEPTION 'IP address and DNS Zone do not match (%, %)',NEW."address",NEW."zone";
		END IF;
		
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."a_insert"() IS 'Creating a new A or AAAA record';

/* Trigger a_update 
	1) Check for zone mismatch
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
COMMENT ON FUNCTION "dns"."a_update"() IS 'Altering an A or AAAA record';

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
CREATE OR REPLACE FUNCTION "dns"."ns_insert" RETURNS TRIGGER AS $$
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
CREATE OR REPLACE FUNCTION "dns"."ns_update" RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Check for existing primary NS for zone
		IF NEW."zone" != OLD."zone" THEN
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
CREATE OR REPLACE FUNCTION "dns"."mx_insert" RETURNS TRIGGER AS $$
	BEGIN
		NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."mx_insert" IS 'Create new MX record';

/* Trigger - mx_update
	1) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."mx_update" RETURNS TRIGGER AS $$
	BEGIN
		IF NEW."address" != OLD."address"
			NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."mx_update" IS 'Modify a MX record';

/* Trigger - txt_insert
	1) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."txt_insert" RETURNS TRIGGER AS $$
	BEGIN
		NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."txt_insert" IS 'Create new TXT record';

/* Trigger - txt_update
	1) Autopopulate address
*/
CREATE OR REPLACE FUNCTION "dns"."txt_update" RETURNS TRIGGER AS $$
	BEGIN
		IF NEW."address" != OLD."address"
			NEW."address" := dns.dns_autopopulate_address(NEW."hostname",NEW."zone");
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."txt_update" IS 'Modify a TXT record';

/* Trigger - dns_autopopulate_address */
CREATE OR REPLACE FUNCTION "dns"."dns_autopopulate_address"(input_hostname text, input_zone text) RETURNS INET AS $$
	DECLARE
		Address INET;
	BEGIN
		SELECT "address" INTO Address
		FROM "dns"."a"
		WHERE "dns"."a"."hostname" = input_hostname
		AND "dns"."a"."zone" = input_zone;
		RETURN Address;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "dns"."dns_autopopulate_address"() IS 'Fill in the address portion of the foreign key relationship';