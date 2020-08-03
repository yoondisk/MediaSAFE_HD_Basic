<?php
/*
	String To Hex
*/
function strToHex($string){
 $hex='';
	for ($i=0; $i < strlen($string); $i++){
		$hex .= "," . dechex(ord($string[$i]));
	}
	$hex=substr( $hex , 1, strlen($hex));
 return $hex;
}

 
/*
	 Hex To String
*/
function hexToStr($hex){
 $hex = str_replace(",","", $hex);
 $string='';
	for ($i=0; $i < strlen($hex)-1; $i+=2){
		$string .= chr(hexdec($hex[$i].$hex[$i+1]));
	}
 return $string;
}

/*
    ENCRYPT encrypt($bszIV, $bszUser_key, $str)
	  Orgin string => Timestamp|String => String to hex => SEED ENCRYPT => Hex to String => Base64_encode => Encrypt String
*/
function encrypt($bszIV, $bszUser_key, $str) {
	
	$str = time().'|'.$str;

	$str = strToHex($str);

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

	$bszChiperText = KISA_SEED_CBC::SEED_CBC_Encrypt($keyBytes, $IVBytes, $planBytes, 0, count($planBytes));

	$r = count($bszChiperText);

	for($i=0;$i< $r;$i++) {
		$ret .=  sprintf("%02X", $bszChiperText[$i]).",";
	}
	
	$encstring=substr($ret,0,strlen($ret)-1);

	$ret=hexToStr($encstring);
	
	$ret=base64_encode($ret);

	return $ret;
}


/*
	DECRYPT decrypt($bszIV, $bszUser_key, $str)
	  Encrypt String => Base64_decode => String to hex  => SEED DECRYPT => Hex to String => TimeStamp Remove => Decrypt String
*/

function decrypt($bszIV, $bszUser_key, $str) {

	$str=base64_decode($str);
	$str=StrTohex($str);

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

	$bszPlainText = KISA_SEED_CBC::SEED_CBC_Decrypt($keyBytes, $IVBytes, $planBytes, 0, count($planBytes));
	for($i=0;$i< sizeof($bszPlainText);$i++) {
		$planBytresMessage .=  sprintf("%02X", $bszPlainText[$i]).",";
	}

	$decstring=substr($planBytresMessage,0,strlen($planBytresMessage)-1);

	$ret=hexToStr($decstring);

	$timeRemove = explode("|",$ret);

	return $timeRemove[1];

}
?>