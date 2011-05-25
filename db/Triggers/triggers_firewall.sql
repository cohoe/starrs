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

/* Trigger - metahost_members_insert
	1) Remove old rules
	2) Apply metahost rules
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_members_insert"() RETURNS TRIGGER AS $$
	DECLARE
		result record;
	BEGIN
		-- Remove old rules
		DELETE FROM "firewall"."rules" WHERE "address" = NEW."address";
		
		-- Apply metahost rules
		FOR result IN SELECT "port","transport","deny" FROM "firewall"."metahost_rules" WHERE "name" = NEW."name" LOOP
			INSERT INTO "firewall"."rules" ("address","port","transport","deny","owner") VALUES 
			(NEW."address",result.port,result.transport,result.deny,api.get_current_user());
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_members_insert"() IS 'Add an address to a firewall metahost';

/* Trigger - metahost_members_delete
	1) Remove old rules
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_members_delete"() RETURNS TRIGGER AS $$
	DECLARE
		result record;
	BEGIN
		-- Remove old rules
		DELETE FROM "firewall"."rules" WHERE "address" = NEW."address";
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_members_delete"() IS 'Delete an address from a firewall metahost';

/* Trigger - metahost_members_update
	1) Remove old address rules
	2) Apply metahost rules
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_members_update"() RETURNS TRIGGER AS $$
	DECLARE
		result record;
	BEGIN
		IF NEW."address" != OLD."address" OR NEW."name" != OLD."name" THEN
			-- Remove old rules
			DELETE FROM "firewall"."rules" WHERE "address" = OLD."address";
			DELETE FROM "firewall"."rules" WHERE "address" = NEW."address";
			
			-- Apply metahost rules
			FOR result IN SELECT "port","transport","deny" FROM "firewall"."metahost_rules" WHERE "name" = NEW."name" LOOP
				INSERT INTO "firewall"."rules" ("address","port","transport","deny","owner") VALUES 
				(NEW."address",result.port,result.transport,result.deny,api.get_current_user());
			END LOOP;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_members_update"() IS 'Alter a metahost member';