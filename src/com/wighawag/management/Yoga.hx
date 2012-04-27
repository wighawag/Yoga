package com.wighawag.management;

import haxe.io.Path;
import sys.io.FileInput;
import sys.FileSystem;
import sys.io.File;

class Yoga {
	
    public static function main() : Void {
		var args : Array<String> = Sys.args();
		
		
		// GET THE LATEST VERSION :
		var newInstall : Bool = Sys.command("haxelib", ["run", "haxelib-runner", "install", "yoga"]) == 0;
		
		// SET IT AS THE CURRENT ONE
		// TODO in haxelib-runner (when no version supplied set the latest version) and return 1 if already set
		var newSet : Bool = Sys.command("haxelib", ["run", "haxelib-runner", "set", "yoga"]) == 0;
		
		
		// if it was not the current one, run yoga again 
		if (newInstall || newSet)
		{
			runANewYogaInstance(args);
		}
		// else execute yoga logic:
		else
		{
			execute(args);
		}
		
    }
	
	private static function runANewYogaInstance(args) : Void
	{
		var fullArgs = ["run", "yoga"];
		fullArgs = fullArgs.concat(args);
		fullArgs.pop();// get rid of the added path when running haxelib run
		Sys.command("haxelib", fullArgs);
		Sys.exit(0);
	}
	
	
	// VERSION SPECIFIC 
	private static var fileName : String = "yoga.xml";
	private static function execute(args : Array<String>) : Void
	{
		fileName = getCurrentDirectoryFromLastArgument(args) + fileName;
		
        // get access to the config xml
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
		
		ensureCorrectVersion(version,args);
		
		join(project);
	}
	
	
	static private function ensureCorrectVersion(version : String, args) 
	{	
		var haxelibFileName : String = "haxelib.xml";
		
		if (!FileSystem.exists(haxelibFileName)){
            Sys.println("no "+ haxelibFileName + " found in the current (haxelib yoga) directory");
            Sys.exit(1);
        }
		
		var content = File.getContent(haxelibFileName);
		
		var xml = Xml.parse(content);
		
		var project = xml.elementsNamed("project").next();
		
		var versionTag = project.elementsNamed("version").next();
		var yogaCurrentVersion = versionTag.get("name");
		
		// if the version required by the project is the current on continue processing
		if (version != yogaCurrentVersion)
		{
			var returnCode : Int;
			returnCode = Sys.command("haxelib", ["run", "haxelib-runner", "install", "yoga", version]);
			if (returnCode > 1)
			{
				Sys.println("error in installing yoga version " + version);
				Sys.exit(1);
			}
			returnCode = Sys.command("haxelib", ["run", "haxelib-runner", "set", "yoga", version]);
			if (returnCode > 1)
			{
				Sys.println("error in setting yoga version " + version);
				Sys.exit(1);
			}
			
			runANewYogaInstance(args);
			Sys.exit(0);
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
	
	static private function join(project : Xml) : Void//Array<Dependency>
	{
		var dependenciesTag = project.elementsNamed("dependencies").next();
		if (dependenciesTag == null)
		{
			Sys.println("no dependencies");
			return;
		}
		var dependencies = dependenciesTag.elements();
		
		for (dependency in dependencies)
		{
			switch(dependency.nodeName)
			{		
				case "haxelib" : 
					var libraryName : String = dependency.get("name");
					var version : String = dependency.get("version");
					var returnCode = Sys.command("haxelib", ["run", "haxelib-runner", "install", libraryName, version ]);
					if (returnCode > 1)
					{
						Sys.println("error in installing " + libraryName + "(" + version + ")");
					}
				case "repository" :
					Sys.println("from repository (Not suppoted yet)");
					// check if exist locally
					
					//if not get it from the repo
					
					//then unzip (+get dependencies if specified (recusrive))
					
				case "git" :
					Sys.println("from git (Not suppoted yet)");
					// check if exist locally
					
					//if not: use git to get the tag specified and pu in local repo
					
					// then get the depedencies is specified (recusrive)
				case "svn" :
					Sys.println("from svn (Not suppoted yet)");
					// check if exist locally
					
					//if not: use svn to get the tag specified and pu in local repo
					
					// then get the depedencies is specified (recusrive)
				case "zip" :
					Sys.println("from a zip file (Not suppoted yet)");
					// check if exist locally
					
					//if not: download zip and unzip it
					
					// then get the depedencies is specified (recusrive)
			}
		}
	}
}
