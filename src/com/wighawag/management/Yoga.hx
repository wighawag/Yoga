package com.wighawag.management;

import com.wighawag.file.FileUtil;
import com.wighawag.format.zip.ZipExtractor;
import com.wighawag.management.YogaSettings;
import com.wighawag.system.SystemUtil;
import haxe.io.Path;
import neko.zip.Reader;
import sys.io.FileInput;
import sys.FileSystem;
import sys.io.File;

class Yoga {
	
	static private var fileName : String = "yoga.xml";
	static private var directoryName : String = ".yoga" ;
	static private var settingsFileName : String = "settings.xml";
	static private var localRepoFolder : String = "repository";
	static private var localTmpFolder : String = "tmp";
	static private var warnings : Array<String>;
	static private var currentDirectory : String;
	static private var targetDirectory : String = "target";
	
	static private var yogaSettings:YogaSettings;
	
	static private var targetPath : String;
	
    static public function main() : Void {
		warnings = new Array<String>();
		var args : Array<String> = Sys.args();
		
		currentDirectory = getCurrentDirectoryFromLastArgument(args);
		
		targetPath = currentDirectory + SystemUtil.slash() + targetDirectory;
		if (FileSystem.exists(targetPath))
		{
			FileUtil.unlink(targetPath);
		}
		
		execute(args);
    }
	
	
	static private function execute(args : Array<String>) : Void
	{
		
		var settingsFolderPath : String = "";
		if (Sys.environment().exists("HOME")) {
			settingsFolderPath = new Path(Sys.getEnv("HOME") + SystemUtil.slash() + directoryName).toString();
		}else if (Sys.environment().exists("USERPROFILE")) {
			settingsFolderPath = new Path(Sys.getEnv("USERPROFILE") + SystemUtil.slash() + directoryName ).toString();
		}
		else if (Sys.environment().exists("YOGA_FOLDER"))
		{
			settingsFolderPath = Sys.getEnv("YOGA_FOLDER");
		}
		else
		{
			Sys.println("no Environment variable defined for finding the yoga folder, please set YOGA_FOLDER to the path you want yoga to store its local repo and settings");
			Sys.exit(1);
		}
		
		Sys.println("local yoga folder " + settingsFolderPath);
		
		if (FileSystem.exists(settingsFolderPath))
		{
			if (!FileSystem.isDirectory(settingsFolderPath))
			{
				Sys.println("local yoga folder exist but it is not a directory");
				Sys.exit(1);
			}
		}	
		else
		{
			Sys.println("creating folder " + settingsFolderPath + " ...");
			try
			{
				FileSystem.createDirectory(settingsFolderPath);
			} catch (e : Dynamic)
			{
				Sys.println("error while creating the directory " + e + " , you might need to create manuually at " + settingsFolderPath);
				Sys.exit(1);
			}
		}
		
		yogaSettings = new YogaSettings();
		
		var settingsFilePath : String = settingsFolderPath + SystemUtil.slash() + settingsFileName;
		if (FileSystem.exists(settingsFilePath))
		{
			var settingsXml : Xml = Xml.parse(File.read(settingsFilePath, false).readAll().toString());
			var settingsTag : Xml = settingsXml.elementsNamed("settings").next();
			if (settingsTag == null)
			{
				Sys.println("no valid settings");
				Sys.exit(1);
			}
			var repositoriesTag : Xml = settingsTag.elementsNamed("repositories").next();
			if (repositoriesTag != null)
			{
				for (repository in repositoriesTag.elementsNamed("repository"))
				{
					Sys.println("add repo " + repository.get("url"));
					yogaSettings.repoList.push(repository.get("url"));
				}
			}
		}
		else
		{
			Sys.println("no config provided");
		}
		
		
		yogaSettings.localRepoPath = settingsFolderPath + SystemUtil.slash() + localRepoFolder;
		if (!FileSystem.exists(yogaSettings.localRepoPath))
		{
			Sys.println("creating directory : " + yogaSettings.localRepoPath + " ...");
			FileSystem.createDirectory(yogaSettings.localRepoPath);
		}
		
		yogaSettings.localTmpPath = settingsFolderPath + SystemUtil.slash() + localTmpFolder;
		if (!FileSystem.exists(yogaSettings.localTmpPath))
		{
			Sys.println("creating directory : " + yogaSettings.localTmpPath + " ...");
			FileSystem.createDirectory(yogaSettings.localTmpPath);
		}
		
		
		var currentProjectFilePath = currentDirectory + fileName;
		
        // get access to the project xml
        if (!FileSystem.exists(currentProjectFilePath)){
            Sys.println("no "+ fileName + " found");
            Sys.exit(1);
        }
		
		var content = File.getContent(currentProjectFilePath);
		
		var currentProject : YogaProject = YogaProject.parse(content);
		
		
		Sys.println("******* This project use yoga version " + currentProject.yogaVersion + " *********");
		
		
		var dependencySet : DependencySet = new DependencySet();
		currentProject.join(yogaSettings, dependencySet);
		
		generateConfig(currentProject, dependencySet);
		
		showWarningsAndErrors();
	}
	
