package com.wighawag.management.command;
import com.wighawag.management.YogaProject;

class BaseYogaProjectCommand extends BaseYogaSettingsCommand
{
	private var currentProject : YogaProject;

	public function new() 
	{
		super();
	}
	
	override function execute() : Void
	{
		super.execute();
		
		var currentProjectFile = this.console.dir.resolveFile(yogaSettings.yogaFileName);
		
        // get access to the project xml
        if (!currentProjectFile.exists){
            Sys.println("no "+ yogaSettings.yogaFileName + " found");
            Sys.exit(1);
        }
		
		var content = currentProjectFile.readString();
		
		currentProject = YogaProject.parse(content);
		
		
		Sys.println("******* This project use yoga version " + currentProject.yogaVersion + " *********");
		
		
	}
	
}