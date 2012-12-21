package com.wighawag.management;

interface Dependency 
{
	function getHxmlString() : String;
	function getNMMLString() : String;
	
	function grab(settings : YogaSettings, dependencySet : DependencySet, step : Int) : Void;
	
	function getUniqueId() : String;

	function descriptionId() : String;
}