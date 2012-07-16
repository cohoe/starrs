/* API - get_interface_address_owner */
CREATE OR REPLACE FUNCTION "api"."get_interface_address_owner"(input_address inet) RETURNS TEXT AS $$
	BEGIN
		RETURN (SELECT "owner" FROM systems.interface_addresses
			JOIN systems.interfaces on systems.interface_addresses.mac = systems.interfaces.mac
			JOIN systems.systems on systems.interfaces.system_name = systems.systems.system_name
			WHERE "address" = input_address);
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_interface_address_owner"(inet) IS 'Get the owner of an interface address';

CREATE OR REPLACE FUNCTION "api"."renew_interface_address"(input_address inet) RETURNS VOID AS $$
	BEGIN
		PERFORM api.create_log_entry('API','DEBUG','begin api.renew_interface_address');

		PERFORM api.create_log_entry('API','INFO','updating system'||input_system_name);
		UPDATE "systems"."interface_addresses"
		SET "renew_date" = date(current_date + (SELECT api.get_site_configuration('DEFAULT_RENEW_INTERVAL')))
		WHERE "address" = input_address;

		PERFORM api.create_log_entry('API','DEBUG','finish api.renew_interface_address');
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."renew_interface_address"(inet) IS 'renew an interface address registration for another interval';

CREATE OR REPLACE FUNCTION "api"."send_renewal_email"(text, text, text) RETURNS VOID AS $$
	use strict;
	use warnings;
	use Net::SMTP;

	my $username = shift(@_) or die "Unable to get username";
	my $system = shift(@_) or die "Unable to get system name";
	my $domain = shift(@_) or die "Unable to get mail domain";

	my $smtp = Net::SMTP->new("mail.$domain");

	$smtp->mail("impulse\@$domain");
	$smtp->recipient("$username\@$domain");
	$smtp->data;
	$smtp->datasend("From: impulse\@$domain\n");
	$smtp->datasend("To: $username\@$domain\n");
	$smtp->datasend("Subject: System Renewal Notification - $system\n");
	$smtp->datasend("\n");
	$smtp->datasend("Your system \"$system\" will expire in less than 7 days and will be removed from IMPULSE automatically. You can click https://impulse.$domain/system/renew/$system to renew your system for another year. Alternatively you can navigate to the System view and click the Renew button. If you have any questions, please see your local system administrator.");

	$smtp->datasend;
	$smtp->quit;
$$ LANGUAGE 'plperlu';
COMMENT ON FUNCTION "api"."send_renewal_email"(text, text, text) IS 'Send an email to a user saying their system is about to expire';

CREATE OR REPLACE FUNCTION "api"."notify_expiring_systems"() RETURNS VOID AS $$
	DECLARE
		SystemData RECORD;
	BEGIN
		FOR SystemData IN (SELECT "owner","system_name" FROM "systems"."systems" WHERE "systems"."systems"."renew_date" <= current_date + interval '7 days') LOOP
			PERFORM "api"."send_renewal_email"(SystemData.owner, SystemData.system_name, (SELECT "api"."get_site_configuration"('DNS_DEFAULT_ZONE')));
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."notify_expiring_systems"() IS 'Notify users of soon-to-expire systems';

CREATE OR REPLACE FUNCTION "api"."clear_expired_systems"() RETURNS VOID AS $$
	DECLARE
		SystemData RECORD;
	BEGIN
		--FOR SystemData IN (SELECT "system_name" FROM "systems"."systems" WHERE "systems"."systems"."renew_date" = current_date) LOOP
		--	PERFORM "api"."remove_system"(SystemData.system_name);
		--END LOOP;
		FOR SystemData IN (SELECT "address" FROM "systems"."interface_addresses" WHERE api.get_interface_address_system("address") IN (SELECT "system_name" FROM "systems"."systems" WHERE "renew_date" = current_date)) LOOP
			PERFORM "api"."remove_interface_address"(SystemData.address);
		END LOOP;
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."clear_expired_systems"() IS 'Remove all systems that expire today.';

CREATE OR REPLACE FUNCTION "api"."get_default_renew_date"() RETURNS DATE AS $$
	BEGIN
		 RETURN date((('now'::text)::date + (api.get_site_configuration('DEFAULT_RENEW_INTERVAL'::text))::interval));
	END;
$$ LANGUAGE 'plpgsql';
COMMENT ON FUNCTION "api"."get_default_renew_date"() IS 'Get the default renew date based on the configuration';
