package com.wighawag.format.zip;
import com.wighawag.file.FileUtil;
import com.wighawag.system.SystemUtil;
import haxe.io.Bytes;
import haxe.io.Path;
import neko.zip.Reader;
import neko.zip.Writer;
import sys.FileSystem;
import sys.io.File;

import com.wighawag.util.Show;

typedef FileZipEntry = {
	var fileTime : Date;
	var fileName : String;
	var data : Bytes;
}
	
class ZipExtractor 
{

	static function populateZipEntries(folder, archiveData : Array<FileZipEntry>, ?prefix : String = "") : Void
	{
		var files = FileSystem.readDirectory(folder);
		for (file in files)
		{
			var zipFileName = prefix + file;
			var filePath : String = folder + SystemUtil.slash() + file;
			
			if (FileSystem.isDirectory(filePath))
			{
				populateZipEntries(filePath, archiveData, zipFileName + "/");
			}
			else
			{
				archiveData.push( { fileTime : Date.now(), fileName : zipFileName, data : File.getBytes(filePath) } );
			}
		}
	}
	
	static public function compress(folder : String, outputZip : String) : Void
	{
		var archiveData : Array<FileZipEntry> = new Array<FileZipEntry>();
		populateZipEntries(folder, archiveData);
		
		var fout = File.write(outputZip, true);
		Writer.writeZip(fout, archiveData, -1);
		fout.close();
	}
	
	static public function extract(zipPath : String, outputFolder : String) : Void 
	{
		var slash = "/";
		if (Sys.systemName().indexOf("Win") != -1)
		{
			slash = "\\";
		}

        var zipInput = File.read(zipPath, true);
        var zipData = Reader.readZip(zipInput);
        zipInput.close();

		if (!FileSystem.exists(outputFolder))
		{
			FileSystem.createDirectory(outputFolder);
		}

		for (oneData in zipData)
		{
			var content = (oneData.compressed) ? Reader.unzip(oneData) : oneData.data;
			//Sys.println(" " + oneData.fileName + ": ");// + content);
			var filePath : String = outputFolder  + oneData.fileName;
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
				if (dirPath.lastIndexOf(SystemUtil.slash()) == dirPath.length - 1)
				{
					dirPath = dirPath.substr(0, dirPath.length - 1);
				}
				if ( !FileSystem.exists( dirPath ) ) {
					try{
                        massive.neko.io.File.createDirectoryPath(dirPath);
					}
					catch (e: Dynamic)
					{
						Show.criticalError('failed creating ' + dirPath + ' (' + e + ')');
					}
				}

				var file = File.write( filePath, true );
				file.write(content);
				file.close();
			}
			
		}
		
	}
	
	static public function getZipFromAnyRepositories(destinationFolder : String, repoList : Array<String>, repoProjectId : String, repoProjectVersion : String) : String
	{
		Show.message("attemtping to get " + repoProjectId + " : " + repoProjectVersion + " from " + repoList);
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
			}
		}
		h.onError = function(e) {
			errorHapenned = true;
		};
		//Sys.println("Downloading " + remoteZip + " to " + destinationZip);
		try{
			h.customRequest(false, tmpOut);
		}catch (e : Dynamic)
		{
			//Sys.println('error : ' + e.toString());
			if (newLocation != null)
			{
				Show.message("redirection : " + newLocation);
			}
			FileSystem.deleteFile(destinationZip);
			errorHapenned = true;
			
		}
		if (newLocation != null)
		{
			return getZip(destinationZip, newLocation);
		}
		
		//Sys.println("request done");
		return !errorHapenned;
	}
	
}