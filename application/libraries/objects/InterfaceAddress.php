<?php

/**
 * This class contains the definition of an InterfaceAddress object. These
 * objects represent an address tied to the
 * specified address.
 */
class InterfaceAddress extends ImpulseObject {
	

	////////////////////////////////////////////////////////////////////////
	// ENUM-LIKE SILLYNESS
	
	// Enumeration values for address family
	public static $IPv4 = 4;
	public static $IPv6 = 6;
	
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string		The address bound to the interface 
	private $address;
	
	// string		The class of the address (all values are default so far)
	private $class;
	
	// string		A comment about the address
	private $comment;
	
	// string		The config type for the address
	// @todo: make a getValidConfigTypes method
	private $config;
	
	// enum(int)	The family the address belongs to (either IPv4 or v6). Can
	// be compared against using ::$IPv4 and ::$IPv6
	private $family;
	
	// string		The mac address that this address is bound to. Can be used
	// to lookup the matching InterfaceObject. 
	private $mac;
	
	// long			The unix timestamp that the interface will be renewed.
	private $renewDate;
	
	// bool			Is this address the primary for the interface
	private $isPrimary;
	
	////////////////////////////////////////////////////////////////////////
	// DNS RELATED VARIABLES
	
	// string				The FQDN that resolves to this address
	private $dnsFqdn;
	
	// AddressRecord		AddressRecord object of this address
	private $dnsAddressRecord;
	
	// array<PointerRecord>	All pointer (CNAME,SRV) records that resolve to this address
	private $dnsPointerRecords;
	
	// array<NsRecord>		All nameserver (NS) records that resolve to this address
	private $dnsNsRecords;
	
	// array<MxRecords>		All mail server (MX) records that resolve to this address
	private $dnsMxRecords;
	
	// array<TxtRecord>		All TXT or SPF records that describe this address
	private $dnsTxtRecords;
	
	////////////////////////////////////////////////////////////////////////
	// FIREWALL RELATED VARIABLES
	
	// bool					Firewall defauly action (t for deny, f for all)
	private $fwDefault;
	
	// array<FirewallRule>	All firewall rules that relate to this address
	private $fwRules;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * Construct a new InterfaceAddress object using the given information
	 * @param 	string 	$address		The address bound to the address 
	 * @param 	string 	$class			The class of the address
	 * @param 	string	$config			How the address is configured
	 * @param 	string 	$mac			The mac address the interface address 
	 * 									is bound to
	 * @param 	long	$renewDate		Unix timestamp when the address renews
	 * @param	bool	$isPrimary		Is this address the primary for the interface?
	 * @param 	string	$comment		A comment about the address
	 * @param	long	$dateCreated	Unix timestamp when the address was created
	 * @param	long	$dateModified	Unix timestamp when the address was modifed
	 * @param	string	$lastModifer	The last user to modify the address 
	 */
	public function __construct($address, $class, $config, $mac, $renewDate, $isPrimary, $comment, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// InterfaceAddress-specific stuff
		$this->address   = $address;
		$this->class     = $class;
		$this->config    = $config;
		$this->mac       = $mac;
		$this->renewDate = $renewDate;
		$this->comment   = $comment; 
		$this->isPrimary = $isPrimary;
		
		// Determine the family of the address based on whether there's a : or not
		$this->family  = (strpos($address, ':') === false) ? self::$IPv4 : self::$IPv6;
		
		// Initialize variables
		$this->dnsPointerRecords = array();
		$this->dnsNsRecords = array();
		$this->dnsMxRecords = array();
		$this->dnsTxtRecords = array();
		$this->fwRules = array();
		$this->dnsFqdn = $this->CI->api->dns->get_ip_fqdn($this->address);
		$this->fwDefault = $this->CI->api->firewall->get_firewall_default($this->address);
        $this->dnsAddressRecord = $this->CI->api->dns->get_address_record($this->address);
		
		// Loaders
		#$this->_load_pointer_records();
		#$this->_load_text_records();
		#$this->_load_mx_records();
		#$this->_load_ns_records();
		
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_address()         { return $this->address; }
	public function get_class()           { return $this->class; }
	public function get_config()          { return $this->config; }
	public function get_mac()             { return $this->mac; }
	public function get_renew_date()      { return $this->renewDate; }
	public function get_comment()         { return $this->comment; }
	public function get_family()          { return $this->family; }
	public function get_isprimary()       { return $this->isPrimary; }
	public function get_fqdn()            { return $this->dnsFqdn; }
	public function get_rules()           { return $this->fwRules; }
	public function get_fw_default()      { return $this->fwDefault; }
	public function get_address_record()  { return $this->dnsAddressRecord; }
	public function get_ns_records()      { return $this->dnsNsRecords; }
	public function get_mx_records()      { return $this->dnsMxRecords; }
	public function get_pointer_records() { return $this->dnsPointerRecords; }
	public function get_text_records()    { return $this->dnsTxtRecords; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	/**
	 * Adds a firewall rule to the address
	 * @param FirewallRule	$rule	The rule object to add
	 */
	public function add_firewall_rule($rule) {
		// If it's not a rule, blow up
		if(!$rule instanceof FirewallRule) {
			throw new APIException("Cannot add a non-rule as a rule");
		}
		
		// Add the rule to the local array
		$this->fwRules[] = $rule;
	}

    /**
     * Add a pointer record for this address
     * @param $pointerRecord    The record object to add
     */
    public function add_pointer_record($pointerRecord) {
		// If it's not a proper record, blow up
		if(!$pointerRecord instanceof PointerRecord) {
			throw new APIException("Cannot add a non-pointer-record as a pointer-record");
		}

		// Add the record to the local array
		$this->dnsPointerRecords[] = $pointerRecord;
	}

    /**
     * Add a TXT or SPF record for this address
     * @param $txtRecord    The record object to add
     */
    public function add_txt_record($txtRecord) {
		// If it's not a proper record, blow up
		if(!$txtRecord instanceof TxtRecord) {
			throw new APIException("Cannot add a non-txt-record as a txt-record");
		}

		// Add the record to the local array
		$this->dnsTxtRecords[] = $txtRecord;
	}

    /**
     * Add a NS record for this address
     * @param $nsRecord     The record object to add
     */
    public function add_ns_record($nsRecord) {
		// If it's not a proper record, blow up
		if(!$nsRecord instanceof NsRecord) {
			throw new APIException("Cannot add a non-ns-record as a ns-record");
		}

		// Add the record to the local array
		$this->dnsNsRecords[] = $nsRecord;
	}

    /**
     * Add a MX record for this address
     * @param $mxRecord     The record object to add
     */
    public function add_mx_record($mxRecord) {
		// If it's not a proper record, blow up
		if(!$mxRecord instanceof MxRecord) {
			throw new APIException("Cannot add a non-mx-record as a mx-record");
		}

		// Add the record to the local array
		$this->dnsMxRecords[] = $mxRecord;
	}


}