#!/bin/bash 
mkdir package
cp src/haxelib.xml package/haxelib.xml
cp target/Yoga.n package/run.n
cp src/yoga.sh package/yoga.sh
cp src/yoga.bat package/yoga.bat
cd package
rm package.zip
zip  ../package.zip haxelib.xml run.n yoga.sh yoga.bat 
haxelib test ../package.zip
