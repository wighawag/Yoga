@echo off
copy src\haxelib.xml package\haxelib.xml
copy src\yoga.sh package\yoga.sh
copy src\yoga.bat package\yoga.bat
cd package
"C:\Program Files\7-Zip\7z.exe" a ..\package.zip haxelib.xml run.n yoga.bat yoga.sh 
haxelib test ..\package.zip
