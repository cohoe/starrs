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

/* dns.txt */
CREATE TRIGGER "dns_zone_txt_insert"
BEFORE INSERT ON "dns"."zone_txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."zone_txt_insert"();

CREATE TRIGGER "dns_zone_txt_update"
BEFORE UPDATE ON "dns"."zone_txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."zone_txt_update"();

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

/* systems.interface_addresses */
CREATE TRIGGER "systems_interface_addresses_insert"
BEFORE INSERT ON "systems"."interface_addresses"
FOR EACH ROW EXECUTE PROCEDURE "systems"."interface_addresses_insert"();

CREATE TRIGGER "systems_interface_addresses_update"
BEFORE UPDATE ON "systems"."interface_addresses"
FOR EACH ROW EXECUTE PROCEDURE "systems"."interface_addresses_update"();

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
FOR EACH ROW EXECUTE PROCEDURE "dns"."ns_query_insert"();

CREATE TRIGGER "dns_ns_update_queue"
AFTER UPDATE ON "dns"."ns"
FOR EACH ROW EXECUTE PROCEDURE "dns"."ns_query_update"();

CREATE TRIGGER "dns_ns_delete_queue"
AFTER DELETE ON "dns"."ns"
FOR EACH ROW EXECUTE PROCEDURE "dns"."ns_query_delete"();

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
FOR EACH ROW EXECUTE PROCEDURE "dns"."txt_query_insert"();

CREATE TRIGGER "dns_txt_update_queue"
AFTER UPDATE ON "dns"."txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."txt_query_update"();

CREATE TRIGGER "dns_txt_delete_queue"
AFTER DELETE ON "dns"."txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."txt_query_delete"();

CREATE TRIGGER "dns_zone_txt_insert_queue"
AFTER INSERT ON "dns"."zone_txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."txt_query_insert"();

CREATE TRIGGER "dns_zone_txt_update_queue"
AFTER UPDATE ON "dns"."zone_txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."txt_query_update"();

CREATE TRIGGER "dns_zone_txt_delete_queue"
AFTER DELETE ON "dns"."zone_txt"
FOR EACH ROW EXECUTE PROCEDURE "dns"."txt_query_delete"();

CREATE TRIGGER "dns_zone_a_insert"
BEFORE INSERT ON "dns"."zone_a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."zone_a_insert"();

CREATE TRIGGER "dns_zone_a_update"
BEFORE UPDATE ON "dns"."zone_a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."zone_a_update"();

CREATE TRIGGER "dns_zone_a_delete"
BEFORE DELETE ON "dns"."zone_a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."zone_a_delete"();

CREATE TRIGGER "dns_zone_a_insert_queue"
AFTER INSERT ON "dns"."zone_a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_insert"();

CREATE TRIGGER "dns_zone_a_update_queue"
AFTER UPDATE ON "dns"."zone_a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_update"();

CREATE TRIGGER "dns_zone_a_delete_queue"
AFTER DELETE ON "dns"."zone_a"
FOR EACH ROW EXECUTE PROCEDURE "dns"."queue_delete"();
