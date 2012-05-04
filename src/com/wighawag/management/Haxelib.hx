package com.wighawag.management;


class Haxelib 
{

	static public function install(libraryName : String, version : String) : Int
	{
		return Sys.command("haxelib", ["run", "haxelib-runner", "install", libraryName, version ]);
	}
	
}