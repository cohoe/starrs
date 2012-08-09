SELECT api.initialize('root');

SELECT api.create_site_configuration('DEFAULT_CONFIG_TYPE','static');
SELECT api.create_site_configuration('DEFAULT_DATACENTER','Rochester');
SELECT api.create_site_configuration('DEFAULT_GROUP','Users');
SELECT api.create_site_configuration('DEFAULT_INTERFACE_NAME','Main Interface');
SELECT api.create_site_configuration('DEFAULT_LOCAL_ADMIN_GROUP','Administrators');
SELECT api.create_site_configuration('DEFAULT_LOCAL_USER_GROUP','Users');
SELECT api.create_site_configuration('DEFAULT_RENEW_INTERVAL','1 year');
SELECT api.create_site_configuration('DEFAULT_SYSTEM_PLATFORM','Custom');
SELECT api.create_site_configuration('DEFAULT_SYSTEM_TYPE','Server');
SELECT api.create_site_configuration('DHCPD_DEFAULT_CLASS','default');
SELECT api.create_site_configuration('DNS_DEFAULT_TTL','3600');
SELECT api.create_site_configuration('DNS_DEFAULT_ZONE','example.com');
SELECT api.create_site_configuration('DYNAMIC_SUBNET','1.1.0.0/16');
SELECT api.create_site_configuration('EMAIL_DOMAIN','example.com');
SELECT api.create_site_configuration('EMAIL_NOTIFICATION_INTERVAL','7 days');
SELECT api.create_site_configuration('USER_PRIVILEGE_SOURCE','local');
SELECT api.create_site_configuration('WEB_URL','https://starrs.example.com');

SELECT api.create_group('Administrators','ADMIN','Admin users','10 years');
SELECT api.create_group('Users','USER','Regular users','1 year');

SELECT api.create_group_member('Administrators','root','ADMIN');
SELECT api.create_group_member('Users','root','ADMIN');
SELECT api.create_group_member('Users','user','USER');

SELECT api.create_datacenter('Rochester','Rochester NY USA');

SELECT api.create_availability_zone('Rochester','Corp','Corporate network');
SELECT api.create_availability_zone('Rochester','Secure','Secure network');

SELECT api.create_vlan('Rochester',1, 'Management','Management VLAN');
SELECT api.create_vlan('Rochester',49, '49net','Server room');
SELECT api.create_vlan('Rochester',50, '50net','Users');

SELECT api.create_dns_key('testkey','F00b@r','rc4-hmac','root','Test key');

SELECT api.create_dns_zone('example.com','testkey',true,true,'root','Root zone',false);

SELECT api.create_ip_subnet('10.0.49.0/24','49v4','VLAN49 subnet',true,false,'example.com','root','Rochester',49);
SELECT api.create_ip_subnet('10.0.50.0/24','50v4','VLAN50 subnet',true,false,'example.com','root','Rochester',50);
SELECT api.create_ip_subnet('2001:49::/64','49v6','VLAN49 IPv6 subnet',false,false,'example.com','root','Rochester',49);
SELECT api.create_ip_subnet('2001:50::/64','50v6','VLAN50 IPv6 subnet',false,false,'example.com','root','Rochester',50);

SELECT api.create_dhcp_class('default','Default class');

SELECT api.create_ip_range('Servers','10.0.49.1','10.0.49.200','10.0.49.0/24','UREG','default','Server registrations','Rochester','Corp');
SELECT api.create_ip_range('Servers IPv6','2001:49::1','2001:49::255','2001:49::/64','UREG','default','Server registrations','Rochester','Corp');
SELECT api.create_ip_range('Users','10.0.50.1','10.0.50.200','10.0.50.0/24','UREG','default','User registrations','Rochester','Corp');
SELECT api.create_ip_range('Users IPv6','2001:50::1','2001:50::255','2001:50::/64','UREG','default','Server registrations','Rochester','Corp');
