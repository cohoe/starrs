<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_network_get extends ImpulseModel {

    public function switchports($systemName) {
		// SQL Query
		$sql = "SELECT * FROM api.get_network_switchports({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $port) {
			$sPort = new NetworkSwitchport(
                $port['system_name'],
				$port['port_name'],
                $port['type'],
				$port['description'],
                $port['port_state'],
                $port['admin_state'],
				$port['date_created'],
				$port['date_modified'],
				$port['last_modifier']
			);

            try {
                $macaddrs = $this->switchport_macs($sPort->get_system_name(),$sPort->get_port_name());
                foreach($macaddrs as $macaddr) {
                    $sPort->add_mac_address($macaddr);
                }
            }
            catch(ObjectNotFoundException $onfE) {};

            $resultSet[] = $sPort;
		}

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No switchports found!");
		}
	}
	
	public function switchport($systemName, $portName) {
		// SQL Query
		$sql = "SELECT * FROM api.get_network_switchport({$this->db->escape($systemName)},{$this->db->escape($portName)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
		
		if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("Multiple ports returned?");
        }

		// Generate results
		$sPort = new NetworkSwitchport(
			$query->row()->system_name,
			$query->row()->port_name,
			$query->row()->type,
			$query->row()->description,
			$query->row()->port_state,
			$query->row()->admin_state,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);

		try {
			$macaddrs = $this->switchport_macs($sPort->get_system_name(),$sPort->get_port_name());
			foreach($macaddrs as $macaddr) {
				$sPort->add_mac_address($macaddr);
			}
		}
		catch(ObjectNotFoundException $onfE) {};


		// Return results
		if($sPort instanceof NetworkSwitchport) {
			return $sPort;
		}
		else {
			throw new ObjectNotFoundException("No switchport found!");
		}
	}

    public function types() {
        // SQL Query
        $sql = "SELECT api.get_network_switchport_types()";
        $query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $type) {
			$resultSet[] = $type['get_network_switchport_types'];
		}

        // Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No switchport types found. This is a big problem. Talk to your administrator.");
		}
    }

    public function switchview_settings($systemName) {
        // SQL Query
        $sql = "SELECT * FROM api.get_network_switchview_settings({$this->db->escape($systemName)})";
        $query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

        if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("Multiple settings returned?");
        }

		// Generate results
        return $query->row_array();
    }

    public function switchport_macs($systemName, $portName) {
        // SQL Query
        $sql = "SELECT * FROM api.get_network_switchport_macs({$this->db->escape($systemName)},{$this->db->escape($portName)})";
        $query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

        // Generate results
        $resultSet = array();
        foreach($query->result_array() as $result) {
            $resultSet[] = $result['get_network_switchport_macs'];
        }

        // Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No MACs found.");
		}
    }
	
	public function switchport_history($systemName, $portName) {
		// SQL Query
        $sql = "SELECT * FROM api.get_network_switchport_history({$this->db->escape($systemName)},{$this->db->escape($portName)})";
        $query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

        // Generate results
        $resultSet = array();
        foreach($query->result_array() as $result) {
            $resultSet[$result['time']][] = $result['mac'];
        }

        // Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No MAC history for this switchport found.");
		}
	}
}
/* End of file api_network_get.php */
/* Location: ./application/models/API/Network/api_network_get.php */