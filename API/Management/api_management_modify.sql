/* api_management_modify
	1) modify_site_configuration
*/

/* API - modify_site_configuration
	1) Check privileges
	2) Create directive
*/
CREATE OR REPLACE FUNCTION "api"."modify_site_configuration"(input_directive text, input_value text) RETURNS SETOF "management"."configuration" AS $$
	BEGIN

		-- Check privileges
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can modify site directives';
		END IF;

		-- Create directive
		UPDATE "management"."configuration" SET "value" = input_value WHERE "option" = input_directive;

		-- Done
		RETURN QUERY (SELECT * FROM "management"."configuration" WHERE "option" = input_directive AND "value" = input_value);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_site_configuration"(text, text) IS 'Modify a site configuration directive';

CREATE OR REPLACE FUNCTION "api"."modify_group"(input_old_group text, input_field text, input_new_value text) RETURNS SETOF "management"."groups" AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			RAISE EXCEPTION 'Permission denied. Only admins can modify groups';
		END IF;

		IF input_field !~* 'group|privilege|renew_interval|comment' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		IF input_field ~* 'renew_interval' THEN
			EXECUTE 'UPDATE "management"."groups" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "group" = $1' 
			USING input_old_group, input_field, input_new_value::interval;
		ELSE
			EXECUTE 'UPDATE "management"."groups" SET ' || quote_ident($2) || ' = $3, 
			date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
			WHERE "group" = $1' 
			USING input_old_group, input_field, input_new_value;
		END IF;

		IF input_field ~* 'group' THEN
			RETURN QUERY (SELECT * FROM "management"."groups" WHERE "group" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "management"."groups" WHERE "group" = input_old_group);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_group"(text, text, text) IS 'Alter a group';

CREATE OR REPLACE FUNCTION "api"."modify_group_member"(input_old_group text, input_old_user text, input_field text, input_new_value text) RETURNS SETOF "management"."group_members" AS $$
	BEGIN
		IF api.get_current_user_level() !~* 'ADMIN' THEN
			IF api.get_current_user() NOT IN (SELECT * FROM api.get_group_admins(input_old_group)) THEN
				RAISE EXCEPTION 'Permission denied. Only admins can modify group members';
			END IF;
		END IF;

		IF input_field !~* 'group|user|privilege' THEN
			RAISE EXCEPTION 'Invalid field specified (%)',input_field;
		END IF;

		EXECUTE 'UPDATE "management"."group_members" SET ' || quote_ident($3) || ' = $4, 
		date_modified = localtimestamp(0), last_modifier = api.get_current_user() 
		WHERE "group" = $1 AND "user" = $2' 
		USING input_old_group, input_old_user, input_field, input_new_value;

		IF input_field ~* 'group' THEN
			RETURN QUERY (SELECT * FROM "management"."group_members" WHERE "group" = input_new_value AND "user" = input_old_user);
		ELSEIF input_field ~* 'user' THEN
			RETURN QUERY (SELECT * FROM "management"."group_members" WHERE "group" = input_old_group AND "user" = input_new_value);
		ELSE
			RETURN QUERY (SELECT * FROM "management"."group_members" WHERE "group" = input_old_group AND "user" = input_old_user);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."modify_group_member"(text, text, text, text) IS 'Modify a group member';
