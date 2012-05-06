package com.wighawag.format.zip;
import com.wighawag.file.FileUtil;
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
		var tmpZip :String = null;
		var got : Bool = false;
		do
		{
			if (repoQueue.length > 0)
			{
				var repoUrl : String = repoQueue.shift();
				var zipFileName : String = repoProjectId + '_' + repoProjectVersion + '.zip';
				tmpZip = destinationFolder + SystemUtil.slash() + zipFileName;
				got = getZip(tmpZip, repoUrl + "/" + zipFileName);
			}
		}while (repoQueue.length > 0 &&  !got);
		
		return tmpZip;
	}
	
	static public function getZip(destinationZip : String, remoteZip : String) : Bool
	{
		
		var tmpOut = sys.io.File.write(destinationZip,true);
		
		var h = new haxe.Http(remoteZip);
		var errorHapenned : Bool = false;
		var newLocation : String = null;
		h.onStatus = function (status : Int) : Void {
			if (status == 302)
			{
				newLocation = h.responseHeaders.get("Location");
				Sys.println("redirect to " +  newLocation);
			}
		}
		h.onError = function(e) {
			errorHapenned = true;
		};
		Sys.println("Downloading " + remoteZip + " to " + destinationZip);
		try{
			h.customRequest(false, tmpOut);
		}catch (e : Dynamic)
		{
			Sys.println('error : ' + e.toString());
			if (newLocation != null)
			{
				Sys.println("redirection");
			}
			FileSystem.deleteFile(destinationZip);
			errorHapenned = true;
			
		}
		if (newLocation != null)
		{
			return getZip(destinationZip, newLocation);
		}
		
		Sys.println("request done");
		return !errorHapenned;
	}
	
}