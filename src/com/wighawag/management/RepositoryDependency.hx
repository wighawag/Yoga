package com.wighawag.management;
import com.wighawag.format.zip.ZipExtractor;
import com.wighawag.system.SystemUtil;
import sys.FileSystem;
import sys.io.File;


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
	
	public function grab(settings : YogaSettings, dependencySet : DependencySet ):Void 
	{
		
		var localRepoProjectDirectory = settings.localRepoProjectRepo.resolveDirectory(id + "_" + version);
		
		// check if exist locally
		if (!localRepoProjectDirectory.exists)
		{
			//if not get it from the repo
			var tmpZipPath = ZipExtractor.getZipFromAnyRepositories(settings.localTmp.nativePath, settings.repoList, id, version);
			if (tmpZipPath == null)
			{
				Sys.println("cannot find " + id + ":" + version);
				Sys.exit(1);
			}
				
			Sys.println("zip downloaded :  " + tmpZipPath);
			
			//then unzip 
			Sys.println("unzipping " + tmpZipPath + " to " + localRepoProjectDirectory.nativePath);
			ZipExtractor.extract(tmpZipPath, localRepoProjectDirectory.nativePath);
		}
		
		// get project and parse it :
		var projectFile = localRepoProjectDirectory.resolveFile(settings.yogaFileName);
		if (!projectFile.exists)
		{
			Sys.println("this dependency does not have any project file, it has been wrongly installed");
			Sys.exit(1);
		}
		
		var dependencyProject : YogaProject = new YogaProject(projectFile.readString());
		
		if (id != dependencyProject.id)
		{
			Sys.println("id do not match between the declared dependency and the actual dependency project! " + "( id :" + id + ", dependencyId : " + dependencyProject.id + ")" );
			Sys.exit(1);
		}
		
			
		for (sourceFolder in dependencyProject.sources)
		{
			
			var sourceDependency : SourceDependency = new SourceDependency(localRepoProjectDirectory.resolveDirectory(sourceFolder).nativePath, dependencyProject.id + '_' + sourceFolder);
			if (!dependencySet.contains(sourceDependency))
			{
				dependencySet.add(sourceDependency);
			
				//(+get dependencies if specified (recusrive))
				dependencyProject.join(settings, dependencySet);
			}
		}
	}
	
	public function getUniqueId():String 
	{
		return "RepositoryDependency_" + id;
	}
	
}