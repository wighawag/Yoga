package com.wighawag.management.command;
import com.wighawag.management.YogaFolders;
import com.wighawag.management.YogaSettings;
import massive.neko.cmd.Command;
import massive.neko.io.File;
import com.wighawag.util.Show;

class BaseYogaSettingsCommand extends Command
{

	private var yogaSettings : YogaSettings;
	
	public function new() 
	{
		super();
	}
	
	override public function execute() : Void
	{
		super.execute();

		var settingsDirectory = YogaFolders.getSettingsFolder();
		
		Show.message("Yoga folder : " + settingsDirectory.nativePath);
		
		yogaSettings = new YogaSettings(settingsDirectory);
	}
	
}