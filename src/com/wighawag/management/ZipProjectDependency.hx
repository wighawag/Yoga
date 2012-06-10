package com.wighawag.management;
import com.wighawag.format.zip.ZipExtractor;
import com.wighawag.management.DependencySet;
import com.wighawag.management.YogaSettings;
import com.wighawag.system.SystemUtil;
import massive.neko.io.File;
import sys.FileSystem;
import com.wighawag.util.Show;

class ZipProjectDependency implements Dependency
{

	public var url : String;
	public var path:String;
	
	public function new(url : String, path : String) 
	{
		if (url.substr(0, 7) != "http://")
		{
			Show.criticalError("invalid url need to start with http://");
		}
		this.url = url;
		this.path = path;
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
		var localRepoProjectDirectory  = settings.localZipProjectRepo.resolveDirectory(StringTools.replace(StringTools.replace(url.substr(7), "/", "_"), ":", "_"));
		
		// check if exist locally
		if (!localRepoProjectDirectory.exists)
		{
			
			var zipFileName : String = StringTools.replace(url.substr(7), "/", "_");
			zipFileName = StringTools.replace(zipFileName, ":", "_");
			var tmpZipFile = settings.localTmp.resolveFile(zipFileName);
			//if not get it from the repo
			
			Show.message("Downloading " + url);
			var got : Bool = ZipExtractor.getZip(tmpZipFile.nativePath , url);
			if (!got)
			{
				Show.criticalError("cannot download " + url);
			}
				
			ZipExtractor.extract(tmpZipFile.nativePath, localRepoProjectDirectory.nativePath);
		}
		
		
		var projectFile : File = null;
		if (path == "" || path == null)
		{
			projectFile = localRepoProjectDirectory.resolveFile(settings.yogaFileName);
		}
		else
		{
			if(path.charAt(0)== "\\" && path.charAt(path.length -1) == "\\")
			{
				path = path.substr(1, path.length - 2);
				var files : Array<File> = localRepoProjectDirectory.getRecursiveDirectoryListing(new EReg(path, ""));
				for (file in files)
				{
					if (!file.isDirectory)
					{
						projectFile = file;
						break;
					}
				}
			}
			
			if (projectFile == null)
			{
				projectFile = localRepoProjectDirectory.resolveDirectory(path);
			}
		}
		
		
		if (!projectFile.exists)
		{
			Show.criticalError("the project file '" + projectFile.nativePath + "' does not exist");
		}
		
		
		var dependencyProject : YogaProject = new YogaProject(projectFile.readString());
		
		for (sourceFolder in dependencyProject.sources)
		{
			
			var sourceDependency : SourceDependency = new SourceDependency(localRepoProjectDirectory.resolveDirectory(sourceFolder).nativePath, dependencyProject.id + '_' + sourceFolder);
			if (!dependencySet.contains(sourceDependency))
			{
				dependencySet.add(sourceDependency);
			
				dependencyProject.join(settings, dependencySet);
			}
		}
	}
	
	public function getUniqueId():String 
	{
		return "ZipProjectDependency_" + url;
	}
	
}