/* Privileges */

DO $$ BEGIN IF (SELECT COUNT("rolname") FROM "pg_roles" WHERE "rolname" = 'impulse_admin') != 1 THEN CREATE ROLE "impulse_admin"; END IF; END $$;
DO $$ BEGIN IF (SELECT COUNT("rolname") FROM "pg_roles" WHERE "rolname" = 'impulse_client') != 1 THEN CREATE ROLE "impulse_client"; END IF; END $$;

/* Schemas
	Allow access to the schemas
*/
GRANT USAGE ON SCHEMA "api" TO "impulse_client";
GRANT USAGE ON SCHEMA "dhcp" TO "impulse_client";
GRANT USAGE ON SCHEMA "dns" TO "impulse_client";
GRANT USAGE ON SCHEMA "ip" TO "impulse_client";
GRANT USAGE ON SCHEMA "management" TO "impulse_client";
GRANT USAGE ON SCHEMA "network" TO "impulse_client";
GRANT USAGE ON SCHEMA "systems" TO "impulse_client";

/* System Data
	Clients should never be able to modify these. They are for administrators only (superuser)
*/
GRANT SELECT ON "ip"."range_uses" TO "impulse_client";
GRANT SELECT ON "systems"."device_types" TO "impulse_client";
GRANT SELECT ON "systems"."os_family" TO "impulse_client";
GRANT SELECT ON "dhcp"."config_types" TO "impulse_client";
GRANT SELECT ON "systems"."os" TO "impulse_client";
GRANT SELECT ON "network"."switchport_types" TO "impulse_client";
GRANT SELECT ON "dns"."types" TO "impulse_client";
GRANT SELECT ON "documentation"."functions" TO "impulse_client";
GRANT SELECT ON "documentation"."arguments" TO "impulse_client";

/* User Data
	This is all the stuff that clients can (depending on user permission level) modify
*/
GRANT SELECT,INSERT,UPDATE,DELETE ON "dhcp"."class_options" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "ip"."subnets" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "ip"."ranges" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."ns" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "network"."switchports" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "systems"."interface_addresses" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dhcp"."classes" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "systems"."systems" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dhcp"."subnet_options" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."mx" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."zones" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."keys" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "ip"."addresses" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."txt" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."a" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "systems"."interfaces" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "management"."configuration" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "management"."processes" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dhcp"."global_options" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "network"."switchport_states" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "network"."switchport_macs" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "network"."switchview" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "network"."switchport_history" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dhcp"."range_options" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."soa" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."srv" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."cname" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."zone_txt" TO "impulse_client";
GRANT SELECT,INSERT,UPDATE,DELETE ON "dns"."zone_a" TO "impulse_client";

/* Special Data
	Read or Write only, not both
*/
GRANT SELECT,INSERT ON "management"."log_master" TO "impulse_client";
GRANT SELECT,INSERT ON "management"."output" TO "impulse_client";

GRANT USAGE,SELECT ON SEQUENCE "management"."output_id_seq" TO "impulse_client";
