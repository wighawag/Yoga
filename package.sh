#!/bin/bash 
mkdir package
cp src/haxelib.xml package/haxelib.xml
cp target/Yoga.n package/run.n
cd package
rm package.zip
zip  ../package.zip haxelib.xml run.n 
haxelib test ../package.zip
