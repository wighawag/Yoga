package com.wighawag.management;
import massive.neko.io.File;

class Target 
{
	public var name:String;
	public var output:String;

	public function new(name : String, output : String) 
	{
		this.name = name;
		this.output = output;
		
	}
	
	public function generateHxml(directory : File, targetDirectory : File, currentProject : YogaProject, dependencySet : DependencySet) : Void
	{
		if (output != null && output != '')
		{
			var outputFile : File = directory.resolveFile(output, true);
			var outputHandle = sys.io.File.write(outputFile.nativePath, false);
			outputHandle.writeString("-" + name + " " + targetDirectory.resolveFile(currentProject.shortName + "_" + currentProject.version + "." + name).nativePath + "\n");
			outputHandle.writeString("-main " + currentProject.mainClass + "\n");
			for (dependency in dependencySet.getDependencies())
			{
				outputHandle.writeString(dependency.getHxmlString() + "\n");
			}
			for (param in currentProject.compilerParameters)
			{
				outputHandle.writeString(param + "\n");
			}
			
			outputHandle.flush();
			outputHandle.close();
		}
	}
	
}