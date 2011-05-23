/* Trigger - switchports_insert
	1) Check for proper system types
*/
CREATE OR REPLACE FUNCTION "network"."switchports_insert"() RETURNS TRIGGER AS $$
	BEGIN
		-- Check for system types
		IF NEW."type" NOT LIKE 'Router|Switch|Hub|Wireless Access Point' THEN
			RAISE EXCEPTION 'Cannot create a switchport on non-network device type %',NEW."type";
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "network"."switchports_insert"() IS 'verifications for network switchports';

/* Trigger - switchports_update
	1) Check for proper system types
*/
CREATE OR REPLACE FUNCTION "network"."switchports_update"() RETURNS TRIGGER AS $$
	BEGIN
		-- Check for system types
		IF NEW."type" != OLD."type" THEN
			IF NEW."type" NOT LIKE 'Router|Switch|Hub|Wireless Access Point' THEN
				RAISE EXCEPTION 'Cannot create a switchport on non-network device type %',NEW."type";
			END IF;
		END IF;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "network"."switchports_update"() IS 'verifications for network switchports';