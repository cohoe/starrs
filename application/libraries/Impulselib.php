<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Library of general functions for the operation of IMPULSE
 */
class Impulselib {

	private $fname;
	private $lname;
	private $uname;
	private $CI;

    /**
     * Constructor. This will load in your identification information for use in privilege leveling
     */
	function __construct() {
		$CI =& get_instance();
		#$this->uname = $CI->input->server('WEBAUTH_USER');
		#$this->fname = $CI->input->server('WEBAUTH_LDAP_GIVENNAME');
		#$this->lname = $CI->input->server('WEBAUTH_LDAP_SN');
		$this->uname = "user";
		$this->fname = "Grant";
		$this->lname = "Cohoe";
	}

    /**
     * Get a standard IPv6 autoconf address from your MAC address
     * @param $mac  The MAC address of the interface
     * @return string
     */
	function get_eui64_address($mac) {
		return $mac;
	}

    /**
     * Get the path of the OS image based on the OS name
     * @param $osname   The name of the OS to get
     * @return
     */
	function get_os_img_path($osname) {
		$paths['Arch'] = "media/images/os/Arch.jpg";
		$paths['CentOS'] = "media/images/os/CentOS.jpg";
		$paths['Cisco IOS'] = "media/images/os/Cisco IOS.jpg";
		$paths['Debian'] = "media/images/os/Debian.jpg";
		$paths['Exherbo'] = "media/images/os/Exherbo.jpg";
		$paths['Fedora'] = "media/images/os/Fedora.jpg";
		$paths['FreeBSD'] = "media/images/os/FreeBSD.jpg";
		$paths['Gentoo'] = "media/images/os/Gentoo.jpg";
		$paths['NetBSD'] = "media/images/os/NetBSD.jpg";
		$paths['OpenBSD'] = "media/images/os/OpenBSD.jpg";
		$paths['Slackware'] = "media/images/os/Slackware.jpg";
		$paths['Ubuntu'] = "media/images/os/Ubuntu.jpg";
		$paths['Windows 7'] = "media/images/os/Windows7.jpg";
		$paths['Windows Server 2003'] = "media/images/os/WindowsServer2003.jpg";
		$paths['Windows Server 2008'] = "media/images/os/WindowsServer2008.jpg";
		$paths['Windows Server 2008 R2'] = "media/images/os/WindowsServer2008R2.jpg";
		$paths['Windows Vista'] = "media/images/os/WindowsVista.jpg";
		$paths['Windows XP'] = "media/images/os/WindowsXP.jpg";
		$paths['Mac OS X'] = "media/images/os/MacOSX.jpg";

		return $paths[$osname];
	}

    /**
     * Clean up a URL that has spaces in it to have %20's
     * @param $url  The URL to parse
     * @return string
     */
	public function remove_url_space($url) {
		return preg_replace("/%20/"," ",$url);
	}

    /**
     * Get your username
     * @return string
     */
	public function get_username() {
		return $this->uname;
	}

    /**
     * Get your real name
     * @return string
     */
	public function get_name() {
		return "$this->fname $this->lname";
	}

    /**
     * Get the object of the current active system from $_SESSION
     * @return System
     */
	public function get_active_system() {
        // Check if the session was started
		if(session_id() == "") { 
			session_start();
		}

        // I have no idea why this works.
        require_once(APPPATH . "controllers/systems.php");
        if(!isset($_SESSION['activeSystem'])) {
            throw new ObjectNotFoundException("Could not find your system. Make sure you aren't pulling any URL shenanigans. Otherwise, click Systems on the left and start again.");
        }
		return unserialize($_SESSION['activeSystem']);
	}

    /**
     * Set the active system in $_SESSION
     * @param $sys  The system to set to
     * @return void
     */
	public function set_active_system($sys) {
        // Check if the session was started
		if(session_id() == "") { 
			session_start();
		}

        // Set it up!
		$_SESSION['activeSystem'] = serialize($sys);
	}

    /**
     * Clean up Postgres's extreme timestamp to only have what we want
     * @param $timestamp    The timestamp string to parse
     * @return string
     */
	public function clean_timestamp($timestamp) { 
		return preg_replace('/:(\d+).(\d+)$/','',$timestamp); 
	}
	
}

/* End of file Impulselib.php */
/* Location: ./application/libraries/Impulselib.php */