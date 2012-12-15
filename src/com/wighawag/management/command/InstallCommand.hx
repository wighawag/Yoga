package com.wighawag.management.command;
import com.wighawag.management.YogaFolders;
import com.wighawag.util.Show;
import massive.neko.io.File;


class InstallCommand extends TestCommand
{


	public function new() 
	{
		super();
	}
	
	override function execute() : Void
	{
		super.execute();

        if(!currentProject.isSnapshot()){
            Show.criticalError("can only install snapshot projects");
        }

		// copy to use regex first and then delete file that are not necessary
		var tmpDir : File = yogaSettings.localTmp.resolveDirectory("installing/" + currentProject.id + "_" + currentProject.version, true);

        YogaFolders.cleanCopy(yogaSettings, currentProject, console.dir, tmpDir);

		var installDir : File = yogaSettings.localRepoProjectRepo.resolveDirectory(currentProject.id + "_" + currentProject.version, true);
		tmpDir.moveTo(installDir, true);
		
	}


	
}