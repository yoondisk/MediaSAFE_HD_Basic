<?php
require_once ('KISA_SEED_CTR.php');

$g_bszUser_key = null;
if(isset($_POST['KEY']))
	$g_bszUser_key = $_POST['KEY'];
if($g_bszUser_key == null)
{
	$g_bszUser_key = "88,E3,4F,8F,08,17,79,F1,E9,F3,94,37,0A,D4,05,89";
}

$g_bszCounter = null;
if(isset($_POST['CTR']))
	$g_bszCounter = $_POST['CTR'];
if($g_bszCounter == null)
{
	$g_bszCounter = "00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FE";
}

function encrypt($bszCounter, $bszUser_key, $str) {
	$planBytes = explode(",",$str);
	$keyBytes = explode(",",$bszUser_key);
	$CTRBytes = explode(",",$bszCounter);
	
	for($i = 0; $i < 16; $i++)
	{
		$keyBytes[$i] = hexdec($keyBytes[$i]);
		$CTRBytes[$i] = hexdec($CTRBytes[$i]);
	}
	for ($i = 0; $i < count($planBytes); $i++) {
		$planBytes[$i] = hexdec($planBytes[$i]);
	}
	if (count($planBytes) == 0) {
		return $str;
	}
	$ret = null;
	$bszChiperText = null;

//*
	//방법 1
	$bszChiperText = KISA_SEED_CTR::SEED_CTR_Encrypt($keyBytes, $CTRBytes, $planBytes, 0, count($planBytes));

	$r = count($bszChiperText);

	foreach($bszChiperText as $encryptedString) {
		$ret .= bin2hex(chr($encryptedString)).",";
	}
	return substr($ret,0,strlen($ret)-1);

//*/

/*
	// 방법 2
	$info = new KISA_SEED_INFO();
	$message_length = count($planBytes);

	$process_blockLeng = 32;
	$outbuf = array_pad(array(), $process_blockLeng/4, 0);

	KISA_SEED_CTR::SEED_CTR_init( $info, KISA_ENC_DEC::KISA_ENCRYPT, $keyBytes, $CTRBytes );

	for($i = 0; $i < $message_length-$process_blockLeng; )
	{
		Common::arraycopy_system($planBytes, $i, $pbszPlainText, 0, $process_blockLeng);
		$data = KISA_SEED_CTR::chartoint32_for_SEED_CTR($pbszPlainText, $process_blockLeng);
		KISA_SEED_CTR::SEED_CTR_Process( $info, $data, $process_blockLeng, $outbuf, $nRetOutLeng );
		$cdata = KISA_SEED_CTR::int32tochar_for_SEED_CTR($outbuf, $nRetOutLeng);
		Common::arraycopy_system($cdata, 0, $pbszCipherText, $i,  $nRetOutLeng );
		$i+= $nRetOutLeng;
	}

	$remainleng = $message_length%$process_blockLeng;
	if($remainleng==0)
	{
		$remainleng = $process_blockLeng;
	}
	Common::arraycopy_system($planBytes, $i, $pbszPlainText, 0, $remainleng);
	$data = KISA_SEED_CTR::chartoint32_for_SEED_CTR($pbszPlainText, $remainleng);
	KISA_SEED_CTR::SEED_CTR_Process( $info, $data, $remainleng, $outbuf, $nRetOutLeng );
	KISA_SEED_CTR::SEED_CTR_Close($info,$outbuf,$nRetOutLeng,$EncRmainLeng);
	$cdata = KISA_SEED_CTR::int32tochar_for_SEED_CTR($outbuf, $nRetOutLeng-$EncRmainLeng);
	Common::arraycopy_system($cdata, 0, $pbszCipherText, $i,  $nRetOutLeng-$EncRmainLeng);
	
	$data = null;
	$cdata = null;
	$outbuf = null;
	
	foreach($pbszCipherText as $encryptedString) {
		$ret .= bin2hex(chr($encryptedString)).",";
	}
	return substr($ret,0,strlen($ret)-1);
//*/
}

