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
			
			var zipFileName : String = StringTools.replace(url.substr(7),"/", "_");
			var tmpZipPath = settings.localTmpPath + SystemUtil.slash() + zipFileName;
			//if not get it from the repo
			var got : Bool = ZipExtractor.getZip(tmpZipPath , url);
			if (!got)
			{
				Sys.println("cannot download " + url);
				Sys.exit(1);
			}
				
			Sys.println("zip downloaded :  " + tmpZipPath);
			
			//then unzip 
			Sys.println("unzipping " + tmpZipPath + " to " + localRepoProjectPath);
			ZipExtractor.extract(tmpZipPath, localRepoProjectPath);
		}
		
		var finalPath : String = localRepoProjectPath + SystemUtil.slash() + StringTools.replace(srcPath, "/", SystemUtil.slash());
		if (!FileSystem.exists(finalPath))
		{
			var foundAlternative : Bool = false;
			if (srcPath.substr(0,2) == "*/") // support '*/' only when src folder is one level deep
			{
				var files : Array<String> = FileSystem.readDirectory(localRepoProjectPath);
				for (file in files)
				{
					if (FileSystem.isDirectory(localRepoProjectPath + SystemUtil.slash() + file))
					{
						var subFiles : Array<String> = FileSystem.readDirectory(localRepoProjectPath + SystemUtil.slash() + file);
						for (subfile in subFiles)
						{
							if (subfile == srcPath.substr(2))
							{
								finalPath = localRepoProjectPath + SystemUtil.slash() + file + SystemUtil.slash() + subfile;
								foundAlternative = true;
								break;
							}
						}
					}
					if (foundAlternative)
					{
						break;
					}
				}
			}
			if (!foundAlternative)
			{
				Sys.println("the srcPath '" + finalPath + "' does not exist");
				Sys.exit(1);
			}
		}
		
		var sourceDependency : SourceDependency = new SourceDependency(finalPath, getUniqueId());
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