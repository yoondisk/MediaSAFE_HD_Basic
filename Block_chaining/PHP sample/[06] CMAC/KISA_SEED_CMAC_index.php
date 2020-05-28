<?php
require_once ('KISA_SEED_CMAC.php');

function generate(&$pet, $pinput, $macLen, $pkey)
{
	$key = explode(",", $pkey);
    $input = explode(",", $pinput);
	
	for ($i = 0; $i < count($key); $i++)
	{
		$key[$i] = hexdec($key[$i]);
    }

    if ($pinput == null)
    {
        $inputLen = 0;
    }
    else
    {
        for ($i = 0; $i < count($input); $i++)
        {
            $input[$i] = hexdec($input[$i]);
        }

        $inputLen = sizeof($input);
    }

    $output = array_pad(array(), $macLen, 0);

    $result = KISA_SEED_CMAC::SEED_Generate_CMAC($output, $macLen, $input, $inputLen, $key);

    $data = null;
    for ($i = 0; $i < sizeof($output); $i++)
    {
			$data .=  sprintf("%02X", $output[$i]).",";
	}

	$pet = substr($data, 0, strlen($data) - 1);
    
    return $result;
}

function verify($pmac, $pinput, $macLen, $pkey)
{
	$key = explode(",", $pkey);
    $input = explode(",", $pinput);
	$mac = explode(",", $pmac);
	
	for ($i = 0; $i < count($key); $i++)
	{
		$key[$i] = hexdec($key[$i]);
    }
	
	for ($i = 0; $i < count($mac); $i++)
	{
		$mac[$i] = hexdec($mac[$i]);
    }

    if ($pinput == null)
    {
        $inputLen = 0;
    }
    else
    {
        for ($i = 0; $i < count($input); $i++)
        {
            $input[$i] = hexdec($input[$i]);
        }

        $inputLen = sizeof($input);
    }

    $result = KISA_SEED_CMAC::SEED_Verify_CMAC($mac, $macLen, $input, $inputLen, $key);
    
    return $result;
}

if (isset($_POST['G_KEY']))
    $g_key = $_POST['G_KEY'];

if ($g_key!=null)
{
    if (isset($_POST['G_IN']))
        $g_in = $_POST['G_IN'];

    if (isset($_POST['G_MAC_LEN']))
        $g_mac_len = $_POST['G_MAC_LEN'];

    $result = null;
    $result = generate($g_mac, $g_in, $g_mac_len, $g_key);

    $g_ret = $result;

    if ($result == 0)
    {
        $g_ret .= ", Success!";
    }
    else
    {
        $g_ret .= ", Failure!";
    }
}
else
{
    $g_in = "";
    $g_mac = "";
    $g_ret = "";
}

if (isset($_POST['V_KEY']))
    $v_key = $_POST['V_KEY'];

if ($v_key != null)
{
    if (isset($_POST['V_IN']))
        $v_in = $_POST['V_IN'];
	
	if (isset($_POST['V_MAC']))
        $v_mac = $_POST['V_MAC'];

    if (isset($_POST['V_MAC_LEN']))
        $v_mac_len = $_POST['V_MAC_LEN'];

    $result = null;
    $result = verify($v_mac, $v_in, $v_mac_len, $v_key);

    $v_ret = $result;

    if ($result == 0)
    {
        $v_ret .= ", Correct!";
    }
    else
    {
        $v_ret .= ", Incorrect!";
    }
}
else
{
    $v_in = "";
    $v_mac = "";
    $v_ret = "";
}


?>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CMAC] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CMAC] 테스트 페이지</h1>
<form name="myform1" method="post" action="./KISA_SEED_CMAC_index.php">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<form method="post" action="./KISA_SEED_CMAC_index.php">
<table border="0">
<tr><td></td><td>&lt;MAC 생성 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="G_KEY" style="width:400px;height:100px;"><?=$g_key?></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="G_IN" style="width:400px;height:100px;"><?=$g_in?></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="G_MAC_LEN" style="width:400px;height:20px;"><?=$g_mac_len?></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ MAC 생성"> </td>
</tr>
<tr>
<td>MAC : </td> 
<td><textarea name="G_MAC" style="width:400px;height:100px;"><?=$g_mac?></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="G_RET" style="width:400px;height:20px;"><?=$g_ret?></textarea></td>
</tr>
</table>
</form>	
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<form name="myform2" method="post" action="./KISA_SEED_CMAC_index.php">
<table border="0">
<tr><td></td><td>&lt;MAC 검증 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="V_KEY" style="width:400px;height:100px;"><?=$v_key?></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="V_IN" style="width:400px;height:100px;"><?=$v_in?></textarea></td>
</tr>
<tr>
<td>MAC : </td>
<td><textarea name="V_MAC" style="width:400px;height:100px;"><?=$v_mac?></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="V_MAC_LEN" style="width:400px;height:20px;"><?=$v_mac_len?></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ MAC 검증"> </td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="V_RET" style="width:400px;height:20px;"><?=$v_ret?></textarea></td>
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
<td>B9,28,C9,8B,08,37,E8,87,45,2C,42,0E,36,07,E7,B9</td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td></td>
</tr>
<tr>
<td>&lt;인증값 길이&gt; : </td>
<td>16</td>
</tr>
<tr>
<td>&lt;MAC&gt; : </td>
<td>6A,6F,37,8E,CF,4B,CB,F4,F8,A1,69,13,2E,D8,38,13</td>
</tr>
</table>
</div>
</form>
</center>
</body>
</html>