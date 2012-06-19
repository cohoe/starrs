-- Inserts

/* BASIC SYSTEM INFORMATION
Useful for collecting metrics on OS usage and device types. Much better than Chuckles' scan-the-network-a-lot
*/

SELECT api.initialize('root');

/* Supported System Types
Lets us see what all is on the network
*/
INSERT INTO "systems"."device_types" 
	("type","family") VALUES 
	('Router','Network'),('Firewall','Network'),('Switch','Network'),('Hub','Network'),('Wireless Access Point','Network'),('Desktop','PC'),('Server','PC'),('Virtual Machine','PC'),('Laptop','PC'),('Printer','PC'),('Game Console','PC');
	
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
	('Windows'),('Linux'),('BSD'),('Mac'),('UNIX'),('Solaris'),('Other');

/* OS Distribution
Better than chuckles' scan-everyone method of figuring out what OS's are on the network
*/
INSERT INTO "systems"."os" 
	("name", "family") VALUES 
	('Cisco IOS','Other'),
	('Windows XP','Windows'),
	('Windows Vista','Windows'),
	('Windows 7','Windows'),
	('Windows Server 2003','Windows'),
	('Windows Server 2008','Windows'),
	('Windows Server 2008 R2','Windows'),
	('Gentoo','Linux'),
	('Ubuntu','Linux'),
	('Fedora','Linux'),
	('CentOS','Linux'),
	('Slackware','Linux'),
	('Arch','Linux'),
	('Exherbo','Linux'),
	('Scientific','Linux'),
	('RHEL','Linux'),
	('Debian','Linux'),
	('FreeBSD','BSD'),
	('OpenBSD','BSD'),
	('Mac OS X', 'Mac'),
	('NetBSD','BSD'),
	('XBox','Other'),
	('PS3','Other'),
	('Wii','Other'),
	('Plan9','UNIX'),
	('GNU/Hurd','UNIX'),
	('Haiku','Other'),
	('BeOS','Other'),
	('OpenIndiana','Solaris'),
	('OpenSolaris','Solaris'),
	('Solaris','Solaris'),
	('Illumos','Solaris'),
	('Vyatta','Other'),
	('Other','Other');
	
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
	
/* DNS types
	record types for DNS
*/
INSERT INTO "dns"."types" ("type","comment") VALUES
	('A','IPv4 address'),
	('AAAA','IPv6 address'),
	('NS','Nameserver'),
	('MX','Mail Exchange'),
	('TXT','Text'),
	('CNAME','Pointer'),
	('SRV','Special service');
	
