package com.wighawag.management;
import com.wighawag.management.DependencySet;

class SourceDependency implements Dependency
{

	private var _path : String;
	private var _uniqueId : String;
	
	public function new(path : String, uniqueId : String) 
	{
		_uniqueId = uniqueId;
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

	public function grab(settings : YogaSettings, dependencySet:DependencySet):Void 
	{
		dependencySet.add(this);
	}
	
	public function getUniqueId():String 
	{
		return "SourceDependency_" + _uniqueId;
	}
	
}