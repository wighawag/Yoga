package com.wighawag.management;
import com.wighawag.management.DependencySet;

class SourceDependency implements Dependency
{

	public var path : String;
	private var _uniqueId : String;
	
	public function new(path : String, uniqueId : String) 
	{
		_uniqueId = uniqueId;
		this.path = path;
	}
	
	/* INTERFACE com.wighawag.management.Dependency */
	
	public function getHxmlString():String 
	{
		return "-cp "  + path;
	}
	
	public function getNMMLString():String 
	{
		return '<source path="' + path +'" />';
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