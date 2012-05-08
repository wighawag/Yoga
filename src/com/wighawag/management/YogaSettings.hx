package com.wighawag.management;
import massive.neko.io.File;


class YogaSettings 
{

	public var localRepo : File;
	public var localTmp : File;
	public var localZipSourceRepo : File;
	public var localZipProjectRepo : File;
	public var localRepoProjectRepo : File;
	
	public var repoList : Array<String>;
	public var yogaFileName : String;
	public var targetDirectory : String;
	
	public function new(settingsDirectory : File) 
	{
		yogaFileName = 'yoga.xml';
		targetDirectory = 'target';
		repoList = new Array<String>();
		
		var settingsFile : File = settingsDirectory.resolveFile('settings.xml');
		
		if (settingsFile.exists)
		{
			var settingsXml : Xml = Xml.parse(settingsFile.readString());
			
			var settingsTag : Xml = settingsXml.elementsNamed("settings").next();
			if (settingsTag == null)
			{
				Sys.println("no valid settings");
				Sys.exit(1);
			}
			var repositoriesTag : Xml = settingsTag.elementsNamed("repositories").next();
			if (repositoriesTag != null)
			{
				for (repository in repositoriesTag.elementsNamed("repository"))
				{
					Sys.println("add repo " + repository.get("url"));
					repoList.push(repository.get("url"));
				}
			}
		}
		else
		{
			Sys.println("no config provided");
		}
		
		
		localRepo = settingsDirectory.resolveDirectory('repository', true);
		
		localZipSourceRepo = localRepo.resolveDirectory('zipsource', true);
		localZipProjectRepo = localRepo.resolveDirectory('zipproject', true);
		localRepoProjectRepo = localRepo.resolveDirectory('repoproject', true);
		
		localTmp = settingsDirectory.resolveDirectory('tmp', true);
	}
	
}