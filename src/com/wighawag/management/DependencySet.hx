package com.wighawag.management;
import com.wighawag.util.Show;

class DependencySet 
{

	private var dependencies : Array<Dependency>;
	private var dictionary : Hash<Dependency>;
	
	public function new() 
	{
		dependencies = new Array<Dependency>();
		dictionary = new Hash<Dependency>();
	}
	
	public function contains(dependency : Dependency) : Bool
	{
		return dictionary.exists(dependency.getUniqueId());
	}
	
	public function add(dependency : Dependency) : Void
	{
		if (dictionary.exists(dependency.getUniqueId()))
		{
			var registeredDependency : Dependency = dictionary.get(dependency.getUniqueId());
			//Sys.println("dependency already grabbed");
			
			var type = Type.getClass(dependency);
			if (type == HaxelibDependency)
			{
				var registeredHaxelibDependency : HaxelibDependency = cast(registeredDependency, HaxelibDependency);
				// TODO : deal with version comp:
				if (registeredHaxelibDependency.version != cast(dependency, HaxelibDependency).version)
				{
					Show.criticalError("dependencies on different versions (" + registeredHaxelibDependency.version + " vs " + cast(dependency, HaxelibDependency).version + ")");
				}
				
			}
			else if (type == RepositoryDependency) // TODO NEVER reach there si nce RepositoryDependency get transformed into SourceDependency
			{
				var registeredRepoDependency : RepositoryDependency = cast(registeredDependency, RepositoryDependency);
				// TODO : deal with version comp:
				if (registeredRepoDependency.version != cast(dependency, RepositoryDependency).version)
				{
                    Show.criticalError("dependencies on different versions (" + registeredRepoDependency.version + " vs " + cast(dependency, RepositoryDependency).version + ")");
				}
			}else if (type == SourceDependency)
				{
					var registeredSourceDependency : SourceDependency = cast(registeredDependency, SourceDependency);
					// TODO : deal with version comp:
					if (registeredSourceDependency.projectVersion != null && registeredSourceDependency.projectVersion != cast(dependency, SourceDependency).projectVersion)
					{
						Show.criticalError("dependencies on different versions for " + registeredSourceDependency.projectId + " (" + registeredSourceDependency.projectVersion + " vs " + cast(dependency, SourceDependency).projectVersion + ")");
					}
				}
			
		}
		else
		{
			dictionary.set(dependency.getUniqueId(), dependency);
			dependencies.push(dependency);
		}
		
	}
	
	public function getDependencies() : Array<Dependency>
	{
		return dependencies;
	}
	
	public function clone() : DependencySet
	{
		var newDependencySet : DependencySet = new DependencySet();
		for (dependency in dependencies)
		{
			newDependencySet.add(dependency);
		}
		return newDependencySet;
	}
	
}