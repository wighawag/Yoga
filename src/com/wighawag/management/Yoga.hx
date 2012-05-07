package com.wighawag.management;
import com.wighawag.management.command.ConfigCommand;
import massive.neko.cmd.CommandLineRunner;

class Yoga extends CommandLineRunner {
	
	static public function main():Yoga { return new Yoga(); }
	
	public function new()
	{
		super();

		mapCommand(ConfigCommand, "", ["config"], "Creates the config file used to execute the project (hxml, nmml,...)");
		
		run();
	}
	
	override function printHeader():Void
	{
		// TODO :  macro for copyright
		print("Yoga - Copyright " + Date.now().getFullYear() + " Wighawag");	
	}
	
}
