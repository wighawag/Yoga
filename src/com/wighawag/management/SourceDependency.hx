package com.wighawag.management;
import com.wighawag.management.DependencySet;

class SourceDependency implements Dependency
{

	public var path : String;
	private var _uniqueId : String;
	public var projectId : String;
	public var projectVersion : String;
	
	public function new(path : String, uniqueId : String, ?projectId : String = null, ?projectVersion : String = null)
	{
		this.projectId = projectId;
		this.projectVersion = projectVersion;
		_uniqueId = uniqueId;
		if (path.charAt(path.length - 1) == "\\")
		{
			path = path.substr(0, path.length -1);
		}
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

	public function grab(settings : YogaSettings, dependencySet:DependencySet, step : Int):Void
	{
		dependencySet.add(this);
	}
	
	public function getUniqueId():String 
	{
		return "SourceDependency_" + _uniqueId;
	}

	public function descriptionId():String {
		if(projectId == null){
			return getUniqueId();
		}else{
			return "project " + projectId + "_" + projectVersion;
		}

	}
}