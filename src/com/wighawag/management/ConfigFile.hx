package com.wighawag.management;
import haxe.Template;
import massive.neko.io.File;
import com.wighawag.util.Show;

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
		
		Show.message("     config file : (" + templateFileName + " -> " + outputFileName + ")");
		var templateFile = directory.resolvePath(templateFileName);
		if (!templateFile.exists)
		{
			Show.criticalError("template file " + templateFile.nativePath +" does not exists");
		}

        if (templateFile.isDirectory){
        	var outputDirectory = directory.resolveDirectory(outputFileName);
            //Show.message("Directory template not supported yet");
            var files = templateFile.getRecursiveDirectoryListing();
            for (file in files)
            {
            	var relativePath = templateFile.getRelativePath(file);
            	if (file.isFile)
            	{	
            		var outputFile = outputDirectory.resolveFile(relativePath,true);
            		var template : Template = new Template(file.readString());
	    			outputFile.writeString(template.execute(new YogaProjectForTemplate(directory, currentProject, dependencySet, yogaSettings)));
            	}
            	else
            	{
            		var outputSubDirectory = outputDirectory.resolveDirectory(relativePath,true);
            	}
            }

        }else{
		    var outputFile = directory.resolveFile(outputFileName, true);
		    var template : Template = new Template(templateFile.readString());
	    	outputFile.writeString(template.execute(new YogaProjectForTemplate(directory, currentProject, dependencySet, yogaSettings)));
        }
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
	public var projectSourceDirectories : Array<String>;
	public var sourceFiles : Array<String>;
	public var hxmlPrefix : String;
	
	
	public function new(currentDir : File, yogaProject : YogaProject, dependencySet : DependencySet, yogaSettings : YogaSettings)
	{
		sourceFiles = new Array<String>();
		projectSourceDirectories = new Array<String>();
		targetDirectory = yogaSettings.targetDirectory;
		shortName = yogaProject.shortName;
		id = yogaProject.id;
		version = yogaProject.version;
		mainClass = yogaProject.mainClass;
        if (mainClass == null)
        {
            mainClass = ""; // TODO check whether template if statement support null. if that is the case better use null
        }
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
				var sourceDependency = cast(dependency, SourceDependency);
				
				var isProjectSource : Bool = false;
				for (sourcePath in yogaProject.sources)
				{
					if (sourceDependency.path == sourcePath)
					{
						isProjectSource = true;
						break;
					}
				}
				
				if (isProjectSource)
				{
					projectSourceDirectories.push(sourceDependency.path);
				}
				else
				{
					sourceDependencies.push(sourceDependency);
				}
			}
		}
		
		for (projectSourcePath in yogaProject.sources)
		{
			var sourceDir = currentDir.resolveDirectory(projectSourcePath);
			var files = sourceDir.getRecursiveDirectoryListing(new EReg("(^|/)\\.(.*)", ""), true);
			for (file in files)
			{
				if (!file.isDirectory)
				{
					sourceFiles.push(currentDir.getRelativePath(file));
				}
			}
		}
		
		hxmlPrefix = yogaProject.outputPrefix;
	}
}
