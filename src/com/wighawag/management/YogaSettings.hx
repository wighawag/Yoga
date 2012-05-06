package com.wighawag.management;


class YogaSettings 
{

	public var localRepoPath : String;
	public var localTmpPath : String;
	public var repoList : Array<String>;
	public var yogaFileName : String;
	
	public function new() 
	{
		repoList = new Array<String>();
	}
	
}