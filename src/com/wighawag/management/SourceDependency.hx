package com.wighawag.management;

class SourceDependency implements Dependency
{

	private var _path : String;
	
	public function new(path : String) 
	{
		_path = path;
	}
	
	/* INTERFACE com.wighawag.management.Dependency */
	
	public function getHxmlString():String 
	{
		return "-cp "  + _path;
	}
	
	public function getNMMLString():String 
	{
		return '<source path="' + _path +'" />';
	}
	
}