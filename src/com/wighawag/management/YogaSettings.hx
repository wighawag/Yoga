package com.wighawag.management;
import massive.neko.io.File;
import com.wighawag.util.Show;

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
	public var deployServer : String;
	
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
				Show.criticalError("no valid settings");
			}
			var repositoriesTag : Xml = settingsTag.elementsNamed("repositories").next();
			if (repositoriesTag != null)
			{
				for (repository in repositoriesTag.elementsNamed("repository"))
				{
					repoList.push(repository.get("url"));
				}
			}
			
			var deployTag : Xml = settingsTag.elementsNamed("deploy-server").next();
			if (deployTag != null)
			{
				//Sys.println("deploy address : " + deployTag.get("url"));
				deployServer = deployTag.get("url");
			}
			else
			{
				deployServer = null;
			}
		}
		else
		{
			Show.message("no settings.xml found");
		}
		
		
		localRepo = settingsDirectory.resolveDirectory('repository', true);
		
		localZipSourceRepo = localRepo.resolveDirectory('zipsource', true);
		localZipProjectRepo = localRepo.resolveDirectory('zipproject', true);
		localRepoProjectRepo = localRepo.resolveDirectory('repoproject', true);
		
		localTmp = settingsDirectory.resolveDirectory('tmp', true);
	}
	
}