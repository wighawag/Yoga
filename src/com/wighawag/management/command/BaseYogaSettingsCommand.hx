package com.wighawag.management.command;
import com.wighawag.management.YogaSettings;
import haxe.io.Path;
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

        Show.message("version 1");
		
		var settingsFolderPath : String = "";
		if (Sys.environment().exists("HOME")) {
			settingsFolderPath = new Path(Sys.getEnv("HOME") + '/.yoga').toString();
		}else if (Sys.environment().exists("USERPROFILE")) {
			settingsFolderPath = new Path(Sys.getEnv("USERPROFILE") + '/.yoga' ).toString();
		}
		else if (Sys.environment().exists("YOGA_FOLDER"))
		{
			settingsFolderPath = Sys.getEnv("YOGA_FOLDER");
		}
		else
		{
			Show.criticalError("no Environment variable defined for finding the yoga folder." +
			"\nPlease set YOGA_FOLDER to the path you want yoga to store its local repo and settings" +
			"\nor set HOME or USERPROFILE environement variable to your home folder where yoga will create a directory");
		}
		
		var settingsDirectory : File = null;
		try
		{
			settingsDirectory = File.create(settingsFolderPath, FileType.DIRECTORY);
		}
		catch (e : Dynamic)
		{
			Show.criticalError("no possible to access " + settingsFolderPath);
		}
		
		if (!settingsDirectory.exists)
		{
			//Sys.println("creating folder " + settingsDirectory.toString() + " ...");
			try
			{
				settingsDirectory.createDirectory();
			} catch (e : Dynamic)
			{
				Show.criticalError("creating the directory " + e + " , you might need to create manually at " + settingsFolderPath);
			}
		}
		
		Show.message("yoga folder : " + settingsDirectory.nativePath);
		
		yogaSettings = new YogaSettings(settingsDirectory);
	}
	
}