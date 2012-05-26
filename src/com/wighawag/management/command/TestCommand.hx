package com.wighawag.management.command;
import com.wighawag.management.DependencySet;
import com.wighawag.management.HaxelibDependency;
import com.wighawag.management.SourceDependency;
import com.wighawag.management.Target;
import com.wighawag.management.YogaProject;
import com.wighawag.management.YogaSettings;
import haxe.Template;
import massive.neko.io.File;


class TestCommand extends DependencyYogaCommand
{

	private var munitTemplate : String;

	public function new()
	{
		super();
		munitTemplate = "version=::version::\nsrc=::testDirectory::\nbin=::testOutputDirectory::\nreport=::testReportDirectory::\nhxml=::testHxmlFile::\nclassPaths=::foreach srcPaths::::__current__::,::end::\n";
		
		
	}
	
	override function execute() : Void
	{
		super.execute();
		
		if (currentProject.testDirectory == null)
		{
			Sys.println("no test specified");
			return;
		}
		
		var munitConfig : MunitConfig = new MunitConfig(currentProject, dependencySet, yogaSettings);
		
		/*
		var template : Template;
		 
		template = new Template(munitTemplate);
		var munitFile : File = console.dir.resolveFile('.munit', true);
		
		munitFile.writeString(template.execute(munitConfig));
		*/
		
		
		
		var testHxmlFile : File = console.dir.resolveFile(munitConfig.testHxmlFile);
		testHxmlFile.deleteFile();
		
		var paths : String = "";
		for (path in munitConfig.srcPaths)
		{
			paths = paths + path + ",";
		}
		paths = paths.substr(0, paths.length -1);
		Sys.command("haxelib", ["run", "munit", "config", "-reset" , "-src", munitConfig.testDirectory, "-bin", munitConfig.testOutputDirectory, "-report", munitConfig.testReportDirectory, "-hxml", munitConfig.testHxmlFile, "-classPaths", paths]);
		
		
		// TODO clean that up
		var testHxmlTemplateFile : File = console.originalDir.resolveFile("test.hxml.template");
		var testHxmlTemplate : String = testHxmlTemplateFile.readString();
		var hxmlTemplate : Template = new Template(testHxmlTemplate);
		var final = hxmlTemplate.execute(munitConfig);
		final = final.substr(0, final.lastIndexOf("--next"));
		testHxmlFile.writeString(final);
		
		Sys.command("haxelib", ["run", "munit", "test"]);
	}
	
}

class MunitConfig
{
	public var version : String;
	public var testDirectory : String;
	public var testOutputDirectory : String;
	public var testReportDirectory : String;
	public var testHxmlFile : String;
	public var srcPaths : Array<String>;
	public var targets : Array<Target>;
	public var haxelibs : Array<HaxelibDependency>;
	
	public function new(currentProject : YogaProject, dependencySet : DependencySet, yogaSettings : YogaSettings)
	{
		version = currentProject.munitVersion;
		testDirectory = currentProject.testDirectory;
		testOutputDirectory = yogaSettings.targetDirectory + '/tests';
		testReportDirectory = testOutputDirectory + '/report';
		testHxmlFile = currentProject.testHxmlFile;
		srcPaths = new Array<String>();
		haxelibs = new Array<HaxelibDependency>();
		var dependencies = dependencySet.getDependencies();
		for (dependency in dependencies)
		{
			if (Type.getClass(dependency) == SourceDependency)
			{
				srcPaths.push(cast(dependency, SourceDependency).path);
			}
			else if(Type.getClass(dependency) == HaxelibDependency)
			{
				haxelibs.push(cast(dependency, HaxelibDependency));
			}
		}
		targets = new Array<Target>();
		for (target in currentProject.targets)
		{
			if (target.name == "cpp")
			{
				Sys.println("munit does not support cpp yet, this will be ignored by munit test runner");
			}
			targets.push(target);
		}
		

		
	}
}