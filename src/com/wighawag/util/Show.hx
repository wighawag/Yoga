package com.wighawag.util;

class Show {
	
	public static function criticalError(msg : String) {
		Sys.println("-- ERROR: " + msg);
		Sys.exit(1);
	}		
	
	public static function message(msg : String){
		Sys.println(msg);
	}

    public static function success(?msg : String = null){
        if(msg == null){
            msg = "";
        }else{
            msg = " : " + msg;
        }
        Sys.println("-- SUCCESS" + msg);
    }

    public static function done(?msg : String = null){
        if(msg == null){
            msg = "";
        }else{
            msg = " : " + msg;
        }
        Sys.println("-- DONE" + msg);
    }
	

}
