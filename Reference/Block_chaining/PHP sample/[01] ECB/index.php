<?php
require_once ('KISA_SEED_ECB.php');

$g_bszUser_key = null;
if(isset($_POST['KEY']))
	$g_bszUser_key = $_POST['KEY'];

if($g_bszUser_key == null)
{
	$g_bszUser_key = "2b,7e,15,16,28,ae,d2,a6,ab,f7,15,88,09,cf,4f,3c";
}

function encrypt($bszUser_key, $str) {
	$planBytes = explode(",",$str);
	$keyBytes = explode(",",$bszUser_key);
	
	for($i = 0; $i < 16; $i++)
	{
		$keyBytes[$i] = hexdec($keyBytes[$i]);
	}
	for ($i = 0; $i < count($planBytes); $i++) {
		$planBytes[$i] = hexdec($planBytes[$i]);
	}

	if (count($planBytes) == 0) {
		return $str;
	}
	$ret = null;
	$bszChiperText = null;
	$pdwRoundKey = array_pad(array(),32,0);

	//방법 1
	$bszChiperText = KISA_SEED_ECB::SEED_ECB_Encrypt($keyBytes, $planBytes, 0, count($planBytes));

	for($i=0;$i< sizeof($bszChiperText);$i++) {
			$ret .=  sprintf("%02X", $bszChiperText[$i]).",";
	}

	return substr($ret,0,strlen($ret)-1);
}

$enc = null;

if(isset($_POST['ENC']))
	$enc = $_POST['ENC'];

if($enc==null) {
	$enc2 = "";
} else {
	//암호화 시작
	$g_bszPlainText = $enc;
	$enc2 = encrypt($g_bszUser_key, $g_bszPlainText);
}

function decrypt($bszUser_key, $str) {
	$planBytes = explode(",",$str);
	$keyBytes = explode(",",$bszUser_key);
	
	for($i = 0; $i < 16; $i++)
	{
		$keyBytes[$i] = hexdec($keyBytes[$i]);
	}

	for ($i = 0; $i < count($planBytes); $i++) {
		$planBytes[$i] = hexdec($planBytes[$i]);
	}

	if (count($planBytes) == 0) {
		return $str;
	}

	$pdwRoundKey = array_pad(array(),32,0);

	$bszPlainText = null;
	$planBytresMessage = null;
	
	// 방법 1
	$bszPlainText = KISA_SEED_ECB::SEED_ECB_Decrypt($keyBytes, $planBytes, 0, count($planBytes));
	for($i=0;$i< sizeof($bszPlainText);$i++) {
		$planBytresMessage .=  sprintf("%02X", $bszPlainText[$i]).",";
	}

	return substr($planBytresMessage,0,strlen($planBytresMessage)-1);
}

$dec = null;

if(isset($_POST['DEC']))
	$dec = $_POST['DEC'];

if($dec==null) {
	$dec2 = "";
} else {
	//복호화 시작
	$g_bszChiperText = $dec;
	$dec2 = decrypt($g_bszUser_key, $g_bszChiperText);
}
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - ECB] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-ECB] 테스트 페이지</h1>
<form name="myform1" method="post" action="./index.php">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<form method="post" action="./index.php">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="KEY" style="width:400px;height:100px;"><?=$g_bszUser_key?></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="ENC" style="width:400px;height:100px;"><?=$enc?></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ 암호화"> </td>
</tr>
<tr>
<td>암호문 : </td> 
<td><textarea name="ENC2" style="width:400px;height:100px;"><?=$enc2?></textarea></td>
</tr>
</table>
</form>	
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<form name="myform2" method="post" action="./index.php">
<table border="0">
<tr><td></td><td>&lt;복호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="KEY" style="width:400px;height:100px;"><?=$g_bszUser_key?></textarea></td>
</tr>
<tr>
<td>암호문 : </td> 
<td><textarea name="DEC" style="width:400px;height:100px;"><?=$dec?></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ 복호화"></td>
</tr>
<tr>
<td>평문 : </td> 
<td><textarea name="DEC2" style="width:400px;height:100px;"><?=$dec2?></textarea></td>
</tr>
</table>
</form>	
</td>
</tr>
</table>
<div style="margin-top:20px;margin-bottom:20px;"><font color="#ff0000">※ 평문 및 암호문은 Hex 값의 0x를 제외하고 콤마로 구분하여 띄어쓰기 없이 입력합니다.(ex : 00,01,0A,0B)</font></div>
<div style="border: 1px solid #aaaaff; background-color:#ddddff;">
<table border="0">
<tr>
<td>&lt;키(KEY)&gt; : </td>
<td>2B,7E,15,16,28,AE,D2,A6,AB,F7,15,88,09,CF,4F,3C</td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td>00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F</td>
</tr>
<tr>
<td>&lt;암호문&gt; : </td>
<TD>F7,A5,AB,AA,86,9B,E1,1E,C1,D0,3B,BA,92,76,A1,64,AD,6C,74,B7,08,D1,CA,7E,B1,AA,FF,31,96,34,C6,02</TD>
</tr>
</table>
</div>
</form>
</center>
</body>
</html>
