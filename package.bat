@echo off
copy src\haxelib.xml package\haxelib.xml
copy test.hxml.template package\test.hxml.template
cd package
"C:\Program Files\7-Zip\7z.exe" a ..\package.zip haxelib.xml run.n test.hxml.template
haxelib test ..\package.zip
