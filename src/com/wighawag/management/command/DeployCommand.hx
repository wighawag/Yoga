package com.wighawag.management.command;
import com.wighawag.format.zip.ZipExtractor;
import haxe.Http;
import massive.neko.io.File;
import massive.neko.util.ZipUtil;
import com.wighawag.util.Show;

class DeployCommand extends InstallCommand
{

	public function new() 
	{
		super();
	}
	
	override function execute() : Void
	{
		super.execute();
		
		if (yogaSettings.deployServer == null)
		{
			Show.criticalError("no deploy server specified in settings.xml");
		}
		
		var projectFileName : String = currentProject.id + "_" + currentProject.version;
		
		var zipFile : File = yogaSettings.localTmp.resolveFile("deploying/" + projectFileName + ".zip", true);
		
		var repoFolder : File = yogaSettings.localRepoProjectRepo.resolveDirectory(projectFileName); 
		
		// Did not work (addign extra empty files (same name as exisiting folder): ZipUtil.zipDirectory(zipFile,repoFolder);
		ZipExtractor.compress(repoFolder.nativePath, zipFile.nativePath);
		
		var http : Http = new Http(yogaSettings.deployServer);
		
		http.onError = function(e) {
			Show.criticalError(e); 
		};
		
		http.onData = function(msg : String):Void { 
			//Sys.println(msg); 
		};
		
		var data = sys.io.File.getBytes(zipFile.nativePath);
		http.fileTransfert("file", zipFile.fileName, new ProgressIn(new haxe.io.BytesInput(data), data.length), data.length);
		Show.message("Sending data.... ");
		http.request(true);
		
		zipFile.deleteFile();
	}
	
}

class ProgressIn extends haxe.io.Input {

	var i : haxe.io.Input;
	var pos : Int;
	var tot : Int;

	public function new( i, tot ) {
		this.i = i;
		this.pos = 0;
		this.tot = tot;
	}

	public override function readByte() {
		var c = i.readByte();
		doRead(1);
		return c;
	}

	public override function readBytes(buf,pos,len) {
		var k = i.readBytes(buf,pos,len);
		doRead(k);
		return k;
	}

	function doRead( nbytes : Int ) {
		pos += nbytes;
		Sys.print( Std.int((pos * 100.0) / tot) + "%\r" );
	}

}