package com.wighawag.management;

interface Dependency 
{
	function getHxmlString() : String;
	function getNMMLString() : String;
	
	function grab(settings : YogaSettings, dependencySet : DependencySet) : Void;
	
	function getUniqueId() : String;
}