package com.wighawag.management;
import com.wighawag.management.test.HaxeTests;
import com.wighawag.management.test.MunitTests;
import com.wighawag.management.test.TestFramework;
import com.wighawag.util.Show;
import semver.SemVer;

class YogaProject 
{
	public var configFiles : Array<ConfigFile>;
	public var compilerParameters : Array<String>;
	public var sources : Array<String>;
	public var runtimeResources : Array<String>;
	public var compiletimeResources : Array<String>;
	public var mainClass : String;
	public var targets : Array<Target>;
	public var dependencies:Array<Dependency>;
	public var yogaVersion : String;
	
	public var id : String;
	public var version : String;
	
	public var testFramework : TestFramework;
	public var outputPrefix:String;
	
	public var shortName(getShortName, null) : String;

    private var prepared : String; // TODO : date
	
	function getShortName() : String
	{
		return id.substr(id.lastIndexOf(".") + 1);
	}

	public function new(content : String, ?warn = true)
	{
		configFiles = new Array<ConfigFile>();
		compilerParameters = new Array<String>();
		sources = new Array<String>();
		targets = new Array<Target>();
		dependencies = new Array<Dependency>();
		
		
		var xml = Xml.parse(content);
		
		var projectTag = xml.elementsNamed("project").next();
		
		if (projectTag == null)
		{
			Show.criticalError("no project element found");
		}
		
		var yogaVersionTag = projectTag.elementsNamed("yoga-version").next();
		if (yogaVersionTag == null)
		{
			Show.criticalError("no yoga-version element found");
		}
		yogaVersion = yogaVersionTag.firstChild().toString();
		
		var idTag : Xml = projectTag.elementsNamed("id").next();
		if (idTag == null)
		{
			Show.criticalError("id not specified");
		}
		id = idTag.firstChild().toString();

		var versionTag : Xml = projectTag.elementsNamed("version").next();
		if (versionTag == null)
		{
			Show.criticalError("project version not specified");
		}
		version = versionTag.firstChild().toString();

        if(!SemVer.valid(version)){
            Show.criticalError("The Version String is not valid");
        }

        var preparedTag : Xml = projectTag.elementsNamed("prepared").next();
        if (preparedTag == null)
        {
            prepared = null;
        }else{
            prepared = preparedTag.firstChild().toString();
        }

		var sourcesTag : Xml = projectTag.elementsNamed("sources").next();
		if (sourcesTag == null)
		{
			Show.criticalError("sources not specified for" + id + '_' + version);
		}
		
		for (sourceXml in sourcesTag.elementsNamed('source'))
		{
			var srcPath : String = sourceXml.get('path');
			sources.push(srcPath);
			dependencies.push(new SourceDependency(srcPath,srcPath));
		}
		
		if (sources.length == 0)
		{
			Show.criticalError("source paths not specified");
		}
		//Sys.println("source : " + sources);
		
		
		var mainTag : Xml = projectTag.elementsNamed("main").next();
		if (mainTag != null)
		{
            mainClass = mainTag.firstChild().toString();
		}

		
		var testsTag : Xml = projectTag.elementsNamed("tests").next();
		if (testsTag == null)
		{
			//if(warn)Show.message("test not specified for " + id + '_' + version);
		}
		else
		{
            var framework = testsTag.get("framework");

            var testDirectory = testsTag.get('path');
            if (testDirectory == null || testDirectory == "")
            {
                Show.criticalError("test path not specified for " + id + '_' + version);
            }

            var testHxmlFile = testsTag.get('hxml');
            if (testHxmlFile == null || testHxmlFile == "")
            {
                testHxmlFile = "test.hxml";
            }

            if (framework == "munit")
            {
                testFramework = new MunitTests(testDirectory, testHxmlFile);
            }
            else if(framework == "default")
            {
                var testMainClass = testsTag.get('mainClass');
                if (testMainClass == null || testMainClass == "")
                {
                    Show.criticalError("default test framework require a main test Class");
                }

                testFramework = new HaxeTests(testDirectory, testHxmlFile, testMainClass);
            }
            else
            {
                if(warn)Show.message("test framework " + framework + " not supported");
            }
		}

		runtimeResources = new Array<String>();
		var runtimeResourcesTag : Xml = projectTag.elementsNamed("runtime-resources").next();
		if (runtimeResourcesTag == null)
		{
			//Show.message("no runtime resources specified for" + id + '_' + version);
		}
		else
		{
			for (runtimeResourceXml in runtimeResourcesTag.elementsNamed('resource'))
			{
				var resourcePath : String = runtimeResourceXml.get('path');
				runtimeResources.push(resourcePath);
			}
		}
		
		
		
		//Sys.println("run time resources : " + runtimeResources);
		
		compiletimeResources = new Array<String>();
		var compiletimeResourcesTag : Xml = projectTag.elementsNamed("compiletime-resources").next();
		if (compiletimeResourcesTag == null)
		{
			//if(warn)Show.message("no compile time resources specified for" + id + '_' + version);
		}
		else
		{
			for (compiletimeResourceXml in compiletimeResourcesTag.elementsNamed('resource'))
			{
				var resourcePath : String = compiletimeResourceXml.get('path');
				compiletimeResources.push(resourcePath);
			}
		
		}
		
		
		//Sys.println("compile time resources : " + compiletimeResources);
		
		
		
		var targetsTag : Xml = projectTag.elementsNamed("targets").next();
		if (targetsTag == null)
		{
            if(warn)Show.message("There is no targets");
		}
		else
		{
			outputPrefix = targetsTag.get("hxml"); 
			
			var counter = 0;
			for (targetTag in targetsTag.elementsNamed("target"))
			{
				var targetName = targetTag.get("name");
				
				
				var extraParams : Array<String> = new Array<String>();
				for (paramlineTag in targetTag.elementsNamed("param"))
				{
					var param = paramlineTag.get("line");
					extraParams.push(param);
				}
				
				
				var target : Target = new Target(targetName, extraParams);
				
				targets.push(target);		
				
				counter ++;
			}

			if (counter == 0)
			{
                if(warn)Show.message("There is no targets specified");
			}
		}
		
		
		
		
		
		
		
		var configurationTag : Xml = projectTag.elementsNamed("configuration").next();
		if (configurationTag != null)
		{
			var compilerConfigTag : Xml = configurationTag.elementsNamed("compiler").next();
			if (compilerConfigTag != null)
			{
				for (compilerParam in compilerConfigTag.elementsNamed("param"))
				{
					compilerParameters.push(compilerParam.get('line'));
				}
			}
		}
		
		for (configFileTag in projectTag.elementsNamed("config-file"))
		{
			var configFile : ConfigFile = new ConfigFile(configFileTag.get('template'), configFileTag.get('output'));
			configFiles.push(configFile);
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
						
						dependencies.push(new HaxelibDependency(libraryName, version));
						
						
					case "repository" :
						var repoProjectId : String = dependency.get("id");
						var repoProjectVersion : String = dependency.get("version");
						
						dependencies.push(new RepositoryDependency(repoProjectId, repoProjectVersion));
						
					case "zip" :
						var zipUrl : String = dependency.get("url");
						var projectPath : String = dependency.get("path");
						if (projectPath == null)
						{
							projectPath = "";
						}
						dependencies.push(new ZipProjectDependency(zipUrl, projectPath));
						
					case "sourcezip" :
						var sourceZipUrl : String = dependency.get("url");
						var sourcesTag = dependency.elementsNamed('sources').next();
						if (sourcesTag == null)
						{
							Show.criticalError("no sources provided");
						}
						
						var sourcePathArray : Array<String> = new Array<String>();
						
						for (srcTag in sourcesTag.elementsNamed('source'))
						{
							var sourcePath : String = srcTag.get("path");
							sourcePathArray.push(sourcePath);
						}
						
						if (sourcePathArray.length == 0)
						{
							Show.criticalError("no src path provided");
						}
						
						//Sys.println("zip source " + sourceZipUrl + " " + sourcePathArray);
						dependencies.push(new ZipSourceDependency(sourceZipUrl, sourcePathArray));
				}
			}
		}
	}

    public function isSnapshot() : Bool{
        trace(id + "_" + version);
        return version.indexOf("-SNAPSHOT") == (version.length - 9);
    }

    public function isPrepared() : Bool{
        return prepared != null;
    }
	
	public function join(yogaSettings : YogaSettings, dependencySet : DependencySet, step : Int) : Void
	{
		var indentation = "";
		for (i in 0...step){
			indentation += "  ";
		}
		if (dependencies.length > 0)Show.message(indentation + "Dependencies for " + id + "_" + version);
		for (dependency in dependencies)
		{
			Show.message(indentation + "  -" + dependency.descriptionId());
            if (!dependencySet.contains(dependency)){
                dependency.grab(yogaSettings, dependencySet, step);
            }
		}
	}
}

