package com.wighawag.management;
import com.wighawag.management.command.ConfigCommand;
import com.wighawag.util.DateMacro;
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
		print("Yoga - Copyright " + DateMacro.getFullYear() + " Wighawag");	
	}
	
}
