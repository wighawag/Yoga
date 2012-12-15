package com.wighawag.management.command;
import com.wighawag.format.zip.ZipExtractor;
import haxe.Http;
import massive.neko.io.File;
import massive.neko.util.ZipUtil;
import com.wighawag.util.Show;
import semver.SemVer;
class DeployPerformCommand extends BaseYogaProjectCommand
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

        if(currentProject.isSnapshot()){
            Show.criticalError("cannot deploy a snapshot, please run deploy:prepare before deply:perform");
        }

        if(!currentProject.isPrepared()){
            Show.criticalError("cannot deploy before deploy:prepare has been executed");
        }


        Sys.println("Have you commited and tagged your folder ? y/N");
        var response = Sys.stdin().readLine();
        if (response != "y" && response != "yes" && response != "Y" && response != "YES" && response != "Yes"){
            Show.criticalError("please commit and tag your project first");
        }

        var projectFileName : String = currentProject.id + "_" + currentProject.version;



        var tmpDir : File = yogaSettings.localTmp.resolveDirectory("deploying/" + projectFileName, true);
        YogaFolders.cleanCopy(yogaSettings, currentProject, console.dir, tmpDir);

        var zipFile : File = yogaSettings.localTmp.resolveFile("deploying/" + projectFileName + ".zip", true);

        // Did not work : ZipUtil.zipDirectory(zipFile,repoFolder);  (it was adding extra empty files (same name as existing folder)
        ZipExtractor.compress(tmpDir.nativePath, zipFile.nativePath);


        var username = com.wighawag.utils.ConsoleInput.ask("username");
        var password = com.wighawag.utils.ConsoleInput.ask("password", true);


        var gotError : String = null;
        var requestStatus : Int = 0;

        var http : Http;
        if (username == ""){
            http = new Http(yogaSettings.deployServer);
        }else{
            http = new com.wighawag.appengine.AppEngineLoginHttp(yogaSettings.deployServer, username, password);
        }

        http.onError = function(e) {
            gotError = e;
        };
        http.onStatus = function(status : Int) {
            requestStatus = status;
            switch(status){
                case 409: Sys.println("project with same id and version already present");
                case 404: Sys.println("Wrong url");
                case 400: Sys.println("Wrong request");
                case 200: Sys.println("Success : Project Uploaded");
            }
        };
        http.onData = function(msg : String):Void {
            //
        };
        var data = sys.io.File.getBytes(zipFile.nativePath);
        http.fileTransfert("file", zipFile.fileName, new ProgressIn(new haxe.io.BytesInput(data), data.length), data.length);
        Show.message("Sending data.... ");
        http.request(true);

        if(gotError != null){
            Show.criticalError(gotError);
        }
        if (requestStatus != 200){
            Show.criticalError("Project not uploaded status code :" + requestStatus);
        }

        zipFile.deleteFile();
        tmpDir.deleteDirectory(true);

        setupNewVersion();
    }

    private function setupNewVersion() : Void{
        // TODO keep the xml structure
        var currentProjectFile = this.console.dir.resolveFile(yogaSettings.yogaFileName);
        var content = currentProjectFile.readString();

        var versionBegin = content.indexOf("<version>");
        var versionEnd = content.indexOf("</version>");
        var newContent = content.substr(0,versionBegin)
                        + "<version>"+incrementVersion(currentProject.version)+"-SNAPSHOT</version>"
                        + content.substr(versionEnd + 10);

        var preparedBegin = newContent.indexOf("<prepared>");
        if(newContent.charAt(preparedBegin-1) == "\t"){
            preparedBegin -= 1;
        }
        if(newContent.charAt(preparedBegin-1) == "\n"){
            preparedBegin -= 1;
        }
        var preparedEnd = newContent.indexOf("</prepared>");

        newContent = newContent.substr(0,preparedBegin)
                        + newContent.substr(preparedEnd + 11);

        currentProjectFile.writeString(newContent,false);
    }

    private function incrementVersion(version: String) : String{
        return SemVer.inc(version,Release.Patch); // Default to minor increase
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