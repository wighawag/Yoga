package com.wighawag.management.command;
import massive.neko.io.File;
import massive.neko.cmd.Command;
import com.wighawag.util.Show;
class SetupAddRepoCommand  extends Command{
    public function new () {
        super();
    }

    override function execute():Void
    {
        super.execute();

        if (console.args.length < 2){
            Show.criticalError("need to pass an url as argument");
        }
        var url = console.args[1];

        var settingsDirectory = YogaFolders.getSettingsFolder();

        var settingsFile : File = settingsDirectory.resolveFile('settings.xml');

        // TODO YogaSettigns dhold be abel to output its xml itslef
        if (settingsFile.exists)
        {
            var settingsXml : Xml = Xml.parse(settingsFile.readString());

            var settingsTag : Xml = settingsXml.elementsNamed("settings").next();
            var repositoriesTag : Xml = settingsTag.elementsNamed("repositories").next();
            if (repositoriesTag != null)
            {
                var child:Xml = Xml.parse("<repository url='" + url + "' />");
                repositoriesTag.addChild(child);
            }else{
                var child:Xml = Xml.parse("<repositories><repository url='" + url + "' /></repositories>");
                settingsTag.addChild(child);
            }

            settingsFile.writeString(settingsXml.toString(), false);
        }
        else
        {
            settingsFile.createFile("<settings><repositories><repository url='" + url + "' /></repositories></settings>");
        }

        Show.done();
    }


}
