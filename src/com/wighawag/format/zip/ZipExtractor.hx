package com.wighawag.format.zip;
import com.wighawag.system.SystemUtil;
import haxe.io.Path;
import neko.zip.Reader;
import sys.FileSystem;
import sys.io.File;


class ZipExtractor 
{

	static public function extract(zipPath : String, outputFolder : String) : Void 
	{
		var slash = "/";
		if (Sys.systemName().indexOf("Win") != -1)
		{
			slash = "\\";
		}
		
		if (!FileSystem.exists(outputFolder))
		{
			FileSystem.createDirectory(outputFolder);
		}
		var zipInput = File.read(zipPath, true);
		var zipData = Reader.readZip(zipInput);
		zipInput.close();
		for (oneData in zipData)
		{
			var content = (oneData.compressed) ? Reader.unzip(oneData) : oneData.data;
			//Sys.println(" " + oneData.fileName + ": ");// + content);
			var filePath : String = outputFolder + slash + oneData.fileName;
			if (filePath.charAt(filePath.length - 1) == "/")
			{
				if (!FileSystem.exists(filePath))
				{
					FileSystem.createDirectory(filePath);
				}
			}
			else
			{
				
				var dirPath = Path.directory( filePath );
				if ( !FileSystem.exists( dirPath ) ) {
					FileSystem.createDirectory(dirPath);
				}

				var file = File.write( filePath, true );
				file.write(content);
				file.close();
			}
			
		}
		
	}
	
	static public function getZipFromAnyRepositories(destinationFolder : String, repoList : Array<String>, repoProjectId : String, repoProjectVersion : String) : String
	{
		Sys.println("attemtping to get " + repoProjectId + " : " + repoProjectVersion + " from " + repoList);
		var repoQueue : Array<String> = repoList.copy();
		var zipPath :String = null;
		do
		{
			if (repoQueue.length > 0)
			{
				var repoUrl : String = repoQueue.shift();
				zipPath = getZip(destinationFolder, repoUrl + "/" + repoProjectId + "_" + repoProjectVersion + ".zip");
			}
		}while (repoQueue.length > 0 && zipPath == null);
		
		return zipPath;
	}
	
	static public function getZip(destinationFolder : String, remoteZip : String) : String
	{
		var zipFileName : String = remoteZip.substr(remoteZip.lastIndexOf("/") + 1);
		var tmpZip = destinationFolder + SystemUtil.slash() + zipFileName;
		var tmpOut = sys.io.File.write(tmpZip,true);
		
		var h = new haxe.Http(remoteZip);
		var errorHapenned : Bool = false;
		h.onError = function(e) {
			errorHapenned = true;
		};
		Sys.println("Downloading "+remoteZip+" to " + tmpZip);
		h.customRequest(false, tmpOut);
		if (errorHapenned)
		{
			return null;
		}
		return tmpZip;
	}
	
}