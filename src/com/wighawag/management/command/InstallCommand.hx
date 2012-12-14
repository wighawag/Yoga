package com.wighawag.management.command;
import com.wighawag.util.Show;
import massive.neko.io.File;


class InstallCommand extends TestCommand
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
		

		// copy to use regex first and then delete file that are not necessary
		var tmpDir : File = yogaSettings.localTmp.resolveDirectory("installing/" + currentProject.id + "_" + currentProject.version, true);
        Show.message("installing to " + tmpDir.nativePath);
		console.dir.copyTo(tmpDir, true, new EReg("(^|/)\\.(.*)|(" + yogaSettings.targetDirectory + ")", ""), true);


		var files = tmpDir.getDirectoryListing();
		for (file in files) 
		{
            var allFilesDeleted : Bool = true;
            if (file.isDirectory){
                var subFiles = file.getRecursiveDirectoryListing();
                // TODO check : delete subfolder if they themselve shoul be deleted
                for (subFile in subFiles){
                    var shouldBeDeleted = shouldDelete(subFile, tmpDir);
                    if (!shouldBeDeleted){
                        Show.message("keeping " + tmpDir.getRelativePath(subFile));
                        allFilesDeleted = false;
                        break;
                    }
                }
            }
            if(allFilesDeleted){
                if(shouldDelete(file, tmpDir)){
                    delete(file);
                }
            }

		}

		var installDir : File = yogaSettings.localRepoProjectRepo.resolveDirectory(currentProject.id + "_" + currentProject.version, true);
		tmpDir.moveTo(installDir, true);
		
	}

    private function shouldDelete(file : File, tmpDir : File) : Bool{
        var currentFileRelativePath : String = tmpDir.getRelativePath(file);
        if (!projectFiles.exists(currentFileRelativePath))
        {
            return true;
        }
        return false;
    }

    private function delete(file : File): Void{
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