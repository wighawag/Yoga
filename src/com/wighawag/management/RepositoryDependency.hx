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
		var repoFolder : String = settings.localRepoPath + SystemUtil.slash() + "remote";
		if (!FileSystem.exists(repoFolder))
		{
			FileSystem.createDirectory(repoFolder);
		}

		var localRepoProjectPath : String = repoFolder + SystemUtil.slash() + id + "_" + version;
		
		// check if exist locally
		if (!FileSystem.exists(localRepoProjectPath))
		{
			
			
			//if not get it from the repo
			var tmpZipPath = ZipExtractor.getZipFromAnyRepositories(settings.localTmpPath, settings.repoList, id, version);
			if (tmpZipPath == null)
			{
				Sys.println("cannot find " + id + ":" + version);
				Sys.exit(1);
			}
				
			Sys.println("zip downloaded :  " + tmpZipPath);
			
			//then unzip 
			Sys.println("unzipping " + tmpZipPath + " to " + localRepoProjectPath);
			ZipExtractor.extract(tmpZipPath, localRepoProjectPath);
		}
		
		// get project and parse it :
		var projectFilePath = localRepoProjectPath + SystemUtil.slash() + settings.yogaFileName;
		if (!FileSystem.exists(projectFilePath))
		{
			Sys.println("this dependency does not have any project file, it has been wrongly installed");
			Sys.exit(1);
		}
		//var fileInput = File.read(projectFilePath, false);
		var fileContent = File.getContent(projectFilePath);
		var dependencyProject : YogaProject = YogaProject.parse(fileContent);
		
		if (id != dependencyProject.id)
		{
			Sys.println("id do not match between the declared dependency and the actual dependency project! " + "( id :" + id + ", dependencyId : " + dependencyProject.id + ")" );
			Sys.exit(1);
		}
		
		var sourceDependency : SourceDependency = new SourceDependency(localRepoProjectPath + SystemUtil.slash() + dependencyProject.sourceFolder, dependencyProject.id);
		if (!dependencySet.contains(sourceDependency))
		{
			dependencySet.add(sourceDependency);
		
			//(+get dependencies if specified (recusrive))
			dependencyProject.join(settings, dependencySet);
		}
	}
	
	public function getUniqueId():String 
	{
		return "RepositoryDependency_" + id;
	}
	
}