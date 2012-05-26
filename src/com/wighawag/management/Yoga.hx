package com.wighawag.management;
import com.wighawag.management.command.ConfigCommand;
import com.wighawag.management.command.DeployCommand;
import com.wighawag.management.command.InstallCommand;
import com.wighawag.management.command.TestCommand;
import com.wighawag.util.DateMacro;
import massive.neko.cmd.CommandLineRunner;

class Yoga extends CommandLineRunner {
	
	static public function main():Yoga { return new Yoga(); }
	
	public function new()
	{
		super();

		mapCommand(ConfigCommand, "", ["config", "c"], "Creates the config file used to execute the project (hxml, nmml,...)");
		mapCommand(InstallCommand, "install", ["i"], "install the project into local repo");
		mapCommand(DeployCommand, "deploy", ["d"], "deploy the project into a repo");
		mapCommand(TestCommand, "test", ["t"], "test the project");
		
		run();
	}
	
	override function printHeader():Void
	{
		print("Yoga - Copyright " + DateMacro.getFullYear() + " Wighawag");	
	}
	
}
