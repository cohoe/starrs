<?php
class Navbar {

	private $options = array();
	private $title;
	private $editable;
	private $deletable;
	private $activePage;
	private $context;
	private $user;
	private $priv;
	private $CI;

	public function __construct($title, $editable, $deletable, $activePage, $context, $options) {
		$this->title = $title;
		$this->editable = $editable;
		$this->deletable = $deletable;
		$this->activePage = $activePage;
		$this->context = $context;

		$this->CI =& get_instance();
		
		// @todo: add code to get the current user
	
		foreach(array_keys($options) as $option) {
			$this->options[] = array("title"=>$option,"link"=>$options[$option]);
		}

		$this->user = $this->CI->impulselib->get_name();
		$this->priv = $this->CI->api->get_current_user_level();
		#$this->user = $this->CI->api->get_current_user_level();
	}

	//////////////////////////////////////////////////////////////////////
	/// SETTERS
	public function add_option($option,$link) 	{ $this->options[] = array("title"=>$option,"link"=>$link); }
	public function set_title($title) 			{ $this->title = $title; }
	public function set_editable($edit) 		{ $this->editable = $edit; }
	public function set_active_page($page)		{ $this->activePage = $page; }
	public function set_context($url)			{ $this->context = $url; }
	public function set_deletable($delete)		{ $this->deletable = $delete; }

	//////////////////////////////////////////////////////////////////////
	/// GETTERS
	public function get_options()		{ return $this->options; }
	public function get_title()			{ return $this->title; }
	public function get_editable()		{ return $this->editable; }
	public function get_active_page()	{ return $this->activePage; }
	public function get_context()		{ return $this->context; }
	public function get_deletable()		{ return $this->deletable; }
	public function get_user()		{ return $this->user; }
	public function get_priv()		{ return $this->priv; }
}
