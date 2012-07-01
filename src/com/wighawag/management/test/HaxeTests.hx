package com.wighawag.management.test;

import com.wighawag.util.Show;
import com.wighawag.management.SourceDependency;
import com.wighawag.management.YogaSettings;
import com.wighawag.management.DependencySet;
import com.wighawag.management.YogaProject;
import massive.neko.cmd.Console;

class HaxeTests implements TestFramework{

    public var testDirectory : String;
    public var testHxmlFile : String;
    public var testMainClass : String;

    public function new(testDirectory : String, testHxmlFile : String, testMainClass : String) {
        this.testDirectory = testDirectory;
        this.testHxmlFile = testHxmlFile;
        this.testMainClass = testMainClass;
    }

    public function execute(console:Console, currentProject:YogaProject, dependencySet:DependencySet, yogaSettings:YogaSettings):Void {

          Show.message("The default haxe test framework is not yet supported");
//        var testDependencySet = dependencySet.clone();
//
//        testDependencySet.add(new SourceDependency(testDirectory, testDirectory));
//        var hxml = HXMLGenerator.generate(console.dir, testOutputDirectory, outputs, testDependencySet, currentProject.compilerParameters, testMainClass);
//
//        testHxmlFile.writeString(hxml);

    }


}
