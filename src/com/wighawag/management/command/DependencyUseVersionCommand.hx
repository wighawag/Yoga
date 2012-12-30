package com.wighawag.management.command;

import com.wighawag.util.Show;

class DependencyUseVersionCommand extends BaseYogaProjectCommand{


    public function new() {
	    super();
    }

	override public function execute() : Void
	{
		super.execute();

		var depId = "";
		var depNewVersion="";
		var depType = "repository";

		if (console.args.length >= 3){
			if (console.args[1] == "haxelib"){
				depType = console.args[1];
				depId = console.args[2];
				if(console.args.length > 3){
					depNewVersion = console.args[3];
				}else{
					depNewVersion = null;
				}

			}else{
				depId = console.args[1];
				depNewVersion = console.args[2];
			}

		}else{
			Show.criticalError("need to pass either:\n haxelib <name> [<version>]\n or \n <id> <version>");
		}


		var currentProjectFile = this.console.dir.resolveFile(yogaSettings.yogaFileName);

		var content = currentProjectFile.readString();

		var xml = Xml.parse(content);

		var projectTag = xml.elementsNamed("project").next();


		var dependenciesTag = projectTag.elementsNamed("dependencies").next();
		if (dependenciesTag == null){
			Show.message("dependency "+ depType + " " + depId + " not found");
		}else{
			var dependencieTags = dependenciesTag.elements();

			var found : Bool = false;
			for (dependency in dependencieTags)
			{
				switch(dependency.nodeName)
				{
					case "haxelib" :
						var libraryName : String = dependency.get("name");
						var version : String = dependency.get("version");

						if(depType == "haxelib" && depId == libraryName){
							if(depNewVersion == null){
								dependency.remove("version");
							}else{
								dependency.set("version", depNewVersion);
							}
							found = true; break;
						}

					case "repository" :
						var repoProjectId : String = dependency.get("id");
						var repoProjectVersion : String = dependency.get("version");

						if(depType == "repository" && depId == repoProjectId){
							dependency.set("version", depNewVersion);
							found = true; break;
						}

				}
			}

			if (found){
				currentProjectFile.writeString(xml.toString(),false);
				Show.success();
			}else{
				Show.message("dependency "+ depType + " " + depId + " not found");
			}



		}

	}

}
