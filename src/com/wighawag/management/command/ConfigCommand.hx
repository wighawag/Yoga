package com.wighawag.management.command;
import com.wighawag.management.HXMLGenerator;
import com.wighawag.management.Output;
import massive.neko.io.File;
import com.wighawag.util.Show;

class ConfigCommand extends DependencyYogaCommand
{

	public function new() 
	{
		super();
	}
	
	override function execute() : Void
	{
		super.execute();
	
		var targetDirectory = console.dir.resolveDirectory(yogaSettings.targetDirectory);
		targetDirectory.deleteDirectory(true);
		
		targetDirectory = console.dir.resolveDirectory(yogaSettings.targetDirectory, true);
		
		if (currentProject.mainClass == null)
        {
            Show.message("target currently do not support project without main class");
            return;
        }

		for (target in currentProject.targets)
		{
			var outputs : Array<Output> = new Array<Output>();
			outputs.push(new Output(currentProject.shortName + "_" + currentProject.version + target.getExtension(), target));
			
			var hxml = HXMLGenerator.generate(console.dir, targetDirectory, outputs, dependencySet, currentProject.compilerParameters, currentProject.mainClass);
			var hxmlFile = console.dir.resolveFile(currentProject.outputPrefix + "_" + target.name + ".hxml", true);
			hxmlFile.writeString(hxml);
		}
		
		
		
		for (configFile in currentProject.configFiles)
		{
			configFile.generate(console.dir, currentProject, dependencySet, yogaSettings);
		}

        Show.done();
	}
	
}