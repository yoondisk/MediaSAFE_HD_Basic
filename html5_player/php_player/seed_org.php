<?php
require_once ('seed/KISA_SEED_CBC.php');

$g_bszUser_key = null;
if(isset($_POST['KEY']))
	$g_bszUser_key = $_POST['KEY'];
if($g_bszUser_key == null)
{
	$g_bszUser_key = "88,E3,4F,8F,08,17,79,F1,E9,F3,94,37,0A,D4,05,89";
}
	
$g_bszIV = null;
if(isset($_POST['IV']))
	$g_bszIV = $_POST['IV'];
if($g_bszIV == null)
{
	$g_bszIV = "26,8D,66,A7,35,A8,1A,81,6F,BA,D9,FA,36,16,25,01";
}

function encrypt($bszIV, $bszUser_key, $str) {


	$planBytes = explode(",",$str);
	$keyBytes = explode(",",$bszUser_key);
	$IVBytes = explode(",",$bszIV);
	
	for($i = 0; $i < 16; $i++)
	{
		$keyBytes[$i] = hexdec($keyBytes[$i]);
		$IVBytes[$i] = hexdec($IVBytes[$i]);
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
	$bszChiperText = KISA_SEED_CBC::SEED_CBC_Encrypt($keyBytes, $IVBytes, $planBytes, 0, count($planBytes));

	$r = count($bszChiperText);

	for($i=0;$i< $r;$i++) {
		$ret .=  sprintf("%02X", $bszChiperText[$i]).",";
	}
	return substr($ret,0,strlen($ret)-1);


/*
	// 방법 2
	$info = new KISA_SEED_INFO();
	$message_length = count($planBytes);
	
	KISA_SEED_CBC::SEED_CBC_init( $info, KISA_ENC_DEC::KISA_ENCRYPT, $keyBytes, $IVBytes );
	
	$process_blockLeng = 32;
	$outbuf = array_pad(array(), $process_blockLeng/4, 0);
	for($i = 0; $i < $message_length-$process_blockLeng; )
	{
		Common::arraycopy_system($planBytes, $i, $pbszPlainText, 0, $process_blockLeng);
		$data = KISA_SEED_CBC::chartoint32_for_SEED_CBC($pbszPlainText, $process_blockLeng);
		KISA_SEED_CBC::SEED_CBC_Process( $info, $data, $process_blockLeng, $outbuf, $nRetOutLeng );
		$cdata = KISA_SEED_CBC::int32tochar_for_SEED_CBC($outbuf, $nRetOutLeng);
		Common::arraycopy_system($cdata, 0, $pbszCipherText, $i,  $nRetOutLeng );
		$i+= $nRetOutLeng;
	}
	$remainleng = $message_length%$process_blockLeng;
	if($remainleng==0)
	{
		$remainleng = $process_blockLeng;
	}
	Common::arraycopy_system($planBytes, $i, $pbszPlainText, 0, $remainleng);
	$data = KISA_SEED_CBC::chartoint32_for_SEED_CBC($pbszPlainText, $remainleng);
	KISA_SEED_CBC::SEED_CBC_Process( $info, $data, $remainleng, $outbuf, $nRetOutLeng );
	$cdata = KISA_SEED_CBC::int32tochar_for_SEED_CBC($outbuf, $nRetOutLeng);
	Common::arraycopy_system($cdata, 0, $pbszCipherText, $i,  $nRetOutLeng );
	$i+= $nRetOutLeng;

	KISA_SEED_CBC::SEED_CBC_Close( $info, $outbuf, 0, $nPaddingLeng );
	$cdata = KISA_SEED_CBC::int32tochar_for_SEED_CBC($outbuf, $nPaddingLeng);
	Common::arraycopy_system($cdata, 0, $pbszCipherText, $i,  $nPaddingLeng );


	$data = null;
	$cdata = null;
	$outbuf = null;
	
	for($i=0;$i< sizeof($pbszCipherText);$i++) {
		$ret .=  sprintf("%02X", $pbszCipherText[$i]).",";
	}
	return substr($ret,0,strlen($ret)-1);
*/

}

function decrypt($bszIV, $bszUser_key, $str) {

	$planBytes = explode(",",$str);
	$keyBytes = explode(",",$bszUser_key);
	$IVBytes = explode(",",$bszIV);
	
	for($i = 0; $i < 16; $i++)
	{
		$keyBytes[$i] = hexdec($keyBytes[$i]);
		$IVBytes[$i] = hexdec($IVBytes[$i]);
	}

	for ($i = 0; $i < count($planBytes); $i++) {
		$planBytes[$i] = hexdec($planBytes[$i]);
	}

	if (count($planBytes) == 0) {
		return $str;
	}

	$pdwRoundKey = array_pad(array(),32,0);

	$bszPlainText = null;

	// 방법 1
	$bszPlainText = KISA_SEED_CBC::SEED_CBC_Decrypt($keyBytes, $IVBytes, $planBytes, 0, count($planBytes));
	for($i=0;$i< sizeof($bszPlainText);$i++) {
		$planBytresMessage .=  sprintf("%02X", $bszPlainText[$i]).",";
	}

	return substr($planBytresMessage,0,strlen($planBytresMessage)-1);


/*
	// 방법 2
	$info = new KISA_SEED_INFO();
	$nCipherTextLen = count($pbszCipherText);

	
	$EncryptedMessage_length = count($planBytes);
	if($EncryptedMessage_length%KISA_SEED_CBC::BLOCK_SIZE_SEED)
	{
		return "";
	}
	KISA_SEED_CBC::SEED_CBC_init( $info, KISA_ENC_DEC::KISA_DECRYPT, $keyBytes, $IVBytes );

	$process_blockLeng = 32;

	$outbuf = array_pad(array(), $process_blockLeng/4, 0);

	for($i = 0; $i < $EncryptedMessage_length-$process_blockLeng; )
	{
		Common::arraycopy_system($planBytes, $i, $pbszCipherText, 0, $process_blockLeng);
		$data = KISA_SEED_CBC::chartoint32_for_SEED_CBC($pbszCipherText,$process_blockLeng);
		KISA_SEED_CBC::SEED_CBC_Process( $info, $data, $process_blockLeng, $outbuf, $nRetOutLeng );
		$cdata = KISA_SEED_CBC::int32tochar_for_SEED_CBC( $outbuf, $nRetOutLeng );
		Common::arraycopy_system($cdata, 0, $pbszPlainText, $i,  $nRetOutLeng );
		$i+= $nRetOutLeng;
	}
	$remainleng = $EncryptedMessage_length%$process_blockLeng;

	if($remainleng==0)
	{
		$remainleng = $process_blockLeng;
	}	
	Common::arraycopy_system($planBytes, $i, $pbszCipherText, 0, $remainleng);
	$data = KISA_SEED_CBC::chartoint32_for_SEED_CBC($pbszCipherText,$remainleng);
	KISA_SEED_CBC::SEED_CBC_Process( $info, $data, $remainleng, $outbuf, $nRetOutLeng );
	if(KISA_SEED_CBC::SEED_CBC_Close( $info, $outbuf, $nRetOutLeng, $nPaddingLeng))
	{
		$cdata = KISA_SEED_CBC::int32tochar_for_SEED_CBC( $outbuf, $remainleng-$nPaddingLeng );
		Common::arraycopy_system($cdata, 0, $pbszPlainText, $i, $remainleng-$nPaddingLeng );
		$message_length = $i+ $remainleng -$nPaddingLeng;
		$result = array_pad(array(), $message_length, 0);
		Common::arraycopy_system($pbszPlainText, 0, $result, 0, $message_length);
		$data = null;
		$cdata = null;
		$outbuf = null;

		for($i=0;$i< sizeof($result);$i++) {
			$planBytresMessage .=  sprintf("%02X", $result[$i]).",";
		}

		return substr($planBytresMessage,0,strlen($planBytresMessage)-1);
	}
	return "";
*/

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
	$enc2 = encrypt($g_bszIV, $g_bszUser_key, $g_bszPlainText);
}

if($dec==null) {
	$dec2 = "";
} else {
	//복호화 시작
	$g_bszChiperText = $dec;
	$dec2 = decrypt($g_bszIV, $g_bszUser_key, $g_bszChiperText);
}

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CBC] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CBC] 테스트 페이지</h1>
<form name="myform" method="post" action="./seed_org.php">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<form method="post" action="./seed_org.php">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="KEY" style="width:400px;height:100px;"><?=$g_bszUser_key?></textarea></td>
</tr>
<tr>
<td>초기값(IV) : </td> 
<td><textarea name="IV" style="width:400px;height:100px;"><?=$g_bszIV?></textarea></td>
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
<td>초기값(IV) : </td> 
<td><textarea name="IV" style="width:400px;height:100px;"><?=$g_bszIV?></textarea></td>
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
<td>&lt;초기값(IV)&gt; : </td>
<td>26,8D,66,A7,35,A8,1A,81,6F,BA,D9,FA,36,16,25,01</td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td>00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F</td>
</tr>
<tr>
<td>&lt;암호문&gt; : </td>
<td>75,DD,A4,B0,65,FF,86,42,7D,44,8C,54,03,D3,5A,07,D3,5A,AB,86,7C,8B,F2,55,7D,82,38,8E,A7,C0,D0,F1</td>
</tr>
</table>
</div>
</form>

</center>
</body>
</html>