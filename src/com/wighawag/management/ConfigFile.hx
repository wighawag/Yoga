package com.wighawag.management;
import haxe.Template;
import massive.neko.io.File;

class ConfigFile 
{
	public var templateFileName : String;
	public var outputFileName : String;
	
	public function new(templateFileName : String, outputFileName : String) 
	{
		this.templateFileName = templateFileName;
		this.outputFileName = outputFileName;
	}
	
	public function generate(directory : File, currentProject : YogaProject, dependencySet : DependencySet, yogaSettings : YogaSettings) : Void
	{
		
		Sys.println("config gile : (" + templateFileName + " -> " + outputFileName + ")");
		var templateFile = directory.resolveFile(templateFileName);
		if (!templateFile.exists)
		{
			Sys.println("template file " + templateFile.nativePath +" does not exists");
			Sys.exit(1);
		}
		
		var template : Template = new Template(templateFile.readString());
		
		var outputFile = directory.resolveFile(outputFileName, true);
		outputFile.writeString(template.execute(new YogaProjectForTemplate(currentProject, dependencySet, yogaSettings)));
	}
	
}

class YogaProjectForTemplate
{
	public var shortName : String;
	public var id : String;
	public var version : String;
	public var mainClass : String;
	public var mainPackage : String;
	public var haxelibDependencies : Array<HaxelibDependency>;
	public var sourceDependencies : Array<SourceDependency>;
	public var extraCompilerParameters : Array<String>;
	public var targetDirectory : String;
	
	
	
	public function new(yogaProject : YogaProject, dependencySet : DependencySet, yogaSettings : YogaSettings)
	{
		targetDirectory = yogaSettings.targetDirectory;
		shortName = yogaProject.shortName;
		id = yogaProject.id;
		version = yogaProject.version;
		mainClass = yogaProject.mainClass;
		var dotIndex = mainClass.lastIndexOf('.');
		if (dotIndex > -1)
		{
			mainPackage = mainClass.substr(0, dotIndex);
		}
		else
		{
			mainPackage = "";
		}
		haxelibDependencies = new Array<HaxelibDependency>();
		sourceDependencies = new Array<SourceDependency>();
		for (dependency in dependencySet.getDependencies())
		{
			if (Type.getClass(dependency) == HaxelibDependency)
			{
				haxelibDependencies.push(cast(dependency, HaxelibDependency));
			}
			else if (Type.getClass(dependency) == SourceDependency)
			{
				sourceDependencies.push(cast(dependency, SourceDependency));
			}
		}
		
	}
}
