package com.wighawag.management;
import sys.io.Process;
import com.wighawag.util.Show;

class Haxelib 
{

	static public function install(libraryName : String, version : String) : Int
	{
		var process : Process;
		if (version == null || version == "")
		{
			Show.message("installing " + libraryName);
			process = new Process("haxelib", ["run", "haxelib-runner", "install", libraryName]);
		}
		else
		{
			Show.message("installing " + libraryName + ":" + version);
			process = new Process("haxelib", ["run", "haxelib-runner", "install", libraryName, version ]);
		}
		
		
		return process.exitCode();
	}
	
}