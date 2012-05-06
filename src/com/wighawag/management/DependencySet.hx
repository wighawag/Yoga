package com.wighawag.management;


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
			Sys.println("dependency already grabbed");
			/* TODO :
			var type = Type.getClass(dependency);
			if (type == HaxelibDependency)
			{
				var registeredHaxelibDependency : HaxelibDependency = cast(registeredDependency, HaxelibDependency);
				// TODO : deal with version comp:
				if (registeredHaxelibDependency.version < cast(dependency, HaxelibDependency).version)
				{
					
				}
				
			}
			else if (type == RepositoryDependency)
			{
				var registeredRepoDependency : RepositoryDependency = cast(registeredDependency, RepositoryDependency);
				// TODO : deal with version comp:
				if (registeredRepoDependency.version < cast(dependency, HaxelibDependency).version)
				{
					
				}
			}
			*/
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
	
}