<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * DHCP configuration type
 */
class ConfigType extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

    // string   The configuration type
	private $config;

    // string   A comment on the type
	private $comment;

    // int      The family of the config type (4, 6, 0 for both)
	private $family;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    /**
     * @param   string  $config         The configuration type
     * @param   string  $comment        A comment on the type
     * @param   integer $family         The family of the config type
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modified
	 * @param   string	$lastModifier	The last user to modify the record
     */
    public function __construct($config, $comment, $family, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->config = $config;
		$this->comment = $comment;
		$this->family = $family;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_config()	{ return $this->config; }
	public function get_comment()	{ return $this->comment; }
	public function get_family()	{ return $this->family; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file ConfigType.php */
/* Location: ./application/libraries/objects/ConfigType.php */