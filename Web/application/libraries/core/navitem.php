<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Navitem {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $title;
	
	private $link;
	
	private $views;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($title, $link, $views) {
	
		$this->title = $title;
		$this->link = $link;
		
		foreach(array_keys($views) as $view) {
			$this->views[$view] = $views[$view];
		}
	}
	
	//////////////////////////////////////////////////////////////////////
	/// GETTERS
	
	public function get_title()          { return $this->title; }
	public function get_link()           { return $this->link; }
	public function get_views()          { return $this->views; }
	public function get_view_link($view) { return $this->views[$view]; }
		
	//////////////////////////////////////////////////////////////////////
	/// SETTERS
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
}
/* End of file navitem.php */
/* Location: ./application/libraries/core/navitem.php */