package com.wighawag.management.command;
import com.wighawag.management.DependencySet;


class DependencyYogaCommand extends BaseYogaProjectCommand
{
	private var dependencySet : DependencySet;
	
	public function new() 
	{
		super();
	}
	
	override public function execute():Void
	{
		super.execute();
		
		dependencySet = new DependencySet();
		currentProject.join(yogaSettings, dependencySet, 1);
	}
}