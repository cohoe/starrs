<?php
/**
 *
 */
class Navbar {

	private $navOptions = array();
	private $create = FALSE;
	private $edit = FALSE;
	private $delete = FALSE;
	private $cancel = FALSE;
	private $createLink;
	private $editLink;
	private $deleteLink;
	private $cancelLink;
	private $title;
	private $activePage;
	private $context;
	private $referer;
	private $user;
	private $priv;
	private $CI;

    /**
     * @param $title
     * @param $modes
     * @param $navOptions
     */
	public function __construct($title, $modes, $navOptions) {
		
		$this->CI =& get_instance();

		$this->title = $title;
		$this->activePage = $this->CI->uri->segment(2);
		$this->context = $this->CI->input->server('REQUEST_URI');
		$this->referer = $this->CI->input->server('HTTP_REFERER');

		
		// @todo: add code to get the current user
		if(count($navOptions) > 0) {
			foreach(array_keys($navOptions) as $option) {
				$this->navOptions[] = array("title"=>$option,"link"=>$navOptions[$option]);
			}
		}
		
		if(isset($modes['CREATE'])) {
			$this->create = TRUE;
			$this->createLink = $modes['CREATE'];
		}
		if(isset($modes['EDIT'])) {
			$this->edit = TRUE;
			$this->editLink = $modes['EDIT'];
		}
		if(isset($modes['DELETE'])) {
			$this->delete = TRUE;
			$this->deleteLink = $modes['DELETE'];
		}
		if(isset($modes['CANCEL'])) {
			$this->cancel = TRUE;
			$this->cancelLink = $this->referer;
		}

		$this->user = $this->CI->impulselib->get_name();
		$this->priv = $this->CI->api->management->get_current_user_level();
		#$this->user = $this->CI->api->get_current_user_level();
	}

	//////////////////////////////////////////////////////////////////////
	/// SETTERS
	public function add_option($option,$link) 	{ $this->navOptions[] = array("title"=>$option,"link"=>$link); }
	public function set_title($title) 			{ $this->title = $title; }
	public function set_edit($edit,$url) 		{ $this->edit = $edit;		$this->editLink = $url; }
	public function set_active_page($page)		{ $this->activePage = $page; }
	public function set_context($url)			{ $this->context = $url; }
	public function set_delete($delete,$url)	{ $this->delete = $delete;	$this->deleteLink = $url; }
	public function set_create($create,$url)	{ $this->create = $create;	$this->createLink = $url; }

	//////////////////////////////////////////////////////////////////////
	/// GETTERS
	public function get_navOptions()	{ return $this->navOptions; }
	public function get_title()			{ return $this->title; }
	public function get_edit()		{ return $this->edit; }
	public function get_active_page()	{ return $this->activePage; }
	public function get_context()		{ return $this->context; }
	public function get_delete()		{ return $this->delete; }
	public function get_user()			{ return $this->user; }
	public function get_priv()			{ return $this->priv; }
	public function get_cancel()	{ return $this->cancel; }
	public function get_create_link()	{ return $this->createLink; }
	public function get_edit_link()		{ return $this->editLink; }
	public function get_delete_link()	{ return $this->deleteLink; }
	public function get_cancel_link()	{ return $this->cancelLink; }
	public function get_create()		{ return $this->create; }
}
