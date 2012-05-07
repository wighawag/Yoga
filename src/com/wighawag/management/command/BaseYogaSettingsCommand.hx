package com.wighawag.management.command;
import com.wighawag.management.YogaSettings;
import haxe.io.Path;
import massive.neko.cmd.Command;
import massive.neko.io.File;


class BaseYogaSettingsCommand extends Command
{

	private var yogaSettings : YogaSettings;
	
	public function new() 
	{
		super();
	}
	
	override function execute() : Void
	{
		super.execute();
		
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
			Sys.println("no Environment variable defined for finding the yoga folder, please set YOGA_FOLDER to the path you want yoga to store its local repo and settings");
			Sys.exit(1);
		}
		
		var settingsDirectory : File = null;
		try
		{
			settingsDirectory = File.create(settingsFolderPath, FileType.DIRECTORY);
		}
		catch (e : Dynamic)
		{
			Sys.println("error for " + settingsFolderPath);
			Sys.exit(1);
		}
		
		Sys.println("local yoga folder " + settingsDirectory.toString());
		
		if (!settingsDirectory.exists)
		{
			Sys.println("creating folder " + settingsDirectory.toString() + " ...");
			try
			{
				settingsDirectory.createDirectory();
			} catch (e : Dynamic)
			{
				Sys.println("error while creating the directory " + e + " , you might need to create manuually at " + settingsFolderPath);
				Sys.exit(1);
			}
		}
		
		yogaSettings = new YogaSettings(settingsDirectory);
	}
	
}