//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
C_TEXT:C284($1;$structure)
C_OBJECT:C1216($0;$result)

$structure:=$1
$result:=New object:C1471

If (Length:C16($structure)#0)
	
	$stylesheet:=Get 4D folder:C485(Current resources folder:K5:16)+"structure-to-sql-converter-v2.xsl"
	
	If (Test path name:C476($stylesheet)=Is a document:K24:1)
		
		$xsltFolder:=XSLT_Get_folder 
		
		C_BLOB:C604($stdInData;$stdOutData;$stdErrData)
		
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS";"true")
		
		C_TEXT:C284($command)
		C_LONGINT:C283($pid)
		
		C_OBJECT:C1216($2;$params)
		$params:=$2
		
		C_TEXT:C284($param;$stringparam)
		
		If (Not:C34(OB Is empty:C1297($params)))
			For each ($param;$params)
				
				Case of 
					: (Value type:C1509($params[$param])=Is real:K8:4)
						$stringparam:=$stringparam+" --param "+$param+" "+String:C10($params[$param];"&xml;")
					: (Value type:C1509($params[$param])=Is boolean:K8:9)
						$stringparam:=$stringparam+" --param "+$param+" "+String:C10(Num:C11($params[$param]);"true();;false()")
					Else 
						$stringValue:=String:C10($params[$param])
						If (Length:C16($stringValue)#0)
							$stringparam:=$stringparam+" --stringparam "+$param+" \""+Replace string:C233($stringValue;"\"";"\"";*)+"\""
						End if 
				End case 
			End for each 
		End if 
		
		If (Is macOS:C1572)
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY";$xsltFolder)
			
			$arguments:=$stringparam+" "+LEP_Escape (Convert path system to POSIX:C1106($stylesheet))
			$arguments:=$arguments+" "+LEP_Escape (Convert path system to POSIX:C1106($structure))
			$command:="xsltproc"+$arguments
			
		Else 
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_HIDE_CONSOLE";"true")
			
			$arguments:=$stringparam+" "+LEP_Escape ($stylesheet)
			$command:=LEP_Escape ($xsltFolder)+"xsltproc.exe"
			$arguments:=$arguments+" "+LEP_Escape ($structure)
			$command:=$command+$arguments
			
		End if 
		
		LAUNCH EXTERNAL PROCESS:C811($command;$stdInData;$stdOutData;$stdErrData;$pid)
		
		$result.stdErr:=Convert to text:C1012($stdErrData;"utf-8")
		$result.sql:=Convert to text:C1012($stdOutData;"utf-8")
		
	End if 
	
End if 

$0:=$result