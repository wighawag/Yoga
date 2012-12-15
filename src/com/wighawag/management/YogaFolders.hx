package com.wighawag.management;
import massive.neko.io.File;
import haxe.io.Path;
import com.wighawag.util.Show;

class YogaFolders {

    public static function cleanCopy(yogaSettings : YogaSettings, currentProject : YogaProject, currentDir : File, destinationDir : File) {
        var projectFiles = new Hash<Bool>();

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
        currentDir.copyTo(destinationDir, true, new EReg("(^|/)\\.(.*)|(" + yogaSettings.targetDirectory + ")", ""), true);

        var files = destinationDir.getDirectoryListing();
        for (file in files)
        {
            var allFilesDeleted : Bool = true;
            if (file.isDirectory){
                var subFiles = file.getRecursiveDirectoryListing();
                // TODO check : delete subfolder if they themselve shoul be deleted
                for (subFile in subFiles){
                    var shouldBeDeleted = shouldDelete(subFile, destinationDir, projectFiles);
                    if (!shouldBeDeleted){
                        Show.message("keeping " + destinationDir.getRelativePath(subFile));
                        allFilesDeleted = false;
                        break;
                    }
                }
            }
            if(allFilesDeleted){
                if(shouldDelete(file, destinationDir, projectFiles)){
                    delete(file);
                }
            }

        }

    }


    static private function shouldDelete(file : File, tmpDir : File, projectFiles : Hash<Bool>) : Bool{
        var currentFileRelativePath : String = tmpDir.getRelativePath(file);
        if (!projectFiles.exists(currentFileRelativePath))
        {
            return true;
        }
        return false;
    }

    static private function delete(file : File): Void{
        if (file.isDirectory)
        {
            file.deleteDirectory(true);
        }
        else
        {
            file.deleteFile();
        }
    }



    static public function getSettingsFolder() : File{
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
                "\nor set HOME or USERPROFILE environement variable to your home folder where yoga will create a .yoga directory");
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
                Show.criticalError("creating the directory :\n" + e + "\n, you might need to create it manually at " + settingsFolderPath);
            }
        }
        return settingsDirectory;
    }


}
