package com.wighawag.management;
import com.wighawag.format.zip.ZipExtractor;
import com.wighawag.management.DependencySet;
import com.wighawag.management.YogaSettings;
import com.wighawag.system.SystemUtil;
import sys.FileSystem;
import sys.io.File;

class ZipProjectDependency implements Dependency
{

	public var url : String;
	
	public function new(url : String) 
	{
		if (url.substr(0, 7) != "http://")
		{
			Sys.println("invalid url need to start with http://");
			Sys.exit(1);
		}
		this.url = url;
	}
	
	/* INTERFACE com.wighawag.management.Dependency */
	
	public function getHxmlString():String 
	{
		return ""; // transormed into a source repository ?
	}
	
	public function getNMMLString():String 
	{
		return ""; // transormed into a source repository ?
	}
	
	public function grab(settings:YogaSettings, dependencySet:DependencySet):Void 
	{
		// TODO extract from RepositoryDependency and use it here as well
		
		
		var repoFolder : String = settings.localRepoPath + SystemUtil.slash() + "zipProject";
		if (!FileSystem.exists(repoFolder))
		{
			FileSystem.createDirectory(repoFolder);
		}
			
		var localRepoProjectPath : String = repoFolder + SystemUtil.slash() + StringTools.replace(url.substr(7),"/", "_");
		
		// check if exist locally
		if (!FileSystem.exists(localRepoProjectPath))
		{
			
			//if not get it from the repo
			var tmpZipPath = ZipExtractor.getZip(settings.localTmpPath, url);
			if (tmpZipPath == null)
			{
				Sys.println("cannot download " + url);
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
		
		var fileContent = File.getContent(projectFilePath);
		var dependencyProject : YogaProject = YogaProject.parse(fileContent);
		
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
		return "ZipProjectDependency_" + url;
	}
	
}