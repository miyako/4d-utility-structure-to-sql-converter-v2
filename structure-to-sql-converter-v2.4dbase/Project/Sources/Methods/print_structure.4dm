//%attributes = {"invisible":true,"shared":true,"preemptive":"incapable"}
C_TEXT:C284($1;$structurePath)
C_OBJECT:C1216($0;$result)

$structurePath:=$1

  //convert xml to svg

$result:=convert_structure_to_sql ($structurePath)

C_PICTURE:C286($svg)
$svg:=$result.svg

C_REAL:C285($imgWidth;$imgHeight)
$imgWidth:=$result.width
$imgHeight:=$result.height

C_REAL:C285($width;$height)
GET PRINT OPTION:C734(Paper option:K47:1;$width;$height)
SET PRINTABLE MARGIN:C710(0;0;0;0)

C_OBJECT:C1216($form)

$form:=New object:C1471(\
"destination";"detailScreen";\
"rightMargin";0;\
"bottomMargin";0;\
"markerHeader";0;\
"markerBody";0;\
"markerBreak";0;\
"markerFooter";0;"events";New collection:C1472("onLoad";"onUnload");\
"pages";New collection:C1472(Null:C1517;New object:C1471("objects";New object:C1471)))

$form.pages[1].objects.img:=New object:C1471(\
"type";"input";\
"top";0;\
"left";0;\
"width";$width;\
"height";$height;\
"dataSourceTypeHint";"picture";\
"focusable";False:C215;\
"enterable";False:C215;\
"contextMenu";"none";\
"dragging";"none")

OPEN PRINTING JOB:C995

FORM LOAD:C1103($form)

$img:=OBJECT Get pointer:C1124(Object named:K67:5;"img")

$pages_h:=($imgWidth\$width)+Num:C11(Bool:C1537($imgWidth%$width))
$pages_v:=($imgHeight\$height)+Num:C11(Bool:C1537($imgHeight%$height))
$offset_x:=0
$offset_y:=0

For ($h;1;$pages_h)
	
	$offset_y:=0
	
	For ($v;1;$pages_v)
		
		TRANSFORM PICTURE:C988($svg;Reset:K61:1)
		TRANSFORM PICTURE:C988($svg;Translate:K61:3;$offset_x;$offset_y)
		
		$img->:=$svg
		
		$printed:=Print object:C1095(*;"img")
		
		If (Not:C34(($h=$pages_h) & ($v=$pages_v)))
			PAGE BREAK:C6
		End if 
		
		$offset_y:=$offset_y-$height
		
	End for 
	
	$offset_x:=$offset_x-$width
	
End for 

FORM UNLOAD:C1299

CLOSE PRINTING JOB:C996

$0:=$result