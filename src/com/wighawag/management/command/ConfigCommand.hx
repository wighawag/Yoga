package com.wighawag.management.command;
import massive.neko.io.File;

class ConfigCommand extends DependencyYogaCommand
{

	public function new() 
	{
		super();
	}
	
	override function execute() : Void
	{
		var targetDirectory = console.dir.resolveDirectory('target');
		targetDirectory.deleteDirectory(true);
		
		super.execute();
		
		targetDirectory = console.dir.resolveDirectory('target', true);
		
		for (target in currentProject.targets)
		{
			Sys.println("target : " + target.name + " (" + target.template + " -> " + target.output + ")");
			var templateFile = console.dir.resolveFile(target.template);
			if (!templateFile.exists)
			{
				Sys.println("template file " + templateFile.nativePath +" does not exists");
				Sys.exit(1);
			}
			
			var outputFile = console.dir.resolveFile(target.output, true);

			if (target.name == "nme")
			{
				var nmml : Xml = Xml.parse(templateFile.readString());
				var nmmlProjectTag : Xml = nmml.elementsNamed("project").next();
				if (nmmlProjectTag == null)
				{
					Sys.println("not a valid nmml template, missing project element");
					Sys.exit(1);
				}
				
				for (nmmlSource in nmmlProjectTag.elementsNamed("source"))
				{
					nmmlProjectTag.removeChild(nmmlSource);
				}
				
				for (nmmlHaxelib in nmmlProjectTag.elementsNamed("haxelib"))
				{
					nmmlProjectTag.removeChild(nmmlHaxelib);
				}
				
				var nmeDependency : Bool = false;
				for (dependency in dependencySet.getDependencies())
				{
					if (Type.getClass(dependency) == HaxelibDependency)
					{
						if (cast(dependency, HaxelibDependency).name == "nme")
						{
							nmeDependency = true;
						}
					}
					nmmlProjectTag.addChild(Xml.parse(dependency.getNMMLString()));
				}
				if (!nmeDependency)
				{
					nmmlProjectTag.addChild(Xml.parse(new HaxelibDependency("nme").getNMMLString()));
				}
				
				outputFile.writeString(nmml.toString());
			}
			else
			{
				var outputHandle = sys.io.File.write(outputFile.nativePath, false);
				outputHandle.writeString(templateFile.readString());
				outputHandle.writeString("-" + target.name + " " + targetDirectory.resolveFile(currentProject.shortName + "_" + currentProject.version + "." + target.name).nativePath + "\n");
				outputHandle.writeString("-main " + currentProject.mainClass + "\n");
				for (dependency in dependencySet.getDependencies())
				{
					outputHandle.writeString(dependency.getHxmlString() + "\n");
				}
				outputHandle.flush();
				outputHandle.close();
			}
		}
		
		
	}
	
}