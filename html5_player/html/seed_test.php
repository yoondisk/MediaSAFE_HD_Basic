<?php
require_once ('seed/KISA_SEED_CBC.php');

/*추가적인 문자열 함수*/
/*
    ENCRYPT encrypt($bszIV, $bszUser_key, $str)
	  Orgin string => Timestamp|String => String to hex => SEED ENCRYPT => Hex to String => Base64_encode => Encrypt String

	DECRYPT DECRYPT decrypt($bszIV, $bszUser_key, $str)
	  Encrypt String => Base64_decode => String to hex  => SEED DECRYPT => Hex to String => TimeStamp Remove => Decrypt String
*/
require_once ('seed/SEED_FUNCTION.php');


/*
 암화화 key,iv 선언.
*/
$g_bszUser_key = "88,E3,4F,8F,08,17,79,F1,E9,F3,94,37,0A,D4,05,89";
$g_bszIV = "26,8D,66,A7,35,A8,1A,81,6F,BA,D9,FA,36,16,25,01";

/*
	360화질 : http://openos.yoondisk.co.kr/test1_360.mp4
	480화질 : http://openos.yoondisk.co.kr/test1_480.mp4
	720화질 : http://openos.yoondisk.co.kr/test1_720.mp4
	1080 화질 : http://openos.yoondisk.co.kr/test1_1080.mp4
*/
$url_org="http://openos.yoondisk.co.kr/test1_1080.mp4";

$encstring = encrypt($g_bszIV, $g_bszUser_key, $url_org);
	 
$decstring = decrypt($g_bszIV, $g_bszUser_key, $encstring);


?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CBC] </title>
</head>
<body>
<center>
<h1>[YoonDisk] [SEED-CBC] PHP URL 암호화 데모</h1>
<p><font color=red>*. 동영상 URL 암호화 처리 [새로고침시 암호화된 $encstring 는 계속 값이 변함]</font>
<p>1. <b>$url_org</b> => <?=$url_org?>
<p>2. $encstring => <b><?=$encstring?></b>
<p>3. $decstring => <?=$decstring?>
</center>
</body>
</html>