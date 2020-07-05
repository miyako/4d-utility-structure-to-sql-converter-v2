//%attributes = {}
$structurePath:=Get 4D folder:C485(Current resources folder:K5:16)+"InvoicesDemo.xml"

  //convert xml to sql
C_OBJECT:C1216($result)
$params:=New object:C1471
$params.debug_sql_name:="de"  //non-ascii value not supported
$params.string_quote_mode:="4D"  //use 4D escape
$params.string_quote_mode:="DQ"  //use double quotes, backslash quoted double quotes
$params.string_quote_mode:="SQ"  //use single quotes, duplicate quoted single quotes
$params.with_replicate:=True:C214  //export ENABLE REPLICATE if applicable
$params.with_autosequence:=True:C214  //export AUTO_INCREMENT if applicable
$params.with_autogenerate:=True:C214  //export AUTO_GENERATE if applicable
$params.with_picture:=True:C214  //export field type #12 as PICTURE instead of BLOB 
$params.with_json:=True:C214  //export field type #21 as TEXT instead of BLOB 
$params.with_schema:=True:C214
$params.with_index:=True:C214

$result:=convert_structure_to_sql ($structurePath;$params)

$path:=System folder:C487(Desktop:K41:16)+"test.sql"
$file:=File:C1566($path;fk platform path:K87:2)
$file.setText($result.sql;"utf-8";Document with LF:K24:22)

OPEN URL:C673($file.platformPath;"Atom")