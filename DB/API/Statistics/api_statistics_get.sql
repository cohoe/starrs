CREATE OR REPLACE FUNCTION api.get_range_utilization() RETURNS TABLE("name" text, inuse integer, free integer, total integer) AS $$
	BEGIN
		RETURN QUERY (SELECT api.get_address_range("address"),COUNT(api.get_address_range("address"))::integer,
		(("last_ip"-"first_ip")::integer - COUNT(api.get_address_range("address"))::integer),
		("last_ip"-"first_ip")::integer AS "total" 
		FROM "systems"."interface_addresses" 
		JOIN "ip"."ranges" 
		ON "ip"."ranges"."name" = api.get_address_range("address") 
		WHERE api.get_address_range("address") 
		IN (SELECT "ip"."ranges"."name" FROM "ip"."ranges") GROUP BY api.get_address_range("address"),"total");
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.get_subnet_utilization() RETURNS TABLE("subnet" cidr, inuse integer, free integer, total integer) AS $$
	BEGIN
		RETURN QUERY (SELECT "ip"."subnets"."subnet",
			(SELECT COUNT("systems"."interface_addresses"."address") FROM "systems"."interface_addresses" WHERE "systems"."interface_addresses"."address" << "ip"."subnets"."subnet")::integer as "inuse",
			(SELECT COUNT("ip"."addresses"."address") FROM "ip"."addresses" WHERE "ip"."addresses"."address" << "ip"."subnets"."subnet")::integer AS "total",
			((SELECT count("ip"."addresses"."address") FROM "ip"."addresses" WHERE "ip"."addresses"."address" << "ip"."subnets"."subnet")::integer - (SELECT count("systems"."interface_addresses"."address") FROM "systems"."interface_addresses" WHERE "systems"."interface_addresses"."address" << "ip"."subnets"."subnet")::integer) AS "free"
			FROM "ip"."subnets" GROUP BY "ip"."subnets"."subnet");
	END;
$$ LANGUAGE plpgsql;