function decrypt($bszCounter, $bszUser_key, $str) {

	$planBytes = explode(",",$str);
	$keyBytes = explode(",",$bszUser_key);
	$CTRBytes = explode(",",$bszCounter);
	
	for($i = 0; $i < 16; $i++)
	{
		$keyBytes[$i] = hexdec($keyBytes[$i]);
		$CTRBytes[$i] = hexdec($CTRBytes[$i]);
	}

	for ($i = 0; $i < count($planBytes); $i++) {
		$planBytes[$i] = hexdec($planBytes[$i]);
	}

	if (count($planBytes) == 0) {
		return $str;
	}

	$bszPlainText = null;
	$planBytresMessage = null;

	// 방법 1
	$bszPlainText = KISA_SEED_CTR::SEED_CTR_Decrypt($keyBytes, $CTRBytes, $planBytes, 0, count($planBytes));

	for($i=0;$i< sizeof($bszPlainText);$i++) {
		$planBytresMessage .=  sprintf("%02X", $bszPlainText[$i]).",";
	}

	return substr($planBytresMessage,0,strlen($planBytresMessage)-1);

/*
	// 방법 2
	$info = new KISA_SEED_INFO();
	$message_length = count($planBytes);

	$process_blockLeng = 32;
	$outbuf = array_pad(array(), $process_blockLeng/4, 0);

	KISA_SEED_CTR::SEED_CTR_init( $info, KISA_ENC_DEC::KISA_ENCRYPT, $keyBytes, $CTRBytes );

	for($i = 0; $i < $message_length-$process_blockLeng; )
	{
		Common::arraycopy_system($planBytes, $i, $pbszPlainText, 0, $process_blockLeng);
		$data = KISA_SEED_CTR::chartoint32_for_SEED_CTR($pbszPlainText, $process_blockLeng);
		KISA_SEED_CTR::SEED_CTR_Process( $info, $data, $process_blockLeng, $outbuf, $nRetOutLeng );
		$cdata = KISA_SEED_CTR::int32tochar_for_SEED_CTR($outbuf, $nRetOutLeng);
		Common::arraycopy_system($cdata, 0, $pbszCipherText, $i,  $nRetOutLeng );
		$i+= $nRetOutLeng;
	}

	$remainleng = $message_length%$process_blockLeng;
	if($remainleng==0)
	{
		$remainleng = $process_blockLeng;
	}
	Common::arraycopy_system($planBytes, $i, $pbszPlainText, 0, $remainleng);
	$data = KISA_SEED_CTR::chartoint32_for_SEED_CTR($pbszPlainText, $remainleng);
	KISA_SEED_CTR::SEED_CTR_Process( $info, $data, $remainleng, $outbuf, $nRetOutLeng );
	KISA_SEED_CTR::SEED_CTR_Close($info,$outbuf,$nRetOutLeng,$EncRmainLeng);
	$cdata = KISA_SEED_CTR::int32tochar_for_SEED_CTR($outbuf, $nRetOutLeng-$EncRmainLeng);
	Common::arraycopy_system($cdata, 0, $pbszCipherText, $i,  $nRetOutLeng-$EncRmainLeng);
	$i+= $nRetOutLeng;


	$data = null;
	$cdata = null;
	$outbuf = null;
	
	foreach($pbszCipherText as $encryptedString) {
		$ret .= bin2hex(chr($encryptedString)).",";
	}
	return substr($ret,0,strlen($ret)-1);
	//*/
}

$enc = null;
$dec = null;

if(isset($_POST['ENC']))
	$enc = $_POST['ENC'];
	
if(isset($_POST['DEC']))
	$dec = $_POST['DEC'];

if($enc==null) {
	$enc2 = "";
} else {
	//암호화 시작
	$g_bszPlainText = $enc;
	$enc2 = encrypt($g_bszCounter, $g_bszUser_key, $g_bszPlainText);

}

if($dec==null) {
	$dec2 = "";
} else {
	//복호화 시작
	$g_bszChiperText = $dec;
	$dec2 = decrypt($g_bszCounter, $g_bszUser_key, $g_bszChiperText);
}

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CTR] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CTR] 테스트 페이지</h1>
<form name="myform" method="post" action="./index.php">
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
<td>카운터(CTR) : </td> 
<td><textarea name="CTR" style="width:400px;height:100px;"><?=$g_bszCounter?></textarea></td>
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
<form method="post" action="./index.php">
<table border="0">
<tr><td></td><td>&lt;복호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="KEY" style="width:400px;height:100px;"><?=$g_bszUser_key?></textarea></td>
</tr>
<tr>
<td>카운터(CTR) : </td> 
<td><textarea name="CTR" style="width:400px;height:100px;"><?=$g_bszCounter?></textarea></td>
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
<td>88,E3,4F,8F,08,17,79,F1,E9,F3,94,37,0A,D4,05,89</td>
</tr>
<tr>
<td>&lt;초기카운터&gt; : </td>
<td>00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FE</td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td>00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F</td>
</tr>
<tr>
<td>&lt;암호문&gt; : </td>
<td>83,72,13,DF,61,DD,CB,5B,50,AC,EB,54,5B,86,43,ED</td>
</tr>
</table>
</div>
</form>

</center>
</body>
</html>