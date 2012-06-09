package com.wighawag.management.command;
import com.wighawag.management.DependencySet;
import com.wighawag.management.HaxelibDependency;
import com.wighawag.management.HXMLGenerator;
import com.wighawag.management.Output;
import com.wighawag.management.SourceDependency;
import com.wighawag.management.Target;
import com.wighawag.management.YogaProject;
import com.wighawag.management.YogaSettings;
import haxe.Template;
import massive.neko.io.File;
import sys.io.Process;
import com.wighawag.util.Show;

class TestCommand extends DependencyYogaCommand
{

	private var munitTemplate : String;

	public function new()
	{
		super();
		//munitTemplate = "version=::version::\nsrc=::testDirectory::\nbin=::testOutputDirectory::\nreport=::testReportDirectory::\nhxml=::testHxmlFile::\nclassPaths=::foreach srcPaths::::__current__::,::end::\n";
		
		
	}
	
	override function execute() : Void
	{
		super.execute();
		
		if (currentProject.testDirectory == null)
		{
			Show.message("no test specified");
			return;
		}
		
		var munitConfig : MunitConfig = new MunitConfig(currentProject, dependencySet, yogaSettings);
		
		//TODO delete .munit file
		
		var testHxmlFile : File = console.dir.resolveFile(munitConfig.testHxmlFile);
		testHxmlFile.deleteFile();
		
		var paths : String = "";
		for (path in munitConfig.srcPaths)
		{
			paths = paths + path + ",";
		}
		paths = paths.substr(0, paths.length -1);
		Sys.command("haxelib", ["run", "munit", "config", "-reset" , "-src", munitConfig.testDirectory, "-bin", munitConfig.testOutputDirectory, "-report", munitConfig.testReportDirectory, "-hxml", munitConfig.testHxmlFile, "-classPaths", paths]);
		

		var outputs : Array<Output> = new Array<Output>();
		
		for (target in currentProject.targets)
		{
			if (target.name == "cpp")
			{
				continue; // skop cpp as it is not supported by munit
			}
			var outputFileName = target.name + "_test";
			switch(target.name)
			{
				case "swf" : outputFileName = "as3_test.swf";
				case "neko" : outputFileName = "neko_test.n";
				case "js" : outputFileName = "js_test.js";
			}
		
			outputs.push(new Output(outputFileName, target));
		}
		
		var testOutputDirectory = console.dir.resolveDirectory(munitConfig.testOutputDirectory);
		
		var testDependencySet = dependencySet.clone();
		testDependencySet.add(new HaxelibDependency("hamcrest"));
		testDependencySet.add(new HaxelibDependency("munit"));
		//var testPath = console.dir.resolveDirectory(currentProject.testDirectory).nativePath;
		testDependencySet.add(new SourceDependency(currentProject.testDirectory, currentProject.testDirectory));
		var hxml = HXMLGenerator.generate(testOutputDirectory, outputs, testDependencySet, currentProject.compilerParameters, "TestMain");
		
		
		testHxmlFile.writeString(hxml);
		
		
		// TODO : patch or rewrite the TestMain.hx so that it use an TextOutput
		
		var munitRunProcess = new Process("haxelib", ["run", "munit", "test"]);
		var output = munitRunProcess.stdout.readAll().toString();
		//var errorOutput = munitRunProcess.stderr.readAll().toString();
		
		// TODO : if failure stop and 
		
		Sys.println(output);
		//Sys.println("ERROR :" + errorOutput);
		
		//Sys.command("haxelib", ["run", "munit", "run"]);
		
		//Sys.command("haxelib", ["run", "munit", "test"]);
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
				Show.message("munit does not support cpp yet, this will be ignored by munit test runner");
			}
			targets.push(target);
		}
		

		
	}
}