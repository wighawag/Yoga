package com.wighawag.management.command;
import com.wighawag.management.YogaProject;
import com.wighawag.util.Show;

class BaseYogaProjectCommand extends BaseYogaSettingsCommand
{
	private var currentProject : YogaProject;

	public function new() 
	{
		super();
	}
	
	override public function execute() : Void
	{
		super.execute();
		
		var currentProjectFile = this.console.dir.resolveFile(yogaSettings.yogaFileName);
		
        // get access to the project xml
        if (!currentProjectFile.exists){
            Show.criticalError("no "+ yogaSettings.yogaFileName + " found");
        }
		
		var content = currentProjectFile.readString();
		
		currentProject = new YogaProject(content);
		
		Show.message("******* This project use yoga version " + currentProject.yogaVersion + " *********");
	}
	
}