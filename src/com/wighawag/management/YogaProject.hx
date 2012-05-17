package com.wighawag.management;



class YogaProject 
{
	public var configFiles : Array<ConfigFile>;
	public var compilerParameters : Array<String>;
	public var sources : Array<String>;
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
		
		
		
		var sourcesTag : Xml = projectTag.elementsNamed("sources").next();
		if (sourcesTag == null)
		{
			Sys.println("sources not specified for" + yogaProject.id + '_' + yogaProject.version);
			Sys.exit(1);
		}
		
		for (sourceXml in sourcesTag.elementsNamed('source'))
		{
			var srcPath : String = sourceXml.get('path');
			yogaProject.sources.push(srcPath);
			yogaProject.dependencies.push(new SourceDependency(srcPath,srcPath));
		}
		
		if (yogaProject.sources.length == 0)
		{
			Sys.println("source paths not specified");
			Sys.exit(1);
		}
		Sys.println("source : " + yogaProject.sources);
		
		
		var mainTag : Xml = projectTag.elementsNamed("main").next();
		if (mainTag == null)
		{
			Sys.println("main class not specified");
			Sys.exit(1);
		}
		yogaProject.mainClass = mainTag.firstChild().toString();
		Sys.println("main class : " + yogaProject.mainClass);
		
		
		
		for (targetTag in projectTag.elementsNamed("target"))
		{
			var targetName = targetTag.get("name");
			var targetOutput = targetTag.get("hxml");
			
			var target : Target = new Target(targetName, targetOutput);
			yogaProject.targets.push(target);
		}
		
		
		
		var configurationTag : Xml = projectTag.elementsNamed("configuration").next();
		if (configurationTag != null)
		{
			var compilerConfigTag : Xml = configurationTag.elementsNamed("compiler").next();
			if (compilerConfigTag != null)
			{
				for (compilerParam in compilerConfigTag.elementsNamed("param"))
				{
					yogaProject.compilerParameters.push(compilerParam.get('line'));
				}
			}
		}
		
		for (configFileTag in projectTag.elementsNamed("config-file"))
		{
			var configFile : ConfigFile = new ConfigFile(configFileTag.get('template'), configFileTag.get('output'));
			yogaProject.configFiles.push(configFile);
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
						var projectPath : String = dependency.get("path");
						if (projectPath == null)
						{
							projectPath = "";
						}
						yogaProject.dependencies.push(new ZipProjectDependency(zipUrl, projectPath));
						
					case "sourcezip" :
						var sourceZipUrl : String = dependency.get("url");
						var sourcesTag = dependency.elementsNamed('sources').next();
						if (sourcesTag == null)
						{
							Sys.println("no sources provided");
							Sys.exit(1);
						}
						
						var sourcePathArray : Array<String> = new Array<String>();
						
						for (srcTag in sourcesTag.elementsNamed('source'))
						{
							var sourcePath : String = srcTag.get("path");
							sourcePathArray.push(sourcePath);
						}
						
						if (sourcePathArray.length == 0)
						{
							Sys.println("no src path provided");
							Sys.exit(1);
						}
						
						Sys.println("zip source " + sourceZipUrl + " " + sourcePathArray);
						yogaProject.dependencies.push(new ZipSourceDependency(sourceZipUrl, sourcePathArray));
				}
			}
		}
		return yogaProject;
	}
	
	private function new() 
	{
		configFiles = new Array<ConfigFile>();
		compilerParameters = new Array<String>();
		sources = new Array<String>();
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

