//%attributes = {"invisible":true,"preemptive":"capable"}
C_TEXT:C284($1;$0;$param)

If (Count parameters:C259#0)
	
	$param:=$1
	
	C_LONGINT:C283($platform;$i;$len)
	_O_PLATFORM PROPERTIES:C365($platform)
	
	If (Is Windows:C1573)
		
		  //argument escape for cmd.exe; other commands (curl, ruby, etc.) may be incompatible
		
		$shoudQuote:=False:C215
		
		$metacharacters:="&|<>()%^\" "
		
		$len:=Length:C16($metacharacters)
		
		For ($i;1;$len)
			$metacharacter:=Substring:C12($metacharacters;$i;1)
			$shoudQuote:=$shoudQuote | (Position:C15($metacharacter;$param;*)#0)
			If ($shoudQuote)
				$i:=$len
			End if 
		End for 
		
		If ($shoudQuote)
			If (Substring:C12($param;Length:C16($param))="\\")
				$param:="\""+$param+"\\\""
			Else 
				$param:="\""+$param+"\""
			End if 
		End if 
		
	Else 
		
		$metacharacters:="\\!\"#$%&'()=~|<>?;*`[] "
		
		For ($i;1;Length:C16($metacharacters))
			$metacharacter:=Substring:C12($metacharacters;$i;1)
			$param:=Replace string:C233($param;$metacharacter;"\\"+$metacharacter;*)
		End for 
		
	End if 
	
End if 

$0:=$param