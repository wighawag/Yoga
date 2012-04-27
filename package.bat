@echo off
copy src\haxelib.xml package\haxelib.xml
cd package
"C:\Program Files\7-Zip\7z.exe" a ..\package.zip haxelib.xml run.n
haxelib test ..\package.zip
