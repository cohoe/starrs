<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class ExceptionDemo extends CI_Controller {
	public function index() {
		// Let's try to run this code and hopefully we won't get an exception!
		try {
			$this->throwAnException();
			
			// If throwAnException threw an exception, we'll never get to this
			// code executed
			echo "<span style='text-align:center; font-size:40px'>";
			echo "Holy Shit! We didn't get an Exception!";
			echo "</span>";
			
		} catch(AmbiguousTargetException $e){
			// Here we run code if calling throwAnException threw an exception
			// You can use $e (or whatever variable) the access the exception.
			// You can also use $e as if it were a string.
			echo "<div style='padding:10px; background-color:grey; border:solid 1px black; position:relative; float:center; margin:auto;'>";
			echo $e;
			echo "</div>";
		} catch(APIException $e) {
			// The catching is totally procedural, so if an applicable catch
			// occurs before your target catch (eg: Exception before 
			// APIException, since all exceptions must inherit from Exception)
			// that catch will happen and the target will be skipped.
			echo "<div style='padding:10px; background-color:grey; border:solid 1px black; position:relative; float:center; margin:auto;'>";
			echo $e . "<br />";
			echo "Well... that kinda sucks.";
			echo "</div>";
		} catch(Exception $e) {
			// This catch will catch ANY exception, so it should always be last
			echo "<span style='text-align:center; font-size:200px'>";
			echo "EXCEPTION CAUGHT!";
			echo "</span>";
			echo "<span style='text-align:center;'>";
			echo "Caught exception of type: " . get_class($e) . "<br />";
			echo "Stack Trace: " . $e->getTraceAsString() . "</div>";
		}
		
		// This code gets executed regardless of whether an exception was caught or not
		echo "<hr />";
		echo "Ha! Ha! I'm on the Internet!";
		
	}
	
	/**
	 * Throws a random exception based on a totally random number.
	 */
	private function throwAnException() {
		$type = rand(0, 10) % 7;
		switch($type) {
			case 0:
				throw new AmbiguousTargetException("More than one object was discovered.");
				break;
			case 1:
				throw new APIException("OMG, the API broke!");
				break;
			case 2:
				throw new DBException("The database query failed with this error code: LOL");
				break;
			case 3:
				throw new ObjectNotFoundException("IMPULSE was inable to find the given object.");
				break;
			case 4:
				throw new OutOfBoundsException("This is a built-in PHP exception.");
				break;
			default:
				return;
				break;
		}
	}
}