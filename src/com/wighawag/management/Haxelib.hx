package com.wighawag.management;
import sys.io.Process;

class Haxelib 
{

	static public function install(libraryName : String, version : String) : Int
	{
		var process : Process = new Process("haxelib", ["run", "haxelib-runner", "install", libraryName, version ]);
		return process.exitCode();
	}
	
}