package com.wighawag.management;
import com.wighawag.util.Show;
import com.wighawag.management.command.DeployPrepareCommand;
import com.wighawag.management.command.ConfigCommand;
import com.wighawag.management.command.DeployPrepareCommand;
import com.wighawag.management.command.DeployPerformCommand;
import com.wighawag.management.command.InstallCommand;
import com.wighawag.management.command.TestCommand;
import com.wighawag.management.command.SetupSystemCommand;
import com.wighawag.management.command.SetupAddRepoCommand;
import com.wighawag.util.DateMacro;
import massive.neko.cmd.CommandLineRunner;

class Yoga extends CommandLineRunner {
	
	static public function main():Yoga { return new Yoga(); }
	
	public function new()
	{
		super();

		mapCommand(ConfigCommand, "", ["config", "c"], "Creates the config file used to execute the project (hxml, nmml,...)");
		mapCommand(InstallCommand, "install", ["i"], "install the project into local repo");
		mapCommand(TestCommand, "test", ["t"], "test the project");
        mapCommand(DeployPrepareCommand, "deploy:prepare", ["p"], "prepare to deploy the project into a repo");
        mapCommand(DeployPerformCommand, "deploy:perform", ["d"], "actual deploy the project into a repo");

        mapCommand(SetupSystemCommand, "setup:system", ["s"], "setup yoga so that it can be called with 'yoga' instead of 'haxelib run yoga' the project");
        mapCommand(SetupAddRepoCommand, "setup:addRepo", ["a"], "add a repository from which to grap dependencies");

		run();
	}
	
	override function printHeader():Void
	{
		print("Yoga - Copyright " + DateMacro.getFullYear() + " Wighawag");	
	}
	
}
