package com.wighawag.management;



class YogaProject 
{
	public var sourceFolder : String;
	public var mainClass : String;
	public var targets : Array<Target>;
	public var dependencies:Array<Dependency>;
	public var yogaVersion : String;
	
	public var id : String;
	public var version : String;
	
	public var shortName(getShortName, null) : String;
	function getShortName() : String
	{
		return id.substr(id.lastIndexOf(".") + 1);
	}

	static public function parse(content : String) : YogaProject
	{
		var yogaProject : YogaProject = new YogaProject();
		
		var xml = Xml.parse(content);
		
		var projectTag = xml.elementsNamed("project").next();
		
		if (projectTag == null)
		{
			Sys.println("no project element found");
			Sys.exit(1);
		}
		
		var yogaVersionTag = projectTag.elementsNamed("yoga-version").next();
		if (yogaVersionTag == null)
		{
			Sys.println("no yoga-version element found");
			Sys.exit(1);
		}
		yogaProject.yogaVersion = yogaVersionTag.firstChild().toString();
		
		
		var sourcesTag : Xml = projectTag.elementsNamed("source").next();
		if (sourcesTag == null)
		{
			Sys.println("source folder not specified");
			Sys.exit(1);
		}
		yogaProject.sourceFolder = sourcesTag.firstChild().toString();
		Sys.println("source : " + yogaProject.sourceFolder);
		yogaProject.dependencies.push(new SourceDependency(yogaProject.sourceFolder,yogaProject.sourceFolder));
		
		var mainTag : Xml = projectTag.elementsNamed("main").next();
		if (mainTag == null)
		{
			Sys.println("main class not specified");
			Sys.exit(1);
		}
		yogaProject.mainClass = mainTag.firstChild().toString();
		Sys.println("main class : " + yogaProject.mainClass);
		
		
		var idTag : Xml = projectTag.elementsNamed("id").next();
		if (idTag == null)
		{
			Sys.println("id not specified");
			Sys.exit(1);
		}
		yogaProject.id = idTag.firstChild().toString();
		
		
		var versionTag : Xml = projectTag.elementsNamed("version").next();
		if (versionTag == null)
		{
			Sys.println("project version not specified");
			Sys.exit(1);
		}
		yogaProject.version = versionTag.firstChild().toString();
		
		for (targetTag in projectTag.elementsNamed("target"))
		{
			var targetName = targetTag.get("name");
			var targetTemplate = targetTag.get("template");
			var targetOutput = targetTag.get("output");
			
			var target : Target = new Target(targetName, targetTemplate, targetOutput);
			yogaProject.targets.push(target);
		}
		
		var dependenciesTag = projectTag.elementsNamed("dependencies").next();
		if (dependenciesTag != null)
		{
			
			var dependencieTags = dependenciesTag.elements();
			
			for (dependency in dependencieTags)
			{
				switch(dependency.nodeName)
				{		
					case "haxelib" : 
						var libraryName : String = dependency.get("name");
						var version : String = dependency.get("version");
						
						yogaProject.dependencies.push(new HaxelibDependency(libraryName, version));
						
						
					case "repository" :
						var repoProjectId : String = dependency.get("id");
						var repoProjectVersion : String = dependency.get("version");
						
						yogaProject.dependencies.push(new RepositoryDependency(repoProjectId, repoProjectVersion));
						
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
		}
		return yogaProject;
	}
	
	private function new() 
	{
		targets = new Array<Target>();
		dependencies = new Array<Dependency>();
	}
	
	public function join(yogaSettings : YogaSettings, dependencySet : DependencySet) : Void
	{
		for (dependency in dependencies)
		{
			dependency.grab(yogaSettings, dependencySet);
		}
	}
}