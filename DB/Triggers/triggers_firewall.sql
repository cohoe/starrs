/* Trigger - metahost_members_insert
	1) Apply metahost rules
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_members_insert"() RETURNS TRIGGER AS $$
	DECLARE
		result record;

	BEGIN
		-- Apply metahost rules
		FOR result IN SELECT "port","transport","deny" FROM "firewall"."metahost_rules" WHERE "name" = NEW."name" LOOP
			INSERT INTO "firewall"."rules" ("address","port","transport","deny","owner") VALUES 
			(NEW."address",result.port,result.transport,result.deny,api.get_current_user());
		END LOOP;
		
		-- Done
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_members_insert"() IS 'Add an address to a firewall metahost';

/* Trigger - metahost_members_delete
	1) Remove old metahost rules
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_members_delete"() RETURNS TRIGGER AS $$
	DECLARE
		result Record;
	BEGIN
		-- Remove old metahost rules
		FOR result IN SELECT "port","transport" FROM "firewall"."metahost_rules" WHERE "firewall"."metahost_rules"."name" = OLD."name" LOOP
			DELETE FROM "firewall"."rules"
			WHERE "firewall"."rules"."address" = OLD."address"
			AND "firewall"."rules"."port" = result.port
			AND "firewall"."rules"."transport" = result.transport;
		END LOOP;
		
		-- Done
		RETURN OLD;
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
		
		-- Done
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_members_update"() IS 'Alter a metahost member';

/* Trigger - metahost_rules_insert
	1) Get owner
	2) Apply rule to members
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_rules_insert"() RETURNS TRIGGER AS $$
	DECLARE
		result Record;
		Owner TEXT;
	BEGIN
		-- Get owner
		SELECT "firewall"."metahosts"."owner" INTO Owner
		FROM "firewall"."metahosts"
		WHERE "firewall"."metahosts"."name" = NEW."name";
	
		-- Apply metahost rules
		FOR result IN SELECT "address" FROM "firewall"."metahost_members" WHERE "name" = NEW."name" LOOP
			INSERT INTO "firewall"."rules" ("address","port","transport","deny","owner","comment") VALUES 
			(result.address,NEW."port",NEW."transport",NEW."deny",Owner,'"'||NEW."name"||'" - '||NEW."comment");
		END LOOP;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_rules_insert"() IS 'Apply rules to members of the metahost';