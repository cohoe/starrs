/* Trigger - metahost_members_insert
	1) Get owner
	2) Apply metahost rules
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_members_insert"() RETURNS TRIGGER AS $$
	DECLARE
		result record;
		Owner TEXT;

	BEGIN
		-- Get owner
		SELECT "firewall"."metahosts"."owner" INTO Owner
		FROM "firewall"."metahosts"
		WHERE "firewall"."metahosts"."name" = NEW."name";
		
		-- Apply standalone metahost rules
		FOR result IN SELECT "port","transport","deny","comment" FROM "firewall"."metahost_rules" WHERE "name" = NEW."name" LOOP
			INSERT INTO "firewall"."rules" ("address","port","transport","deny","owner","comment","source") VALUES 
			(NEW."address",result.port,result.transport,result.deny,Owner,'"'||NEW."name"||'" - '||result.comment,'metahost-standalone');
		END LOOP;
		
		-- Apply program metahost rules
		
		/* THIS NEEDS DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
		
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

/* Trigger - metahost_rules_insert
	1) Get owner
	2) Get program info
	3) Apply rule to members
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_rule_program_insert"() RETURNS TRIGGER AS $$
	DECLARE
		ProgName TEXT;
		PortNum INTEGER;
		ProgTransport TEXT;
		result Record;
		Owner TEXT;
	BEGIN
		-- Get owner
		SELECT "firewall"."metahosts"."owner" INTO Owner
		FROM "firewall"."metahosts"
		WHERE "firewall"."metahosts"."name" = NEW."name";

		-- Get program info
		SELECT "name","port","transport" INTO ProgName,PortNum,ProgTransport
		FROM "firewall"."programs"
		WHERE "port" = NEW."port";

		-- Apply metahost rules
		FOR result IN SELECT "address" FROM "firewall"."metahost_members" WHERE "name" = NEW."name" LOOP
			INSERT INTO "firewall"."rules" ("address","port","transport","deny","owner","comment","source") VALUES
			(result.address,PortNum,ProgTransport,NEW."deny",Owner,'"'||NEW."name"||'" program "'||ProgName||'" selected','metahost-program');
		END LOOP;
		
		-- Done
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."rule_program_insert"() IS 'Place a program rule in the master table';

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
			INSERT INTO "firewall"."rules" ("address","port","transport","deny","owner","comment","source") VALUES 
			(result.address,NEW."port",NEW."transport",NEW."deny",Owner,'"'||NEW."name"||'" - '||NEW."comment",'metahost-standalone');
		END LOOP;
		
		-- Done
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_rules_insert"() IS 'Apply rules to members of the metahost';

/* Trigger - metahost_rules_update
	1) Get owner
	2) Update record
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_rules_update"() RETURNS TRIGGER AS $$
	DECLARE
		MhOwner TEXT;
	BEGIN
		-- Get owner
		SELECT "firewall"."metahosts"."owner" INTO MhOwner
		FROM "firewall"."metahosts"
		WHERE "firewall"."metahosts"."name" = NEW."name";

		-- Update record
		UPDATE "firewall"."rules" 
		SET "port"=NEW."port","transport"=NEW."transport", "deny"=NEW."deny", "owner"=MhOwner, "comment"='"'||NEW."name"||'" - '||NEW."comment"
		WHERE "address" IN (SELECT "address" FROM "firewall"."metahost_members" WHERE "name" = OLD."name")
		AND "port" = OLD."port" AND "transport" = OLD."transport";

		-- Done
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_rules_update"() IS 'Update a rule applied to all metahost members';

/* Trigger - metahost_rules_delete
	1) Delete records
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_rules_delete"() RETURNS TRIGGER AS $$
	BEGIN
		-- Delete records
		DELETE FROM "firewall"."rules" WHERE ("address") IN 
		(SELECT "address" FROM "firewall"."metahost_members" WHERE "name" = OLD."name")
		AND "port" = OLD."port" AND "transport" = OLD."transport" AND "source" = 'metahost-standalone';
		
		-- Done
		RETURN OLD;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."metahost_rules_delete"() IS 'Remove a rule applied to all metahosts';

/* Trigger - rule_program_insert
	1) Get program info
	2) Insert rules into the master
*/
CREATE OR REPLACE FUNCTION "firewall"."rule_program_insert"() RETURNS TRIGGER AS $$
	DECLARE
		ProgName TEXT;
		PortNum INTEGER;
		ProgTransport TEXT;
	BEGIN
		-- Get program info
		SELECT "name","port","transport" INTO ProgName,PortNum,ProgTransport
		FROM "firewall"."programs"
		WHERE "port" = NEW."port";

		-- Insert rules
		INSERT INTO "firewall"."rules" ("address","port","transport","deny","owner","comment","source") VALUES
		(NEW."address",PortNum,ProgTransport,NEW."deny",NEW."owner",'"'||ProgName||'" program selected','standalone-program');
		
		-- Done
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."rule_program_insert"() IS 'Place a program rule in the master table';

/* Trigger - rule_program_delete
	1) Get program info
	2) Delete rules from the master
*/
CREATE OR REPLACE FUNCTION "firewall"."rule_program_delete"() RETURNS TRIGGER AS $$
	DECLARE
		ProgName TEXT;
		PortNum INTEGER;
		ProgTransport TEXT;
	BEGIN
		-- Get program info
		SELECT "name","port","transport" INTO ProgName,PortNum,ProgTransport
		FROM "firewall"."programs"
		WHERE "port" = OLD."port";
		
		-- Delete rule
		DELETE FROM "firewall"."rules" WHERE "firewall"."rules"."address" = OLD."address" AND "port" = PortNum AND "transport" = ProgTransport AND "source" = 'standalone-program';
		
		-- Done
		RETURN OLD;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."rule_program_delete"() IS 'Remove a standalone program rule';

/* Trigger - metahost_rule_program_delete
	1) Get program info
	2) Delete rules from the master
*/
CREATE OR REPLACE FUNCTION "firewall"."metahost_rule_program_delete"() RETURNS TRIGGER AS $$
	DECLARE
		ProgName TEXT;
		PortNum INTEGER;
		ProgTransport TEXT;
		result Record;
	BEGIN
		-- Get program info
		SELECT "name","port","transport" INTO ProgName,PortNum,ProgTransport
		FROM "firewall"."programs"
		WHERE "port" = OLD."port";
		
		-- Delete metahost rules
		FOR result IN SELECT "address" FROM "firewall"."metahost_members" WHERE "name" = OLD."name" LOOP
			DELETE FROM "firewall"."rules" WHERE "firewall"."rules"."address" = result.address AND "port" = PortNum AND "transport" = ProgTransport AND "source" = 'metahost-program';
		END LOOP;
		
		-- Done
		RETURN OLD;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "firewall"."rule_program_delete"() IS 'Remove a metahost program rule';