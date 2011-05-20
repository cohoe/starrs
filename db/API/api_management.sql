/*Trigger Function API - create_log_entry*/
CREATE OR REPLACE FUNCTION "api"."create_log_entry"(input_source text, input_severity text, input_message text) RETURNS VOID AS $$
	BEGIN
		input_source := api.sanitize_general(input_source);
		input_severity := api.sanitize_general(input_severity);
		input_message := api.sanitize_general(input_message);
		
		INSERT INTO "management"."log_master"
		("source","user","severity","message") VALUES
		(input_source,api.get_current_user(),input_severity,input_message);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."create_log_entry"() IS 'Function to insert a log entry';

/*Trigger Function API - sanitize_general*/
CREATE OR REPLACE FUNCTION "api"."sanitize_general"(input text) RETURNS TEXT AS $$
	DECLARE
		BadCrap	TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\_\.\-\:]*', '', 'gi');
		IF BadCrap != '' THEN
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
		RETURN input;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."sanitize_general"() IS 'Allow only certain characters for most common objects';

/*Trigger Function API - sanitize_dhcp*/
CREATE OR REPLACE FUNCTION "api"."sanitize_dhcp"(input text) RETURNS VOID AS $$
	DECLARE
		BadCrap	TEXT;
	BEGIN
		BadCrap = regexp_replace(input, E'[a-z0-9\_\.\=\"\,\(\)\/\; ]*\-*', '', 'gi');
		IF BadCrap != '' THEN
			--RAISE EXCEPTION 'Invalid characters detected in string "%"',BadCrap;
			RAISE EXCEPTION 'Invalid characters detected in string "%"',input;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."sanitize_dhcp"() IS 'Only allow certain characters in DHCP options';

/*Trigger Function API - get_current_user*/
CREATE OR REPLACE FUNCTION "api"."get_current_user" RETURNS TEXT AS $$
	DECLARE
		Username	TEXT;
	BEGIN
		-- Do stuff to check the table
		Username := 'cohoe_debug';
		RETURN Username;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_current_user"() IS 'Get the username of the current session';

/*Trigger Function API - validate_domain (DOCUMENT)*/
CREATE OR REPLACE FUNCTION "api"."validate_domain"(hostname text, domain text) RETURNS BOOLEAN AS $$
	use strict;
	use warnings;
	use Data::Validate::Domain qw(is_domain);

	# Usage: SELECT api.validate_domain([hostname OR NULL],[domain OR NULL]);

	# Declare the string to check later on
	my $domain;

	# This script can deal with just domain validation rather than host-domain. Note that the
	# module this depends on requires a valid TLD, so one is picked for this purpose.
	if (!$_[0])
	{
		# We are checking a domain name only
		$domain = $_[1];
	}
	elsif (!$_[1])
	{
		# We are checking a hostname only
		$domain = "$_[0].me";
	}
	else
	{
		# We have enough for a FQDN
		$domain = "$_[0].$_[1]";
	}

	# Return a boolean value of whether the input forms a valid domain
	if (is_domain($domain))
	{
		return 'TRUE';
	}
	else
	{
		return 'FALSE';
	}
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."validate_domain"() IS 'Validate hostname, domain, FQDN based on known rules. Requires Perl module';

/*Trigger Function API - renew_system (DOCUMENT)*/
CREATE OR REPLACE FUNCTION "api"."renew_system"(input_system_name text) RETURNS VOID AS $$
	BEGIN
		SELECT api.create_log_entry('API','DEBUG','begin api.renew_system');
		input_system_name := api.sanitize_general(input_system_name);
		
		SELECT api.create_log_entry('API','INFO','renewing system');
		UPDATE "systems"."systems" SET "renew_date" = date(current_date + interval '1 year');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."renew_system"() IS 'Renew a registered system for the next year';