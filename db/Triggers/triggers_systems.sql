/* Trigger - interface_addresses_insert 
	1) Set address family
	2) Check if address is within a subnet
	3) Check if primary address exists
	4) Check for one DHCPable address per MAC
	5) Check family against config type
	6) Check for wacky names
	7) Check for IPv6 secondary name
	8) IPv6 Autoconfiguration
*/
CREATE OR REPLACE FUNCTION "systems"."interface_addresses_insert"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
		ConfigFamily INTEGER;
		PrimaryName TEXT;
	BEGIN
		-- Set address family
		NEW."family" := family(NEW."address");

		-- Check if address is within a subnet
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."subnets" 
		WHERE NEW."address" << "ip"."subnets"."subnet";
		IF (RowCount < 1) THEN
			RAISE EXCEPTION 'IP address (%) must be within a managed subnet.',NEW."address";
		END IF;
		
		-- Check if primary address exists (it shouldnt)
		SELECT COUNT(*) INTO RowCount
		FROM "systems"."interface_addresses"
		WHERE "systems"."interface_addresses"."isprimary" = TRUE
		AND "systems"."interface_addresses"."family" = NEW."family"
		AND "systems"."interface_addresses"."mac" = NEW."mac";
		IF NEW."isprimary" IS TRUE AND RowCount > 0 THEN
			-- There is a primary address already registered and this was supposed to be one.
			RAISE EXCEPTION 'Primary address for this interface and family already exists';
		ELSIF NEW."isprimary" IS FALSE AND RowCount = 0 THEN
			-- There is no primary and this is set to not be one.
			RAISE EXCEPTION 'No primary address exists for this interface and family.';
		END IF;

		-- Check for one DHCPable address per MAC
		IF NEW."config" !~* 'static' THEN
			SELECT COUNT(*) INTO RowCount
			FROM "systems"."interface_addresses"
			WHERE "systems"."interface_addresses"."family" = NEW."family"
			AND "systems"."interface_addresses"."config" ~* 'dhcp';
			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'Only one DHCP/Autoconfig-able address per MAC is allowed';
			END IF;
		END IF;

		-- Check address family against config type
		IF NEW."config" !~* 'static' THEN
			SELECT "family" INTO ConfigFamily
			FROM "dhcp"."config_types"
			WHERE "dhcp"."config_types"."config" = NEW."config";
			IF NEW."family" != ConfigFamily THEN
				RAISE EXCEPTION 'Invalid configuration type selected (%) for your address family (%)',NEW."config",NEW."family";
			END IF;
		END IF;

		-- Check for wacky names
		SELECT COUNT(*) INTO RowCount
		FROM "systems"."interface_addresses"
		WHERE "systems"."interface_addresses"."name" = NEW."name"
		AND "systems"."interface_addresses"."mac" = NEW."mac";
		IF (RowCount > 0 AND NEW."family" = 4) THEN
			RAISE EXCEPTION 'IPv4 address names (%) should not be the same as any other address on this interface (%)',NEW."name",NEW."mac";
		END IF;
		
		-- Check for IPv6 secondary name
		IF NEW."family" = 6 AND NEW."isprimary" = FALSE THEN
			SELECT "name" INTO PrimaryName
			FROM "systems"."interface_addresses"
			WHERE "systems"."interface_addresses"."mac" = NEW."mac"
			AND "systems"."interface_addresses"."isprimary" = TRUE;
			IF NEW."name" != PrimaryName THEN
				RAISE EXCEPTION 'IPv6 secondaries must have the same interface name (%) as the primary (%)',NEW."name",PrimaryName;
			END IF;
		END IF;
		
		-- IPv6 Autoconfiguration
		IF NEW."family" = 6 AND NEW."config" ~* 'autoconf' THEN
			SELECT COUNT(*) INTO RowCount
			FROM "ip"."addresses"
			WHERE "ip"."addresses"."address" = NEW."address";

			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'Existing address (%) detected. Cannot continue.',NEW."address";
			END IF;

			INSERT INTO "ip"."addresses" ("address") VALUES (NEW."address");
		END IF;

		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "systems"."interface_addresses_insert"() IS 'Create a new address based on a very complex ruleset';

/* TRIGGER - interface_addresses_update */
CREATE OR REPLACE FUNCTION "systems"."interface_addresses_update"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount	INTEGER;	-- Placeholder
		ConfigFamily	INTEGER;	-- Family of config type
	BEGIN
		-- Set address family
		NEW."family" := family(NEW."address");

		-- Check if IP is within our controlled subnets
		IF NEW."address" != OLD."address" THEN
			SELECT COUNT(*) INTO RowCount
			FROM "ip"."subnets" 
			WHERE NEW."address" << "ip"."subnets"."subnet";
			
			IF (RowCount < 1) THEN
				RAISE EXCEPTION 'IP address (%) must be within a managed subnet.',NEW."address";
			END IF;
		END IF;
		
		-- Check if primary for the family already exists. It shouldnt.
		IF NEW."isprimary" != OLD."isprimary" THEN
			SELECT COUNT(*) INTO RowCount
			FROM "systems"."interface_addresses"
			WHERE "systems"."interface_addresses"."isprimary" = TRUE
			AND "systems"."interface_addresses"."family" = NEW."family";

			IF NEW."isprimary" IS TRUE AND RowCount > 0 THEN
				-- There is a primary address already registered and this was supposed to be one.
				RAISE EXCEPTION 'Primary address for this interface and family already exists';
			ELSIF NEW."isprimary" IS FALSE AND RowCount = 0 THEN
				-- There is no primary and this is set to not be one.
				RAISE EXCEPTION 'No primary address exists for this interface and family';
			END IF;
		END IF;

		-- Check for only one DHCPable address per MAC address
		IF NEW."config" != OLD."config" THEN
			IF NEW."config" !~* 'static' THEN
				SELECT COUNT(*) INTO RowCount
				FROM "systems"."interfaces"
				JOIN "systems"."interface_addresses" ON 
				"systems"."interface_addresses"."interface_id" = "systems"."interfaces"."interface_id"
				WHERE "systems"."interface_addresses"."family" = NEW."family"
				AND "systems"."interface_addresses"."config" !~* 'static';

				IF (RowCount > 0) THEN
					RAISE EXCEPTION 'Only one DHCP/Autoconfig-able address per MAC is allowed';
				END IF;
			END IF;

			-- Check address family against config type
			IF NEW."config" !~* 'static' THEN
				SELECT "family" INTO ConfigFamily
				FROM "dhcp"."config_types"
				WHERE "dhcp"."config_types"."config" = NEW."config";

				IF NEW."family" != ConfigFamily THEN
					RAISE EXCEPTION 'Invalid configuration type selected (%) for your address family (%)',NEW."config",NEW."family";
				END IF;
			END IF;
			
			-- IPv6 Autoconfiguration
			IF NEW."family" = 6 AND NEW."config" ~* 'autoconf' THEN
				SELECT COUNT(*) INTO RowCount
				FROM "ip"."addresses"
				WHERE "ip"."addresses"."address" = NEW."address";

				IF (RowCount > 0) THEN
					RAISE EXCEPTION 'Existing address (%) detected. Cannot continue.',NEW."address";
				END IF;

				INSERT INTO "ip"."addresses" ("address") VALUES (NEW."address");
			END IF;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "systems"."interface_addresses_update"() IS 'Modify an existing address based on a very complex ruleset';
