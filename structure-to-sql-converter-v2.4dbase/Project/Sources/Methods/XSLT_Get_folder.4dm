//%attributes = {"invisible":true,"preemptive":"capable"}
C_TEXT:C284($0; $path)

$path:=Get 4D folder:C485(Database folder:K5:14)+"XSLT"+Folder separator:K24:12

Case of 
	: (Is macOS:C1572)
		$path:=$path+"MacOS"+Folder separator:K24:12
	: (Is Windows:C1573)
		$path:=$path+"Windows64"+Folder separator:K24:12
End case 

$0:=$path