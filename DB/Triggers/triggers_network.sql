/* Trigger - switchports_insert
	1) Check for proper system types
*/
CREATE OR REPLACE FUNCTION "network"."switchports_insert"() RETURNS TRIGGER AS $$
	DECLARE
		DeviceType TEXT;
	BEGIN
		-- Check for system types
		SELECT "type" INTO DeviceType
		FROM "systems"."systems"
		WHERE "systems"."systems"."system_name" = NEW."system_name";
		IF DeviceType !~* 'Router|Switch|Hub|Wireless Access Point' THEN
			RAISE EXCEPTION 'Cannot create a switchport on non-network device type (%)',DeviceType;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "network"."switchports_insert"() IS 'verifications for network switchports';

/* Trigger - switchports_update
	1) Check for proper system types
*/
CREATE OR REPLACE FUNCTION "network"."switchports_update"() RETURNS TRIGGER AS $$
	DECLARE
		DeviceType TEXT;
	BEGIN
		-- Check for system types
		IF NEW."system_name" != OLD."system_name" THEN
			SELECT "type" INTO DeviceType
			FROM "systems"."systems"
			WHERE "systems"."systems"."system_name" = NEW."system_name";
			IF DeviceType !~* 'Router|Switch|Hub|Wireless Access Point' THEN
				RAISE EXCEPTION 'Cannot create a switchport on non-network device type %',DeviceType;
			END IF;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "network"."switchports_update"() IS 'verifications for network switchports';