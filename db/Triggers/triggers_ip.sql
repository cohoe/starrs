/* TRIGGER subnets_insert */
CREATE OR REPLACE FUNCTION "ip"."subnets_insert"() RETURNS TRIGGER AS $$
DECLARE
	RowCount INTEGER;	-- Placeholder
BEGIN

	-- Check for larger/smaller subnets and existing addresses
	SELECT COUNT(*) INTO RowCount
	FROM "ip"."subnets"
	WHERE NEW."subnet" << "ip"."subnets"."subnet";
	IF (RowCount > 0) THEN
		RAISE EXCEPTION 'A larger existing subnet was detected. Nested subnets are not supported.';
	END IF;

	SELECT COUNT(*) INTO RowCount
	FROM "ip"."subnets"
	WHERE NEW."subnet" >> "ip"."subnets"."subnet";
	IF (RowCount > 0) THEN
		RAISE EXCEPTION 'A smaller existing subnet was detected. Nested subnets are not supported.';
	END IF;
	
	SELECT COUNT(*) INTO RowCount
	FROM "ip"."addresses"
	WHERE "ip"."addresses"."address" << NEW."subnet";
	IF RowCount >= 1 THEN
		RAISE EXCEPTION 'Existing addresses detected for your subnet. Modify the existing subnet.';
	END IF;

	-- Autogenerate all IP addresses if told to
	IF NEW."autogen" IS TRUE THEN
		INSERT INTO "ip"."addresses" ("address","last_modifier") SELECT "get_subnet_addresses",api.get_current_user() FROM api.get_subnet_addresses(NEW."subnet");
	END IF;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

/* TRIGGER - subnets_update */
CREATE OR REPLACE FUNCTION "ip"."subnets_update"() RETURNS TRIGGER AS $$
DECLARE
	RowCount INTEGER;	-- Placeholder
BEGIN

	-- Check for larger/smaller subnets and existing addresses
	IF NEW."subnet" != OLD."subnet" THEN
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."subnets"
		WHERE NEW."subnet" << "ip"."subnets"."subnet";
		IF (RowCount > 0) THEN
			RAISE EXCEPTION 'A larger existing subnet was detected. Nested subnets are not supported.';
		END IF;

		SELECT COUNT(*) INTO RowCount
		FROM "ip"."subnets"
		WHERE NEW."subnet" >> "ip"."subnets"."subnet";
		IF (RowCount > 0) THEN
			RAISE EXCEPTION 'A smaller existing subnet was detected. Nested subnets are not supported.';
		END IF;
		
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."addresses"
		WHERE "ip"."addresses"."address" << NEW."subnet";
		IF RowCount >= 1 THEN
			RAISE EXCEPTION 'Existing addresses detected for your subnet. Modify the existing subnet.';
		END IF;
	END IF;

	-- Autogenerate all IP addresses if told to
	IF NEW."autogen" != OLD."autogen" THEN
		IF NEW."autogen" IS TRUE THEN
			DELETE FROM "ip"."addresses" WHERE "ip"."addresses"."address" << OLD."subnet";
			INSERT INTO "ip"."addresses" ("address") SELECT * FROM ip_address_autopopulation(NEW."subnet");
		END IF;
	END IF;
	NEW."date_modified" := current_timestamp;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "ip"."subnets_update"() IS 'Modify an existing new subnet';

/* TRIGGER - subnets_delete */
-- Delete an existing subnet, remove its addresses from the table. Only works if they arent in use.
-- BROKEN
CREATE OR REPLACE FUNCTION "ip"."subnets_delete"() RETURNS TRIGGER AS $$
DECLARE
	RowCount INTEGER;	-- Placeholder
BEGIN

	IF OLD."autogen" = TRUE THEN
		-- Check to see if there are inuse addresses from your old subnet. All addresses must be set not inuse before you can proceed.
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."addresses"
		WHERE "ip"."addresses"."address" << OLD."subnet" AND "ip"."addresses"."inuse"=TRUE;
		IF (RowCount >= 1) THEN
			RAISE EXCEPTION 'Inuse addresses found. Aborting delete.';
		ELSE
			-- Looks like you are good!
			DELETE FROM "ip"."addresses" WHERE "address" << OLD."subnet";
		END IF;
	END IF;

	-- Delete RDNS zone for old subnet
	DELETE FROM "dns"."zones" WHERE "dns"."zones"."zone" = api.get_reverse_domain(OLD."subnet");
	RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "ip"."subnets_delete"() IS 'You can only delete a subnet if no addresses from it are inuse.';


/* TRIGGER - addresses_insert */
CREATE OR REPLACE FUNCTION "ip"."addresses_insert"() RETURNS TRIGGER AS $$
DECLARE
	RowCount INTEGER;
BEGIN
	-- Search the firewall defaults table for the address you are trying to add to make sure it doesnt already exist in there
	SELECT COUNT(*) INTO RowCount
	FROM "firewall"."defaults"
	WHERE "firewall"."defaults"."address" = NEW."address";
	
	IF (RowCount >= 1) THEN
		RAISE EXCEPTION 'Address % is already has a firewall default action?',NEW."address";
	-- Looks like it does not. Insert it with the default value to DENY.
	ELSIF (RowCount = 0) THEN
		RETURN NEW;
		INSERT INTO "firewall"."defaults" ("address", "deny", "last_modifier") VALUES (NEW."address", DEFAULT, NEW."last_modifier");
	-- Not sure what is going on here. There's some funky crap going on.
	ELSE
		RAISE EXCEPTION 'Could not activate firewall address %',NEW."address";
	END IF;
