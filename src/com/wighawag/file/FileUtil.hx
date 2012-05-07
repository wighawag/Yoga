package com.wighawag.file;
import com.wighawag.system.SystemUtil;
import sys.FileSystem;


class FileUtil 
{

	/// from http://haxe.org/forum/thread/3395#nabble-td6226269
	public static function unlink( path : String ) : Void 
	{ 
	  if( FileSystem.exists( path ) ) 
	  { 
		if( FileSystem.isDirectory( path ) ) 
		{ 
		  for( entry in FileSystem.readDirectory( path ) ) 
		  { 
			unlink( path + "/" + entry ); 
		  } 
		  FileSystem.deleteDirectory( path ); 
		} 
		else 
		{ 
		  FileSystem.deleteFile( path ); 
		} 
	  } 
	} 
	
	
	
}