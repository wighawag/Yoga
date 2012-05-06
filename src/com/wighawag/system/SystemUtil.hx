package com.wighawag.system;

class SystemUtil 
{

	static public function slash() : String 
	{
		if (Sys.systemName().indexOf("Win") != -1)
		{
			return "\\";
		}
		return "/";
	}
	
}