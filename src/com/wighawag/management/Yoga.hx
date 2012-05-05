package com.wighawag.management;

import haxe.io.Path;
import sys.io.FileInput;
import sys.FileSystem;
import sys.io.File;

class Yoga {
	
	static private var fileName : String = "yoga.xml";
	static private var directoryName : String = "yoga" ;
	static private var settingsFileName : String = "settings.xml";
	static private var localRepoFolder : String = "repository";
	static private var localRepoPath : String;
	static private var localTmpFolder : String = "tmp";
	static private var localTmpPath : String;
	static private var warnings : Array<String>;
	static private var currentDirectory : String;
	static private var targetDirectory : String = "target";
	static private var slash : String;
	static private var prefix : String;
	
	static private var repoList : Array<String>;
	
    static public function main() : Void {
		warnings = new Array<String>();
		var args : Array<String> = Sys.args();
		repoList = new Array<String>();
		
		currentDirectory = getCurrentDirectoryFromLastArgument(args);
		
		slash = "/";
		prefix = ".";
		if (Sys.systemName().indexOf("Win") != -1)
		{
			slash = "\\";
		}
		
		execute(args);
    }
	
	
	static private function execute(args : Array<String>) : Void
	{
		
		var settingsFolderPath : String = "";
		if (Sys.environment().exists("HOME")) {
			settingsFolderPath = new Path(Sys.getEnv("HOME") + slash + prefix + directoryName).toString();
		}else if (Sys.environment().exists("USERPROFILE")) {
			settingsFolderPath = new Path(Sys.getEnv("USERPROFILE") + slash + prefix + directoryName ).toString();
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
		
		var settingsFilePath : String = settingsFolderPath + slash + settingsFileName;
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
					repoList.push(repository.get("url"));
				}
			}
		}
		else
		{
			Sys.println("no config provided");
		}
		
		localRepoPath = settingsFolderPath + slash + localRepoFolder;
		if (!FileSystem.exists(localRepoPath))
		{
			Sys.println("creating directory : " + localRepoPath + " ...");
			FileSystem.createDirectory(localRepoPath);
		}
		
		localTmpPath = settingsFolderPath + slash + localTmpFolder;
		if (!FileSystem.exists(localTmpPath))
		{
			Sys.println("creating directory : " + localTmpPath + " ...");
			FileSystem.createDirectory(localTmpPath);
		}
		
		
		fileName = currentDirectory + fileName;
		
        // get access to the project xml
        if (!FileSystem.exists(fileName)){
            Sys.println("no "+ fileName + " found");
            Sys.exit(1);
        }
		
		var content = File.getContent(fileName);
		
		var xml = Xml.parse(content);
		
		var project = xml.elementsNamed("project").next();
		
		if (project == null)
		{
			Sys.println("no project element found");
			Sys.exit(1);
		}
		
		var yogaVersionTag = project.elementsNamed("yoga-version").next();
		if (yogaVersionTag == null)
		{
			Sys.println("no yoga-version element found");
			Sys.exit(1);
		}
		var version : String = yogaVersionTag.firstChild().toString();
		
		Sys.println("******* This project use yoga version " + version + " *********");
		
		
		var dependencies = join(project);
		
		generateConfig(project, dependencies);
		
		showWarningsAndErrors();
	}
	
	static private function generateConfig(project : Xml, dependencies : Array<Dependency>) 
	{
		var sourcesTag : Xml = project.elementsNamed("source").next();
		if (sourcesTag == null)
		{
			Sys.println("source folder not specified");
			Sys.exit(1);
		}
		var sourcesFolder : String = sourcesTag.firstChild().toString();
		Sys.println("source : " + sourcesFolder);
		dependencies.push(new SourceDependency(sourcesFolder));
		
		var mainTag : Xml = project.elementsNamed("main").next();
		if (mainTag == null)
		{
			Sys.println("main class not specified");
			Sys.exit(1);
		}
		var mainClass : String = mainTag.firstChild().toString();
		Sys.println("main class : " + mainClass);
		
		
		var idTag : Xml = project.elementsNamed("id").next();
		if (idTag == null)
		{
			Sys.println("id not specified");
			Sys.exit(1);
		}
		var id : String = idTag.firstChild().toString();
		var shortName : String = id.substr(id.lastIndexOf(".") + 1);
		
		
		var versionTag : Xml = project.elementsNamed("version").next();
		if (versionTag == null)
		{
			Sys.println("project version not specified");
			Sys.exit(1);
		}
		var projectVersion : String = versionTag.firstChild().toString();
		
		if (!FileSystem.exists(currentDirectory + slash + targetDirectory))
		{
			FileSystem.createDirectory(currentDirectory + slash + targetDirectory);
		}
		
		for (targetTag in project.elementsNamed("target"))
		{
			var targetName = targetTag.get("name");
			var targetTemplate = targetTag.get("template");
			var targetOutput = targetTag.get("output");
			
			Sys.println("target : " + targetName + " (" + targetTemplate + " -> " + targetOutput + ")");
			var inputFile = File.read(currentDirectory + targetTemplate, false);
			var outputFile = File.write(currentDirectory + targetOutput, false);
			
			if (targetName == "nme")
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
				for (dependency in dependencies)
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
				outputFile.writeString("-" + targetName + " " + targetDirectory + slash + shortName + "_" + projectVersion + "." + targetName + "\n");
				outputFile.writeString("-main " + mainClass + "\n");
				for (dependency in dependencies)
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
	
	static private function join(project : Xml) : Array<Dependency>
	{
		Sys.println("dealing with dependencies ...");
		
		var array : Array<Dependency> = new Array<Dependency>();
		var dependenciesTag = project.elementsNamed("dependencies").next();
		if (dependenciesTag == null)
		{
			Sys.println("no dependencies");
			return array;
		}
		var dependencies = dependenciesTag.elements();
		
		for (dependency in dependencies)
		{
			switch(dependency.nodeName)
			{		
				case "haxelib" : 
					var libraryName : String = dependency.get("name");
					var version : String = dependency.get("version");
					
					var returnCode = Haxelib.install(libraryName, version);
					if (returnCode > 1)
					{
						Sys.println("error in installing haxelib " + libraryName + " version " + version );
						Sys.exit(1);
					}
					
					array.push(new HaxelibDependency(libraryName, version));
					
					
				case "repository" :
					var repoProjectId : String = dependency.get("id");
					var repoProjectVersion : String = dependency.get("version");
					
					// check if exist locally
					
					
					//if not get it from the repo
					var tmpZipPath = getZipFromAnyRepositories(repoProjectId, repoProjectVersion);
					if (tmpZipPath == null)
					{
						Sys.println("cannot find " + repoProjectId + ":" + repoProjectVersion);
						Sys.exit(1);
					}
						
					Sys.println("zip downloaded :  " + tmpZipPath);
					
					
					//then unzip (+get dependencies if specified (recusrive))
					
				case "zip" :
					var zipUrl : String = dependency.get("url");
					Sys.println("repo project from a zip file (Not suppoted yet)");
					// check if exist locally
					
					//if not: download zip and unzip it
					
					// then get the depedencies is specified (recusrive)
				case "sourcezip" :
					var sourceZipUrl : String = dependency.get("url");
					var sourcePath : String = dependency.get("srcpath");
					Sys.println("source from a zip file (Not suppoted yet)");
					// check if exist locally
					
					//if not: download zip and unzip it
					
					// then get the depedencies is specified (recusrive)
			}
		}
		return array;
	}
	
	static private function getZipFromAnyRepositories(repoProjectId : String, repoProjectVersion : String) : String
	{
		
		var repoQueue : Array<String> = repoList.copy();
		var zipPath :String = null;
		do
		{
			if (repoQueue.length > 0)
			{
				var repoUrl : String = repoQueue.shift();
				zipPath = getZip(repoUrl + "/" + repoProjectId + "_" + repoProjectVersion + ".zip");
			}
		}while (repoQueue.length > 0 && zipPath == null);
		
		return zipPath;
	}
	
	static private function getZip(remoteZip : String) : String
	{
		var zipFileName : String = remoteZip.substr(remoteZip.lastIndexOf("/") + 1);
		var tmpZip = localTmpPath + slash + zipFileName;
		var tmpOut = sys.io.File.write(tmpZip,true);
		
		var h = new haxe.Http(remoteZip);
		var errorHapenned : Bool = false;
		h.onError = function(e) {
			errorHapenned = true;
		};
		Sys.println("Downloading "+remoteZip+"...");
		h.customRequest(false, tmpOut);
		if (errorHapenned)
		{
			return null;
		}
		return tmpZip;
	}
}
