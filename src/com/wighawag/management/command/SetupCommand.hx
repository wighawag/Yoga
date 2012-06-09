package com.wighawag.management.command;
import massive.neko.cmd.Command;
import massive.neko.io.FileSys;
import sys.io.File;

class SetupCommand extends Command{
	
	public function new () {
		super();		
	}		

	override function execute():Void 
	{
		super.execute();
		
		if (FileSys.isWindows) {
			
			var haxePath = Sys.getEnv ("HAXEPATH");
			
			if (haxePath == null || haxePath == "") {
				
				haxePath = "C:\\Motion-Twin\\haxe\\";
				
			}
			
			File.copy (console.originalDir.nativePath + "\\yoga.bat", haxePath + "\\yoga.bat");
			
		} else {
			
			File.copy (console.originalDir.nativePath + "/yoga.sh", "/usr/lib/haxe/yoga");
			Sys.command ("chmod", [ "755", "/usr/lib/haxe/yoga" ]);
			
			Sys.command("rm -rf /usr/bin/yoga");
			Sys.command("ln -s /usr/lib/haxe/yoga /usr/bin/yoga");	
		}
	}
	
}
