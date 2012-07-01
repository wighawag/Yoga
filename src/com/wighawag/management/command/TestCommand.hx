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
	
	override public function execute() : Void
	{
		super.execute();
		
		if (currentProject.testFramework == null)
		{
			Show.message("no test specified");
			return;
		}

        if (currentProject.targets.length == 0)
        {
            Show.criticalError("There are no targets specified, Tests cannot be run");
        }

		currentProject.testFramework.execute(console, currentProject, dependencySet, yogaSettings);
	}
	
}
