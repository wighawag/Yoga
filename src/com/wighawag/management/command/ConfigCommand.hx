package com.wighawag.management.command;
import massive.neko.io.File;

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
		
		for (target in currentProject.targets)
		{
			target.generateHxml(console.dir,targetDirectory,currentProject,dependencySet);
		}
		
		
		for (configFile in currentProject.configFiles)
		{
			configFile.generate(console.dir, currentProject, dependencySet, yogaSettings);
		}
		
	}
	
}