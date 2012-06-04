/* dns.a */
CREATE TRIGGER "dns_a_insert"
BEFORE INSERT ON "dns"."a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."a_insert"();

CREATE TRIGGER "dns_a_update"
BEFORE UPDATE ON "dns"."a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."a_update"();

/* dns.mx */
CREATE TRIGGER "dns_mx_insert"
BEFORE INSERT ON "dns"."mx"
FOR EACH ROW EXECUTE PROCEDURE "dns"."mx_insert"();

CREATE TRIGGER "dns_mx_update"
BEFORE UPDATE ON "dns"."mx"
FOR EACH ROW EXECUTE PROCEDURE "dns"."mx_update"();

/* dns.ns */
CREATE TRIGGER "dns_ns_insert"
BEFORE INSERT ON "dns"."ns"
FOR EACH ROW EXECUTE PROCEDURE "dns"."ns_insert"();

CREATE TRIGGER "dns_ns_update"
BEFORE UPDATE ON "dns"."ns"
FOR EACH ROW EXECUTE PROCEDURE "dns"."ns_update"();

/* dns.srv */
CREATE TRIGGER "dns_srv_insert"
BEFORE INSERT ON "dns"."srv"
FOR EACH ROW EXECUTE PROCEDURE "dns"."srv_insert"();

CREATE TRIGGER "dns_srv_update"
BEFORE UPDATE ON "dns"."srv"
FOR EACH ROW EXECUTE PROCEDURE "dns"."srv_update"();

/* dns.cname */
CREATE TRIGGER "dns_cname_insert"
BEFORE INSERT ON "dns"."cname"
FOR EACH ROW EXECUTE PROCEDURE "dns"."cname_insert"();

CREATE TRIGGER "dns_cname_update"
BEFORE UPDATE ON "dns"."cname"
FOR EACH ROW EXECUTE PROCEDURE "dns"."cname_update"();

/* dns.txt */
CREATE TRIGGER "dns_txt_insert"
BEFORE INSERT ON "dns"."txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."txt_insert"();

CREATE TRIGGER "dns_txt_update"
BEFORE UPDATE ON "dns"."txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."txt_update"();

/* firewall.metahost_members */
CREATE TRIGGER "firewall_metahost_members_insert"
BEFORE INSERT ON "firewall"."metahost_members"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."metahost_members_insert"();

CREATE TRIGGER "firewall_metahost_members_delete"
BEFORE DELETE ON "firewall"."metahost_members"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."metahost_members_delete"();

/* firewall.metahost_rules */
CREATE TRIGGER "firewall_metahost_rules_insert"
BEFORE INSERT ON "firewall"."metahost_rules"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."metahost_rules_insert"();

CREATE TRIGGER "firewall_metahost_rules_update"
BEFORE UPDATE ON "firewall"."metahost_rules"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."metahost_rules_update"();

CREATE TRIGGER "firewall_metahost_rules_delete"
BEFORE DELETE ON "firewall"."metahost_rules"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."metahost_rules_delete"();

/* ip.addresses */
CREATE TRIGGER "ip_addresses_insert"
BEFORE INSERT ON "ip"."addresses"
FOR EACH ROW EXECUTE PROCEDURE "ip"."addresses_insert"();

/* ip.ranges */
CREATE TRIGGER "ip_ranges_insert"
BEFORE INSERT ON "ip"."ranges"
FOR EACH ROW EXECUTE PROCEDURE "ip"."ranges_insert"();

CREATE TRIGGER "ip_ranges_update"
BEFORE UPDATE ON "ip"."ranges"
FOR EACH ROW EXECUTE PROCEDURE "ip"."ranges_update"();

/* ip.subnets */
CREATE TRIGGER "ip_subnets_insert"
BEFORE INSERT ON "ip"."subnets"
FOR EACH ROW EXECUTE PROCEDURE "ip"."subnets_insert"();

CREATE TRIGGER "ip_subnets_update"
BEFORE UPDATE ON "ip"."subnets"
FOR EACH ROW EXECUTE PROCEDURE "ip"."subnets_update"();

CREATE TRIGGER "ip_subnets_delete"
BEFORE DELETE ON "ip"."subnets"
FOR EACH ROW EXECUTE PROCEDURE "ip"."subnets_delete"();

