-- Inserts

/* BASIC SYSTEM INFORMATION
Useful for collecting metrics on OS usage and device types. Much better than Chuckles' scan-the-network-a-lot
*/

SELECT api.initialize('IMPULSE Installer');

/* Supported System Types
Lets us see what all is on the network
*/
INSERT INTO "systems"."device_types" 
	("type") VALUES 
	('Router'),('Firewall'),('Switch'),('Hub'),('Wireless Access Point'),('Desktop'),('Server'),('Virtual Machine'),('Laptop');
	
/* Network Port Types
For configuring views for Uplinks, trunks, and other such things
*/
INSERT INTO "network"."switchport_types"
	("type") VALUES
	('Uplink'),('Access'),('VLAN'),('Trunk');

/* OS Family
For seeing overall who uses what
*/
INSERT INTO "systems"."os_family" 
	("family") VALUES 
	('Windows'),('Linux'),('BSD'),('Mac'),('Other');

/* OS Distribution
Better than chuckles' scan-everyone method of figuring out what OS's are on the network
*/
INSERT INTO "systems"."os" 
	("name", "default_connection_name", "family") VALUES 
	('Cisco IOS','VLAN','Other'),
	('Windows XP','Local Area Connection','Windows'),
	('Windows Vista','Local Area Connection','Windows'),
	('Windows 7','Local Area Connection','Windows'),
	('Windows Server 2003','Local Area Connection','Windows'),
	('Windows Server 2008','Local Area Connection','Windows'),
	('Windows Server 2008 R2','Local Area Connection','Windows'),
	('Gentoo','eth0','Linux'),
	('Ubuntu','eth0','Linux'),
	('Fedora','eth0','Linux'),
	('CentOS','eth0','Linux'),
	('Slackware','eth0','Linux'),
	('Arch','eth0','Linux'),
	('Exherbo','eth0','Linux'),
	('Debian','eth0','Linux'),
	('FreeBSD','fxp0','BSD'),
	('OpenBSD','xx0','BSD'),
	('NetBSD','xx0','BSD');
	
/* NETWORK INFORMATION
Use a table to keep track of all active IP addresses and what they are used for. IP's must be activated here before they can be handed out
Address ranges may be configured to allow for more control of the network.
*/

/* Range Uses
This specifies what the purposes for each range can be. Dynamic, static, DHCP, etc
*/
INSERT INTO "ip"."range_uses"
	("use", "comment") VALUES
	('UREG','User registration'),
	('ROAM','Dynamic (roaming)'),
	('AREG','Auto registration'),
	('RESV','Reserved');
	
/* DHCP Configuration Types
Available address configuration types. Each of these determines a certain type of class as well. 
*/
INSERT INTO "dhcp"."config_types"
	("config","family","comment") VALUES
	('dhcp',4,'Regular DHCP'),
	('dhcpv6',6,'DHCPv6'),
	('static',0,'Manually assigned'),
	('autoconf',6,'Generated via MAC address');
	
/* FIREWALL
Firewall options. This will require its own custom script to get working. This script is outside the scope of this project.
*/

/*Firewall transports. 
What to block
*/
INSERT INTO "firewall"."transports"
	("transport") VALUES
	('TCP'),('UDP'),('BOTH'),('ICMP'),('ICMPv6');
	
	
/* Firewall Programs
	Common programs for easy use
*/
INSERT INTO "firewall"."programs"
	("name","port","transport") VALUES
	('SSH',22,'TCP'),
	('LDAP',389,'TCP'),
	('HTTP',80,'TCP'),
	('HTTPS',443,'TCP'),
	('RDP',3389,'TCP'),
	('DNS',53,'BOTH');

/* Firewall Software
	How to format firewall rules
*/
INSERT INTO "firewall"."software" ("software_name") VALUES ('Cisco IOS'),('iptables'),('pf');

/* Processes
	The output jobs
*/
