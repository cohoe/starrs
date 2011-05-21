/* TRIGGER - interface_addresses_insert */
CREATE OR REPLACE FUNCTION "systems"."interface_addresses_insert"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount	INTEGER;	-- Placeholder
		ConfigFamily	INTEGER;	-- Family of config type
	BEGIN
		SELECT api.create_log_entry('database','DEBUG','Begin systems.interface_addresses_insert');
		-- Set address family
		NEW."family" := family(NEW."address");

		-- Check if IP is within our controlled subnets
		SELECT COUNT(*) INTO RowCount
		FROM "ip"."subnets" 
		WHERE NEW."address" << "ip"."subnets"."subnet";
		
		IF (RowCount < 1) THEN
			SELECT api.create_log_entry('database','ERROR','IP not in subnets');
			SELECT api.create_log_entry('database','ERROR',NEW);
			RAISE EXCEPTION 'IP address (%) must be within a managed subnet.',NEW."address";
		END IF;
		
		-- Check if primary for the family already exists. It shouldnt.
		SELECT COUNT(*) INTO RowCount
		FROM "systems"."interface_addresses"
		WHERE "systems"."interface_addresses"."isprimary" = TRUE
		AND "systems"."interface_addresses"."family" = NEW."family";

		IF NEW."isprimary" IS TRUE AND RowCount > 0 THEN
			-- There is a primary address already registered and this was supposed to be one.
			SELECT api.create_log_entry('database','ERROR','Primary interface already exists');
			SELECT api.create_log_entry('database','ERROR','NEW');
			RAISE EXCEPTION 'Primary address for this interface and family already exists';
		ELSIF NEW."isprimary" IS FALSE AND RowCount = 0 THEN
			-- There is no primary and this is set to not be one.
			SELECT api.create_log_entry('database','ERROR','Primary interface does not exist');
			SELECT api.create_log_entry('database','ERROR',NEW);
			RAISE EXCEPTION 'No primary address exists for this interface and family';
		END IF;

		-- Check for only one DHCPable address per MAC address
		IF NEW."config" NOT LIKE 'static' THEN
			SELECT COUNT(*) INTO RowCount
			FROM "systems"."interfaces"
			JOIN "systems"."interface_addresses" ON 
			"systems"."interface_addresses"."interface_id" = "systems"."interfaces"."interface_id"
			WHERE "systems"."interface_addresses"."family" = NEW."family"
			AND "systems"."interface_addresses"."config" NOT LIKE 'static';

			IF (RowCount > 0) THEN
				SELECT api.create_log_entry('database','ERROR','Only one stateful address per MAC allowed');
				SELECT api.create_log_entry('database','ERROR',NEW);
				RAISE EXCEPTION 'Only one DHCP/Autoconfig-able address per MAC is allowed';
			END IF;
		END IF;

		-- Check address family against config type
		IF NEW."config" NOT LIKE 'static' THEN
			SELECT "family" INTO ConfigFamily
			FROM "dhcp"."config_types"
			WHERE "dhcp"."config_types"."config" = NEW."config";

			IF NEW."family" != ConfigFamily THEN
				SELECT api.create_log_entry('database','ERROR','Configuration/family mismatch');
				SELECT api.create_log_entry('database','ERROR',NEW);
				RAISE EXCEPTION 'Invalid configuration type selected (%) for your address family (%)'NEW."config",NEW."family";
			END IF;
		END IF;

		-- IPv6 Autoconfiguration
		IF NEW."family" = 6 AND NEW."config" LIKE 'autoconf' THEN
			SELECT COUNT(*) INTO RowCount
			FROM "ip"."addresses"
			WHERE "ip"."addresses"."address" = NEW."address";

			IF (RowCount > 0) THEN
				SELECT api.create_log_entry('database','ERROR','Autoconf address already exists');
				SELECT api.create_log_entry('database','ERROR',NEW);
				RAISE EXCEPTION 'Existing address (%) detected. Cannot continue.',NEW."address";
			END IF;

			INSERT INTO "ip"."addresses" ("address") VALUES (NEW."address");
			SELECT api.create_log_entry('database','INFO','Autoconf address created');
			SELECT api.create_log_entry('database','INFO',NEW);
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
		SELECT api.create_log_entry('database','DEBUG','Begin systems.interface_addresses_update');
		-- Set address family
		NEW."family" := family(NEW."address");

		-- Check if IP is within our controlled subnets
		IF NEW."address" != OLD."address" THEN
			SELECT COUNT(*) INTO RowCount
			FROM "ip"."subnets" 
			WHERE NEW."address" << "ip"."subnets"."subnet";
			
			IF (RowCount < 1) THEN
				SELECT api.create_log_entry('database','ERROR','IP not in subnets');
				SELECT api.create_log_entry('database','ERROR',NEW);
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
				SELECT api.create_log_entry('database','ERROR','Primary interface already exists');
				SELECT api.create_log_entry('database','ERROR','NEW');
				RAISE EXCEPTION 'Primary address for this interface and family already exists';
			ELSIF NEW."isprimary" IS FALSE AND RowCount = 0 THEN
				-- There is no primary and this is set to not be one.
				SELECT api.create_log_entry('database','ERROR','Primary interface does not exist');
				SELECT api.create_log_entry('database','ERROR',NEW);
				RAISE EXCEPTION 'No primary address exists for this interface and family';
			END IF;
		END IF;

		-- Check for only one DHCPable address per MAC address
		IF NEW."config" != OLD."config" THEN
			IF NEW."config" NOT LIKE 'static' THEN
				SELECT COUNT(*) INTO RowCount
				FROM "systems"."interfaces"
				JOIN "systems"."interface_addresses" ON 
				"systems"."interface_addresses"."interface_id" = "systems"."interfaces"."interface_id"
				WHERE "systems"."interface_addresses"."family" = NEW."family"
				AND "systems"."interface_addresses"."config" NOT LIKE 'static';

				IF (RowCount > 0) THEN
					SELECT api.create_log_entry('database','ERROR','Only one stateful address per MAC allowed');
					SELECT api.create_log_entry('database','ERROR',NEW);
					RAISE EXCEPTION 'Only one DHCP/Autoconfig-able address per MAC is allowed';
				END IF;
			END IF;

			-- Check address family against config type
			IF NEW."config" NOT LIKE 'static' THEN
				SELECT "family" INTO ConfigFamily
				FROM "dhcp"."config_types"
				WHERE "dhcp"."config_types"."config" = NEW."config";

				IF NEW."family" != ConfigFamily THEN
					SELECT api.create_log_entry('database','ERROR','Configuration/family mismatch');
					SELECT api.create_log_entry('database','ERROR',NEW);
					RAISE EXCEPTION 'Invalid configuration type selected (%) for your address family (%)'NEW."config",NEW."family";
				END IF;
			END IF;
			
			-- IPv6 Autoconfiguration
			IF NEW."family" = 6 AND NEW."config" LIKE 'autoconf' THEN
				SELECT COUNT(*) INTO RowCount
				FROM "ip"."addresses"
				WHERE "ip"."addresses"."address" = NEW."address";

				IF (RowCount > 0) THEN
					SELECT api.create_log_entry('database','ERROR','Autoconf address already exists');
					SELECT api.create_log_entry('database','ERROR',NEW);
					RAISE EXCEPTION 'Existing address (%) detected. Cannot continue.',NEW."address";
				END IF;

				INSERT INTO "ip"."addresses" ("address") VALUES (NEW."address");
				SELECT api.create_log_entry('database','INFO','Autoconf address created');
				SELECT api.create_log_entry('database','INFO',NEW);
			END IF;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "systems"."interface_addresses_update"() IS 'Modify an existing address based on a very complex ruleset';
