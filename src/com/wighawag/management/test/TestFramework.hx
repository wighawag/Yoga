package com.wighawag.management.test;

import massive.neko.cmd.Console;
import com.wighawag.management.YogaProject;
import com.wighawag.management.DependencySet;
import com.wighawag.management.YogaSettings;

interface TestFramework {
    function execute(console : Console, currentProject : YogaProject, dependencySet : DependencySet, yogaSettings : YogaSettings) : Void;
}