END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "ip"."addresses_insert"() IS 'Activate a new IP address in the application';

/* TRIGGER - ranges_insert */
CREATE OR REPLACE FUNCTION "ip"."ranges_insert"() RETURNS TRIGGER AS $$
	DECLARE
		LowerBound	INET;
		UpperBound	INET;
		result		RECORD;
		RowCount	INTEGER;
	BEGIN
		-- Basic checks
		IF host(input_subnet) = host(input_first_ip) THEN
			RAISE EXCEPTION 'You cannot have a boundry that is the network identifier';
		END IF;
		
		IF NOT input_first_ip << input_subnet OR NOT input_last_ip << input_subnet THEN
			RAISE EXCEPTION 'Range addresses must be inside the specified subnet';
		END IF;

		IF input_first_ip >= input_last_ip THEN
			RAISE EXCEPTION 'First address is larger or equal to last address.';
		END IF;
		
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."addresses"
		WHERE "ip"."addresses"."address" = input_first_ip;
		
		IF (RowCount != 1) THEN
			RAISE EXCEPTION 'First address (%) not found in address pool.',input_first_ip;
		END IF;
		
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."addresses"
		WHERE "ip"."addresses"."address" = input_last_ip;
		
		IF (RowCount != 1) THEN
			RAISE EXCEPTION 'Last address (%) not found in address pool.',input_last_ip;
		END IF;

		-- Loop through all ranges and find what is near the new range
		FOR result IN SELECT "first_ip","last_ip" FROM "ip"."ranges" WHERE "subnet" = input_subnet LOOP
			IF input_first_ip >= result.first_ip AND input_first_ip <= result.last_ip THEN
				RAISE EXCEPTION 'First address out of bounds.';
			ELSIF input_first_ip > result.last_ip THEN
				LowerBound := result.last_ip;
			END IF;
			IF input_last_ip >= result.first_ip AND input_last_ip <= result.last_ip THEN
				RAISE EXCEPTION 'Last address is out of bounds';
			END IF;
		END LOOP;

		-- Define the upper bound of the range
		SELECT "first_ip" INTO UpperBound
		FROM "ip"."ranges"
		WHERE "first_ip" >= LowerBound
		ORDER BY "first_ip" LIMIT 1;

		-- Check if we try to span multiple ranges
		IF input_last_ip >= UpperBound THEN
			RAISE EXCEPTION 'Last address is out of bounds';
		END IF;

		-- All is well. Insert range
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "ip"."ranges_insert"() IS 'Insert a new range of addresses for use';




/* TRIGGER - ranges_update */
CREATE OR REPLACE FUNCTION "ip"."ranges_update"() RETURNS TRIGGER AS $$
	DECLARE
		LowerBound	INET;
		UpperBound	INET;
		result		RECORD;
		RowCount	INTEGER;
	BEGIN
		IF NEW."first_ip" != OLD."first_ip" OR NEW."last_ip" != OLD."last_ip" THEN
			-- Basic checks
			IF host(input_subnet) = host(input_first_ip) THEN
				RAISE EXCEPTION 'You cannot have a boundry that is the network identifier';
			END IF;
			
			IF NOT input_first_ip << input_subnet OR NOT input_last_ip << input_subnet THEN
				RAISE EXCEPTION 'Range addresses must be inside the specified subnet';
			END IF;

			IF input_first_ip >= input_last_ip THEN
				RAISE EXCEPTION 'First address is larger or equal to last address.';
			END IF;
			
			SELECT COUNT(*) INTO RowCount
			FROM "ip"."addresses"
			WHERE "ip"."addresses"."address" = input_first_ip;
			
			IF (RowCount != 1) THEN
				RAISE EXCEPTION 'First address (%) not found in address pool.',input_first_ip;
			END IF;
			
			SELECT COUNT(*) INTO RowCount
			FROM "ip"."addresses"
			WHERE "ip"."addresses"."address" = input_last_ip;
			
			IF (RowCount != 1) THEN
				RAISE EXCEPTION 'Last address (%) not found in address pool.',input_last_ip;
			END IF;

			-- Loop through all ranges and find what is near the new range
			FOR result IN SELECT "first_ip","last_ip" FROM "ip"."ranges" WHERE "subnet" = input_subnet LOOP
				IF input_first_ip >= result.first_ip AND input_first_ip <= result.last_ip THEN
					RAISE EXCEPTION 'First address out of bounds.';
				ELSIF input_first_ip > result.last_ip THEN
					LowerBound := result.last_ip;
				END IF;
				IF input_last_ip >= result.first_ip AND input_last_ip <= result.last_ip THEN
					RAISE EXCEPTION 'Last address is out of bounds';
				END IF;
			END LOOP;

			-- Define the upper bound of the range
			SELECT "first_ip" INTO UpperBound
			FROM "ip"."ranges"
			WHERE "first_ip" >= LowerBound
			ORDER BY "first_ip" LIMIT 1;

			-- Check if we try to span multiple ranges
			IF input_last_ip >= UpperBound THEN
				RAISE EXCEPTION 'Last address is out of bounds';
			END IF;

			-- All is well. Insert range
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "ip"."ranges_update"() IS 'Alter a range of addresses for use';