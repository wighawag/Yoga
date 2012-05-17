package com.wighawag.management;
import com.wighawag.format.zip.ZipExtractor;
import com.wighawag.management.DependencySet;
import com.wighawag.management.YogaSettings;
import com.wighawag.system.SystemUtil;
import massive.neko.io.File;
import sys.FileSystem;


class ZipSourceDependency implements Dependency 
{

	public var url : String;
	public var srcPathArray : Array<String>;
	
	public function new(url : String, srcPathArray : Array<String>) 
	{
		this.url = url;
		this.srcPathArray = srcPathArray;
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
		
		
		var localRepoProjectDirectory  = settings.localZipProjectRepo.resolveDirectory(StringTools.replace(StringTools.replace(url.substr(7), "/", "_"), ":", "_"));
		
		// check if exist locally
		if (!localRepoProjectDirectory.exists)
		{
			var zipFileName : String = StringTools.replace(url.substr(7), "/", "_");
			zipFileName = StringTools.replace(zipFileName, ":", "_");
			var tmpZipFile = settings.localTmp.resolveFile(zipFileName);
			//if not get it from the repo
			
			var got : Bool = ZipExtractor.getZip(tmpZipFile.nativePath , url);
			if (!got)
			{
				Sys.println("cannot download " + url);
				Sys.exit(1);
			}
				
			Sys.println("zip downloaded :  " + tmpZipFile.nativePath);
			
			//then unzip 
			Sys.println("unzipping " + tmpZipFile.nativePath + " to " + localRepoProjectDirectory.nativePath);
			
			ZipExtractor.extract(tmpZipFile.nativePath, localRepoProjectDirectory.nativePath);
		}
		
		
		for (srcPath in srcPathArray)
		{
			var srcDirectory : File = null;
			
			var files : Array<File> = localRepoProjectDirectory.getRecursiveDirectoryListing(new EReg(srcPath, ""));
			for (file in files)
			{
				Sys.println(file.nativePath);
				if (file.isDirectory)
				{
					srcDirectory = file;
					break;
				}
			}
		
			if (srcDirectory == null)
			{
				srcDirectory = localRepoProjectDirectory.resolveDirectory(srcPath);
			}
			
			if (!srcDirectory.exists)
			{
				Sys.println("the srcPath '" + srcDirectory.nativePath + "' does not exist");
				Sys.exit(1);
			}
			
			var sourceDependency : SourceDependency = new SourceDependency(srcDirectory.nativePath, getUniqueId() + srcDirectory.nativePath);
			if (!dependencySet.contains(sourceDependency))
			{
				dependencySet.add(sourceDependency);
			}
		}
	}
	
	public function getUniqueId():String 
	{
		return "ZipSourceDependency_" + url;
	}
	
}