package com.wighawag.management;

class Target 
{
	public var name : String;
	public var extraParameters : Array<String>;
	
	public function new(name : String, ?extraParameters : Array<String>) 
	{
		this.name = name;
		this.extraParameters = extraParameters;
	}
	
	public function getHxmlLines(outputPath:String)  : String
	{
		var result = "";
		
		result += "-" + name + " " +  outputPath + "\n";
		if (extraParameters != null)
		{
			for (parameterLine in extraParameters)
			{
				result += parameterLine + "\n";
			}
		}
		
		return result;
	}
	
	public function getExtension() : String
	{
		switch(name)
		{
			case "swf" : return ".swf";
			case "js" : return ".js";
			case "neko" : return ".n";
			case "cpp" : return "_cpp";
		}
		return "." + name;
	}
	
}