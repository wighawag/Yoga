package com.wighawag.management.command;
import massive.neko.io.File;


class InstallCommand extends DependencyYogaCommand
{

	private var projectFiles : Hash<Bool>;
	
	public function new() 
	{
		super();
		projectFiles = new Hash<Bool>();
	}
	
	override function execute() : Void
	{
		super.execute();
		
		projectFiles.set(yogaSettings.yogaFileName, true);
		
		for (resourcePath in currentProject.runtimeResources)
		{
			projectFiles.set(resourcePath, true);
		}
		
		for (resourcePath in currentProject.compiletimeResources)
		{
			projectFiles.set(resourcePath, true);
		}
		
		for (srcPath in currentProject.sources)
		{
			projectFiles.set(srcPath, true);
		}
		
		Sys.println(projectFiles.toString());
		
	
		// copy to use regex first and then delete file that are not necessary
		var tmpDir : File = yogaSettings.localTmp.resolveDirectory("installing/" + currentProject.id + "_" + currentProject.version, true);
		console.dir.copyTo(tmpDir, true, new EReg("(^|/)\\.(.*)|(" + yogaSettings.targetDirectory + ")", ""), true);
		
		var files = tmpDir.getDirectoryListing();
		for (file in files) 
		{
			var currentFileRelativePath : String = tmpDir.getRelativePath(file);
			Sys.println(currentFileRelativePath);
			if (!projectFiles.exists(currentFileRelativePath))
			{
				if (file.isDirectory)
				{
					file.deleteDirectory(true);
				}
				else
				{
					file.deleteFile();
				}
			}
		}
		
		var installDir : File = yogaSettings.localRepoProjectRepo.resolveDirectory(currentProject.id + "_" + currentProject.version, true);
		//tmpDir.moveTo(installDir, true);
		
	}
	
	
}