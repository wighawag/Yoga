package com.wighawag.management.test;
import massive.neko.cmd.Console;
import com.wighawag.management.test.MunitTests;
import com.wighawag.management.Target;
import sys.io.Process;
import com.wighawag.management.SourceDependency;
import com.wighawag.management.HaxelibDependency;
import com.wighawag.management.Output;
import massive.neko.io.File;
import com.wighawag.management.command.TestCommand;
import com.wighawag.management.YogaSettings;
import com.wighawag.management.DependencySet;
import com.wighawag.management.YogaProject;
import com.wighawag.util.Show;

class MunitTests implements TestFramework{

    public var testDirectory : String;
    public var testHxmlFile : String;

    public function new(testDirectory : String, testHxmlFile : String) {
        this.testDirectory = testDirectory;
        this.testHxmlFile = testHxmlFile;
    }

    public function execute(console : Console, currentProject : YogaProject, dependencySet : DependencySet, yogaSettings : YogaSettings):Void {
        var munitConfig : MunitConfig = new MunitConfig(this, currentProject, dependencySet, yogaSettings);

        var munitFile : File = console.dir.resolveFile(".munit");
        munitFile.deleteFile();

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
        testDependencySet.add(new SourceDependency(testDirectory, testDirectory));
        var hxml = HXMLGenerator.generate(console.dir, testOutputDirectory, outputs, testDependencySet, currentProject.compilerParameters, "TestMain");


        testHxmlFile.writeString(hxml);


        var testMainFile : File = console.originalDir.resolveFile("TestMain.hx");
        var destTestMainFile : File = console.dir.resolveFile(testDirectory + "/TestMain.hx");
        testMainFile.copyTo(destTestMainFile, true);

        var munitRunProcess = new Process("haxelib", ["run", "munit", "test"]);
        var output = munitRunProcess.stdout.readAll().toString();

        if (output.indexOf("Error") != -1){
            Show.message(output);
            Show.criticalError("Compilation Error");
        }

        var resultLine = output.substr(output.indexOf("PLATFORMS TESTED:"));
        resultLine = resultLine.substr(0,resultLine.indexOf("\n"));


        //PLATFORMS TESTED: 2, PASSED: 0, FAILED: 2, ERRORS: 0, TIME: 1.13492
        var failChunk = resultLine.substr(resultLine.indexOf("FAILED:")+8);
        failChunk = failChunk.substr(0, failChunk.indexOf(","));
        var platformFailures = Std.parseInt(failChunk);
        if (platformFailures > 0)
        {
            Show.criticalError("Test Failures : " + failChunk);
        }

        var errorChunk = resultLine.substr(resultLine.indexOf("ERRORS:")+8);
        errorChunk = errorChunk.substr(0, errorChunk.indexOf(","));
        var platformErrors = Std.parseInt(errorChunk);
        if (platformErrors > 0)
        {
            Show.criticalError("Test Errors : " + errorChunk);
        }
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

    public function new(munitTests : MunitTests, currentProject : YogaProject, dependencySet : DependencySet, yogaSettings : YogaSettings)
    {
        //version = currentProject.munitVersion;
        testDirectory = munitTests.testDirectory;
        testOutputDirectory = yogaSettings.targetDirectory + '/tests';
        testReportDirectory = testOutputDirectory + '/report';
        testHxmlFile = munitTests.testHxmlFile;
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