	static private function generateConfig(yogaProject : YogaProject, dependencySet : DependencySet) : Void
	{
		FileSystem.createDirectory(targetPath);
		
		for (target in yogaProject.targets)
		{
			Sys.println("target : " + target.name + " (" + target.template + " -> " + target.output + ")");
			var inputFile = File.read(currentDirectory + target.template, false);
			var outputFile = File.write(currentDirectory + target.output, false);
			
			if (target.name == "nme")
			{
				var nmml : Xml = Xml.parse(inputFile.readAll().toString());
				var nmmlProjectTag : Xml = nmml.elementsNamed("project").next();
				if (nmmlProjectTag == null)
				{
					Sys.println("not a valid nmml template, missing project element");
					Sys.exit(1);
				}
				
				for (nmmlSource in nmmlProjectTag.elementsNamed("source"))
				{
					nmmlProjectTag.removeChild(nmmlSource);
				}
				
				for (nmmlHaxelib in nmmlProjectTag.elementsNamed("haxelib"))
				{
					nmmlProjectTag.removeChild(nmmlHaxelib);
				}
				
				var nmeDependency : Bool = false;
				for (dependency in dependencySet.getDependencies())
				{
					if (Type.getClass(dependency) == HaxelibDependency)
					{
						if (cast(dependency, HaxelibDependency).name == "nme")
						{
							nmeDependency = true;
						}
					}
					nmmlProjectTag.addChild(Xml.parse(dependency.getNMMLString()));
				}
				if (!nmeDependency)
				{
					nmmlProjectTag.addChild(Xml.parse(new HaxelibDependency("nme").getNMMLString()));
				}
				
				outputFile.writeString(nmml.toString());
				
				outputFile.close();
				
			}
			else
			{
				outputFile.writeString(inputFile.readAll().toString());
				outputFile.writeString("-" + target.name + " " + targetDirectory + SystemUtil.slash() + yogaProject.shortName + "_" + yogaProject.version + "." + target.name + "\n");
				outputFile.writeString("-main " + yogaProject.mainClass + "\n");
				for (dependency in dependencySet.getDependencies())
				{
					outputFile.writeString(dependency.getHxmlString() + "\n");
				}
				outputFile.close();
			}
		}
	}
	
	static private function showWarningsAndErrors() : Void 
	{
		if (warnings.length > 0)
		{
			Sys.println("Warnings : ");
			for (warning in warnings)
			{
				Sys.println(warning);
			}
		}
	}
	
	
	static private function getCurrentDirectoryFromLastArgument(args:Array<String>) : String
	{
		if (args.length > 0){
			var last:String = (new Path(args[args.length-1])).toString();
			
			var slash = last.substr(-1);
			if (slash=="/"|| slash=="\\"){
				last = last.substr(0, last.length - 1);
			}
			
			
			if (FileSystem.exists(last) && FileSystem.isDirectory(last)) {
				return last + slash;
			}
		}
		return "";		
	}
	
}
