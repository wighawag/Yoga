package com.wighawag.management.command;
import com.wighawag.management.ZipSourceDependency;
import com.wighawag.management.ZipProjectDependency;
import com.wighawag.management.RepositoryDependency;
import massive.neko.io.File;
import massive.neko.util.ZipUtil;
import com.wighawag.util.Show;

class DeployPrepareCommand extends TestCommand
{

	public function new() 
	{
		super();
	}
	
	override function execute() : Void
	{
		super.execute();

        if(!currentProject.isSnapshot()){
            Show.criticalError("can only prepare snapshot project");
        }

        if(currentProject.isPrepared()){
            Show.criticalError("This project seems already prepared");
        }

        //The following require just looking through the list, no need to perform a join

        //TODO check repo dependencies so that they are not snapshot
        var hasSnapShotDependencies : Bool = false;
        var snapshotMessage = "Cannot proceed as there are snapshot as dependencies, please remove them :";
        var hasZipDependencies : Bool = false;
        var zipMessage = "There are depencies that are zip files, This is not recommended :";
        for (dependency in currentProject.dependencies){
            if (Std.is(dependency, RepositoryDependency)){
                var repoDependency : RepositoryDependency = cast(dependency);
                var isSnapshot = repoDependency.isSnapshot();
                if (isSnapshot){
                    hasSnapShotDependencies = true;
                    snapshotMessage += "\n " + repoDependency.id + "_" + repoDependency.version;
                }
            }else if (Std.is(dependency, ZipProjectDependency)){
                var zipProjectDependency : ZipProjectDependency = cast(dependency);
                hasZipDependencies = true;
                zipMessage += "\n project zip : " + zipProjectDependency.url;
            }else if (Std.is(dependency, ZipSourceDependency)){
                var zipSourceDependency : ZipSourceDependency = cast(dependency);
                hasZipDependencies = true;
                zipMessage += "\n source zip : " + zipSourceDependency.url;
            }
        }

        if(hasSnapShotDependencies){
            Show.criticalError(snapshotMessage);
        }
        if(hasZipDependencies){
            Show.message(zipMessage);
            Sys.println("Do you still want to proceed ? y/N");
            var response = Sys.stdin().readLine();
            if (response != "y" && response != "yes" && response != "Y" && response != "YES" && response != "Yes"){
                Sys.exit(1);
            }
        }

        // TODO keep the xml structure
        var currentProjectFile = this.console.dir.resolveFile(yogaSettings.yogaFileName);
        var content = currentProjectFile.readString();

        var versionBegin = content.indexOf("<version>");
        var versionEnd = content.indexOf("</version>");
        var newContent = content.substr(0,versionBegin)
        + "<version>"+currentProject.version.substr(0, currentProject.version.length - 9) +"</version>"
        + "\n\t" + "<prepared>" + Date.now().toString() + "</prepared>"
        + content.substr(versionEnd + 10);

        currentProjectFile.writeString(newContent,false);

        Show.done("You can now commit and tag  before deploying to the repo (deploy:perform)");
	}
	
}

