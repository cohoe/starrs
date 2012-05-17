<?php
class Server extends CI_Controller {
	public function index() {
		print_r($_SERVER);
	}
}
