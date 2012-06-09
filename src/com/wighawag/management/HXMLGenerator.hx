package com.wighawag.management;
import massive.neko.io.File;

class HXMLGenerator 
{

	static public function generate(currentDirectory : File, targetDirectory : File, outputs : Array<Output>, dependencySet : DependencySet, extraParameters : Array<String>, ?mainClass : String ) : String 
	{
		var hxmlString = "";
		var counter = 0;
		for (output in outputs)
		{
			if (counter > 0)
			{
				hxmlString += "--next\n";
			}
			
			hxmlString += output.generateHxml(currentDirectory, targetDirectory, dependencySet, extraParameters, mainClass);
			
			counter ++;
		}
		return hxmlString;
			
	}
	
}