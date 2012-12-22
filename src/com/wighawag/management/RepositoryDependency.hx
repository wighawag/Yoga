package com.wighawag.management;
import com.wighawag.format.zip.ZipExtractor;
import com.wighawag.system.SystemUtil;
import sys.FileSystem;
import sys.io.File;
import com.wighawag.util.Show;

class RepositoryDependency implements Dependency
{

	public var id : String;
	public var version : String;
	
	public function new(id : String, version : String) 
	{
		this.id = id;
		this.version = version;
	}
	
	/* INTERFACE com.wighawag.management.Dependency */
	
	public function getHxmlString():String 
	{
		return ""; // should be transformed into a sourceDependency ?
	}
	
	public function getNMMLString():String 
	{
		return ""; // should be transformed into a sourceDependency ?
	}
	
	public function grab(settings : YogaSettings, dependencySet : DependencySet, step : Int ):Void
	{
		
		var localRepoProjectDirectory = settings.localRepoProjectRepo.resolveDirectory(id + "_" + version);
		
		// check if exist locally
		if (!localRepoProjectDirectory.exists)
		{
			//if not get it from the repo
			var tmpZipPath = ZipExtractor.getZipFromAnyRepositories(settings.localTmp.nativePath, settings.repoList, id, version);
			if (tmpZipPath == null)
			{
				Show.criticalError("cannot find " + id + ":" + version);
			}
				
			//Sys.println("zip downloaded :  " + tmpZipPath);
			
			//then unzip 
			//Sys.println("unzipping " + tmpZipPath + " to " + localRepoProjectDirectory.nativePath);
			ZipExtractor.extract(tmpZipPath, localRepoProjectDirectory.nativePath);
		}
		
		// get project and parse it :
		var projectFile = localRepoProjectDirectory.resolveFile(settings.yogaFileName);
		if (!projectFile.exists)
		{
			Show.criticalError("this dependency (" + id + "_" + version + ") does not have any project file, it has been wrongly installed");
		}

        Show.message("grabing " + id + "_" + version);
		var dependencyProject : YogaProject = new YogaProject(projectFile.readString(), false);
		
		if (id != dependencyProject.id)
		{
			Show.criticalError("id do not match between the declared dependency and the actual dependency project! " + "( id :" + id + ", dependencyId : " + dependencyProject.id + ")" );
		}
		
			
		for (sourceFolder in dependencyProject.sources)
		{
			var sourceDependency : SourceDependency = new SourceDependency(localRepoProjectDirectory.resolveDirectory(sourceFolder).nativePath, dependencyProject.id + '_' + sourceFolder, dependencyProject.id, dependencyProject.version);
			dependencySet.add(sourceDependency);
		}

		//Show.message("Dependencies for " + dependencyProject.id + "_" + dependencyProject.version);
		dependencyProject.join(settings, dependencySet, step + 1);
	}

	public function getUniqueId():String 
	{
		return "RepositoryDependency_" + id + "_" + version;
	}

    public function isSnapshot() : Bool{
        return version.indexOf("-SNAPSHOT") == (version.length - 9);
    }

	public function descriptionId():String {
		return "project " + id + "_" + version;
	}
	
}