package com.wighawag.management;
import com.wighawag.util.Show;

class HaxelibDependency implements Dependency
{

	public var name(default, null) : String;
	public var version(default, null) : String;
	
	public function new(name : String, ?version : String = null) 
	{
		this.name = name;
		this.version = version;
	}
	
	/* INTERFACE com.wighawag.management.Dependency */
	
	public function getHxmlString():String 
	{
		if (version == null)
		{
			return "-lib " + name;
		}
		return "-lib " + name + ":" + version;
	}
	
	public function getNMMLString():String 
	{
		if (version == null)
		{
			return '<haxelib name="'+ name +'" />';
		}
		return '<haxelib name="'+ name +'" version="' + version + '" />';
	}
	
	public function grab(settings : YogaSettings, dependencySet : DependencySet) : Void
	{
		var returnCode = Haxelib.install(name, version);
		if (returnCode > 1)
		{
			Show.criticalError("failed installing haxelib " + name + " version " + version );
		}
		dependencySet.add(this);
	}
	
	public function getUniqueId():String 
	{
		return "HaxelibDependency_" + name;
	}
	
}