/* Trigger - rules_insert 
	1) Check for metahost membership (there shouldnt be any)
*/
CREATE OR REPLACE FUNCTION "firewall"."rules_insert"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Metahost membership
		SELECT COUNT(*) INTO RowCount
		FROM "firewall"."metahost_members"
		WHERE "firewall"."metahost_members"."address" = NEW."address";
		IF (RowCount > 0) THEN
			RAISE EXCEPTION 'Rules cannot be applied to members of a metahost';
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."rules_insert"() IS 'Firewall rule verification';

/* Trigger - rules_update 
	1) Check for metahost membership (there shouldnt be any)
*/
CREATE OR REPLACE FUNCTION "firewall"."rules_update"() RETURNS TRIGGER AS $$
	DECLARE
		RowCount INTEGER;
	BEGIN
		-- Metahost membership
		IF NEW."address" != OLD."address" THEN
			SELECT COUNT(*) INTO RowCount
			FROM "firewall"."metahost_members"
			WHERE "firewall"."metahost_members"."address" = NEW."address";
			IF (RowCount > 0) THEN
				RAISE EXCEPTION 'Rules cannot be applied to members of a metahost';
			END IF;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."rules_update"() IS 'Firewall rule verification';