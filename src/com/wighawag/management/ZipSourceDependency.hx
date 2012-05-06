package com.wighawag.management;
import com.wighawag.format.zip.ZipExtractor;
import com.wighawag.management.DependencySet;
import com.wighawag.management.YogaSettings;
import com.wighawag.system.SystemUtil;
import sys.FileSystem;


class ZipSourceDependency implements Dependency 
{

	public var url : String;
	public var srcPath : String;
	
	public function new(url : String, srcPath : String) 
	{
		this.url = url;
		this.srcPath = srcPath;
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
		// TODO extract from ZipProjectDependency and RepositoryDependency and use it here as well
		
		var zipSourceRepoFolder : String = settings.localRepoPath + SystemUtil.slash() + "zipSource";
		if (!FileSystem.exists(zipSourceRepoFolder))
		{
			FileSystem.createDirectory(zipSourceRepoFolder);
		}
		
		var localRepoProjectPath : String = zipSourceRepoFolder + SystemUtil.slash() + StringTools.replace(url.substr(7),"/", "_");
		
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
		
		var sourceDependency : SourceDependency = new SourceDependency(localRepoProjectPath + SystemUtil.slash() + srcPath, getUniqueId());
		if (!dependencySet.contains(sourceDependency))
		{
			dependencySet.add(sourceDependency);
		}
	}
	
	public function getUniqueId():String 
	{
		return "ZipSourceDependency_" + url + "_" + srcPath;
	}
	
}