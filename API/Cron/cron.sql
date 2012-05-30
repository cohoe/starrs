CREATE OR REPLACE FUNCTION "cron"."network_switchview"() RETURNS VOID AS $$
	DECLARE
		Systems RECORD;
	BEGIN
		PERFORM api.create_log_entry('CRON', 'DEBUG', 'Beginning switchview scan');
		
		FOR Systems IN (SELECT system_name FROM api.get_systems(NULL) WHERE FAMILY = 'Network') LOOP
			PERFORM api.switchview_scan_admin_state(Systems.system_name);
			PERFORM api.switchview_scan_port_state(Systems.system_name);
			PERFORM api.switchview_scan_mac(Systems.system_name);
			PERFORM api.switchview_scan_description(Systems.system_name);
		END LOOP;

		PERFORM api.create_log_entry('CRON', 'DEBUG', 'Completed switchview scan');
	END;
$$ LANGUAGE 'plpgsql';