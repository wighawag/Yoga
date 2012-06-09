package com.wighawag.util;

class Show {
	
	public static function criticalError(msg : String) {
		Sys.println("ERROR: " + msg);
		Sys.exit(1);
	}		
	
	public static function message(msg : String){
		Sys.println(msg);
	}
	

}
