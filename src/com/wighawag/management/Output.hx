package com.wighawag.management;
import massive.neko.io.File;

class Output 
{
	public var outputFileName : String;
	public var target : Target;

	public function new(outputFileName : String, target : Target) 
	{
		this.outputFileName = outputFileName;
		this.target = target;
	}
	
	public function generateHxml(targetDirectory : File, dependencySet : DependencySet, extraParameters : Array<String>, mainClass : String) : String
	{		
		var result : String = "";
		
		var outputFile : File = targetDirectory.resolveFile(outputFileName, true);

		result += target.getHxmlLines(outputFile.nativePath);

		
		if (mainClass != null && mainClass != "")
		{
			result+= "-main " + mainClass + "\n";
		}
		else
		{
			// TODO deal with adding included classes (macro?)
		}
		
		var dependencies = dependencySet.getDependencies();
		for (dependency in dependencies)
		{
			result += dependency.getHxmlString() + "\n";
		}
		
		for (param in extraParameters)
		{
			result += param + "\n";
		}
		return result;
	}

	
}