#!/bin/bash 
rm package.zip
mkdir package
cp src/haxelib.xml package/haxelib.xml
cp target/Yoga.n package/run.n
cp src/yoga.sh package/yoga.sh
cp src/yoga.bat package/yoga.bat
cp src/TestMain.hx package/TestMain.hx
cd package
zip  ../package.zip haxelib.xml run.n yoga.sh yoga.bat TestMain.hx
haxelib test ../package.zip
