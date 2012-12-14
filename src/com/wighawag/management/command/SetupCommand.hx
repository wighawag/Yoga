package com.wighawag.management.command;
import massive.neko.cmd.Command;
import massive.neko.io.FileSys;
import sys.io.File;
import com.wighawag.util.Show;
class SetupCommand extends Command{
	
	public function new () {
		super();		
	}		

	override function execute():Void 
	{
		super.execute();

        var haxePathEnvironementVariableDefined : Bool = false;
        var haxePath = Sys.getEnv ("HAXEPATH");
        if (haxePath != null){
            haxePathEnvironementVariableDefined = true;
        }

		if (FileSys.isWindows) {
			if (haxePath == null || haxePath == "") {
				haxePath = "C:\\Motion-Twin\\haxe\\";
			}
            checkHaxePathExistence(haxePath, haxePathEnvironementVariableDefined);
			File.copy (console.originalDir.nativePath + "\\yoga.bat", haxePath + "yoga.bat");

		} else {
            if (haxePath == null || haxePath == "") {
                haxePath = "/usr/lib/haxe";
            }
            checkHaxePathExistence(haxePath, haxePathEnvironementVariableDefined);

			File.copy (console.originalDir.nativePath + "/yoga.sh", haxePath);
			Sys.command ("chmod", [ "755", haxePath + "/yoga" ]);
			
			Sys.command("rm -rf /usr/bin/yoga");
			Sys.command("ln -s " + haxePath +"/yoga /usr/bin/yoga");
		}
	}

    private function checkHaxePathExistence(haxePath : String, haxePathEnvironementVariableDefined : Bool) : Void{
        if(!FileSys.exists(haxePath)){
            var message = "Haxe Path " + haxePath + " does not exist";
            if (!haxePathEnvironementVariableDefined){
                message+="\n please define HAXEPATH environement variable to point to where Haxe is installed on your system";
            }else{
                message+="\n please check your HAXEPATH environement variable and where Haxe is installed on your system";
            }
            Show.criticalError(message);
        }
    }
	
}
