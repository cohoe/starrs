<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Impulselib {

	private $fname;
	private $lname;
	private $uname;
	private $CI;

	function __construct() {
		$CI =& get_instance();
		$this->uname = $CI->input->server('WEBAUTH_USER');
		$this->fname = $CI->input->server('WEBAUTH_LDAP_GIVENNAME');
		$this->lname = $CI->input->server('WEBAUTH_LDAP_SN');
		#$this->uname = "user";
		#$this->fname = "Grant";
		#$this->lname = "Cohoe";
	}

	function get_eui64_address($mac)
	{
		return $mac;
	}
	
	function get_os_img_path($osname)
	{
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

		return $paths[$osname];
	}
	
	public function remove_url_space($url) {
		return preg_replace("/%20/"," ",$url);
	}
	
	public function set_session($key, $value) {
		session_start();
		$_SESSION[$key] = $value;
	}
	
	public function get_session($key) {
		session_start();
		return $_SESSION[$key];
	}
	
	public function clear_session($key) {
		session_start();
		unset($_SESSION[$key]);
	}

	public function get_username() {
		return $this->uname;
	}

	public function get_name() {
		return "$this->fname $this->lname";
	}
}

/* End of file Impulselib.php */