/* network.switchports */
CREATE TRIGGER "network_switchports_insert"
BEFORE INSERT ON "network"."switchports"
FOR EACH ROW EXECUTE PROCEDURE "network"."switchports_insert"();

CREATE TRIGGER "network_switchports_update"
BEFORE UPDATE ON "network"."switchports"
FOR EACH ROW EXECUTE PROCEDURE "network"."switchports_update"();

/* systems.interface_addresses */
CREATE TRIGGER "systems_interface_addresses_insert"
BEFORE INSERT ON "systems"."interface_addresses"
FOR EACH ROW EXECUTE PROCEDURE "systems"."interface_addresses_insert"();

CREATE TRIGGER "systems_interface_addresses_update"
BEFORE UPDATE ON "systems"."interface_addresses"
FOR EACH ROW EXECUTE PROCEDURE "systems"."interface_addresses_update"();

/* firewall rule programs */
CREATE TRIGGER "firewall_rule_program_insert"
BEFORE INSERT ON "firewall"."program_rules"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."rule_program_insert"();

CREATE TRIGGER "firewall_metahost_rule_program_insert"
BEFORE INSERT ON "firewall"."metahost_program_rules"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."metahost_rule_program_insert"();

/* firewall rule programs */
CREATE TRIGGER "firewall_rule_program_delete"
BEFORE DELETE ON "firewall"."program_rules"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."rule_program_delete"();

CREATE TRIGGER "firewall_metahost_rule_program_delete"
BEFORE DELETE ON "firewall"."metahost_program_rules"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."metahost_rule_program_delete"();

CREATE TRIGGER "dns_a_insert_queue"
AFTER INSERT ON "dns"."a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_insert"();

CREATE TRIGGER "dns_a_update_queue"
AFTER UPDATE ON "dns"."a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_update"();

CREATE TRIGGER "dns_a_delete_queue"
AFTER DELETE ON "dns"."a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_delete"();

CREATE TRIGGER "dns_srv_insert_queue"
AFTER INSERT ON "dns"."srv"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_insert"();

CREATE TRIGGER "dns_srv_update_queue"
AFTER UPDATE ON "dns"."srv"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_update"();

CREATE TRIGGER "dns_srv_delete_queue"
AFTER DELETE ON "dns"."srv"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_delete"();

CREATE TRIGGER "dns_cname_insert_queue"
AFTER INSERT ON "dns"."cname"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_insert"();

CREATE TRIGGER "dns_cname_update_queue"
AFTER UPDATE ON "dns"."cname"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_update"();

CREATE TRIGGER "dns_cname_delete_queue"
AFTER DELETE ON "dns"."cname"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_delete"();

CREATE TRIGGER "dns_ns_insert_queue"
AFTER INSERT ON "dns"."ns"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_insert"();

CREATE TRIGGER "dns_ns_update_queue"
AFTER UPDATE ON "dns"."ns"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_update"();

CREATE TRIGGER "dns_ns_delete_queue"
AFTER DELETE ON "dns"."ns"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_delete"();

CREATE TRIGGER "dns_mx_insert_queue"
AFTER INSERT ON "dns"."mx"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_insert"();

CREATE TRIGGER "dns_mx_update_queue"
AFTER UPDATE ON "dns"."mx"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_update"();

CREATE TRIGGER "dns_mx_delete_queue"
AFTER DELETE ON "dns"."mx"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_delete"();

CREATE TRIGGER "dns_txt_insert_queue"
AFTER INSERT ON "dns"."txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_insert"();

CREATE TRIGGER "dns_txt_update_queue"
AFTER UPDATE ON "dns"."txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_update"();

CREATE TRIGGER "dns_txt_delete_queue"
AFTER DELETE ON "dns"."txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_delete"();

CREATE TRIGGER "firewall_defaults_insert"
AFTER INSERT ON "firewall"."defaults"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."defaults_insert"();

CREATE TRIGGER "firewall_defaults_update"
AFTER UPDATE ON "firewall"."defaults"
FOR EACH ROW EXECUTE PROCEDURE "firewall"."defaults_update"();

CREATE TRIGGER "network_switchport_states_update"
BEFORE UPDATE ON "network"."switchport_states"
FOR EACH ROW EXECUTE PROCEDURE "network"."switchport_states_update"();