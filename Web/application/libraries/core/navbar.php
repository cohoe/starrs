<?php
/**
 * The navigation bar across all pages. 
 */
class Navbar {

    ////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

    // array<String>    Array of places you can go from your current page
	private $navOptions = array();

    // boolean          Display the create button
	private $create = FALSE;

    // boolean          Display the edit button
	private $edit = FALSE;

    // boolean          Display the delete button
	private $delete = FALSE;

    // boolean          Display the cancel button
	private $cancel = FALSE;

    // string           The link for the create button
	private $createLink;

    // string           The link for the edit button
	private $editLink;

    // string           The link for the delete button
	private $deleteLink;

    // string           The link for the cancel button
	private $cancelLink;
	
	// string			The link for the help button
	private $helpLink;

    // string           The page title to display in the bar
	private $title;

    // string           The page that we are on
	private $activePage;

    // string           The URL that the browser is currently at
	private $context;

    // string           The place you came from
	private $referer;

    // string           Your name
	private $user;

    // string           Your privilege level
	private $priv;

    //                  The CI outside world
	private $CI;

    ////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    /**
     * @param $title        The title of the bar
     * @param $modes        The modes to activate
     * @param $navOptions   The options to display
     */
	public function __construct($title, $modes, $navOptions) {

        // Load the CI world
		$this->CI =& get_instance();

        // Set some basic information
		$this->title = $title;
		$this->activePage = $this->CI->uri->segment(2);
		$this->context = $this->CI->input->server('REQUEST_URI');
		$this->referer = $this->CI->input->server('HTTP_REFERER');

		// Load the navigation options
		if(count($navOptions) > 0) {
			foreach(array_keys($navOptions) as $option) {
				$this->navOptions[] = array("title"=>$option,"link"=>$navOptions[$option]);
			}
		}

        // Check for which modes we are in
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
			if($modes['CANCEL'] == "") {
				$this->cancelLink = $this->referer;
			}
			else {
				$this->cancelLink = $modes['CANCEL'];
			}
		}
		if(isset($modes['HELP'])) {
			#$this->helpLink = $modes['HELP'];
		}

        $object = $this->CI->uri->segment(1);
        $view = $this->CI->uri->segment(2);

        if($view) {
            $this->helpLink = "/reference/help/$object/$view";
        }
        else {
            $this->helpLink = "/reference/help/$object";
        }
		#$this->helpLink = "/reference/help/".$this->CI->uri->segment(1)."/".$this->CI->uri->segment(2);

        // Load your user information
		$this->user = $this->CI->impulselib->get_name();
		$this->priv = $this->CI->api->get->current_user_level();
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
	public function get_edit()          { return $this->edit; }
	public function get_active_page()	{ return $this->activePage; }
	public function get_context()		{ return $this->context; }
	public function get_delete()		{ return $this->delete; }
	public function get_user()			{ return $this->user; }
	public function get_priv()			{ return $this->priv; }
	public function get_cancel()        { return $this->cancel; }
	public function get_create_link()	{ return $this->createLink; }
	public function get_edit_link()		{ return $this->editLink; }
	public function get_delete_link()	{ return $this->deleteLink; }
	public function get_cancel_link()	{ return $this->cancelLink; }
	public function get_help_link()		{ return $this->helpLink; }
	public function get_create()		{ return $this->create; }

    ////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}

/* End of file navbar.php */
/* Location: ./application/libraries/core/navbar.php */
