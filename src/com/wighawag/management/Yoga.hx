package com.wighawag.management;
import com.wighawag.management.command.ConfigCommand;
import com.wighawag.management.command.InstallCommand;
import com.wighawag.util.DateMacro;
import massive.neko.cmd.CommandLineRunner;

class Yoga extends CommandLineRunner {
	
	static public function main():Yoga { return new Yoga(); }
	
	public function new()
	{
		super();

		mapCommand(ConfigCommand, "", ["config", "c"], "Creates the config file used to execute the project (hxml, nmml,...)");
		mapCommand(InstallCommand, "install", ["i"], "install the project into local repo");
		
		run();
	}
	
	override function printHeader():Void
	{
		print("Yoga - Copyright " + DateMacro.getFullYear() + " Wighawag");	
	}
	
}
