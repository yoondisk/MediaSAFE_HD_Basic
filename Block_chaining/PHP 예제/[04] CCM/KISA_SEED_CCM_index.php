<?php
require_once ('KISA_SEED_CCM.php');

function encrypt(&$pet, $pinput, $macLen, $pnonce, $paad, $pkey)
{
	$key = explode(",", $pkey);
    $input = explode(",", $pinput);
    $nonce = explode(",", $pnonce);
    $aad = explode(",", $paad);
	
	for ($i = 0; $i < count($key); $i++)
	{
		$key[$i] = hexdec($key[$i]);
    }
    
    for ($i = 0; $i < count($nonce); $i++)
    {
		$nonce[$i] = hexdec($nonce[$i]);
    }

    $nonceLen = sizeof($nonce);
    
    if ($paad == null)
    {
        $aadLen = 0;
    }
    else
    {
        for ($i = 0; $i < count($aad); $i++)
        {
            $aad[$i] = hexdec($aad[$i]);
        }

        $aadLen = sizeof($aad);
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

    $output = array_pad(array(), $inputLen + $macLen, 0);

    $result = KISA_SEED_CCM::SEED_CCM_Encryption($output, $input, $inputLen, $macLen, $nonce, $nonceLen, $aad, $aadLen, $key);

    $data = null;
    for ($i = 0; $i < sizeof($output); $i++)
    {
			$data .=  sprintf("%02X", $output[$i]).",";
	}

	$pet = substr($data, 0, strlen($data) - 1);
    
    return $result;
}

function decrypt(&$pdt, $pinput, $macLen, $pnonce, $paad, $pkey)
{
	$key = explode(",", $pkey);
    $input = explode(",", $pinput);
    $nonce = explode(",", $pnonce);
    $aad = explode(",", $paad);
	
	for ($i = 0; $i < count($key); $i++)
	{
		$key[$i] = hexdec($key[$i]);
    }
    
    for ($i = 0; $i < count($nonce); $i++)
    {
		$nonce[$i] = hexdec($nonce[$i]);
	}

    $nonceLen = sizeof($nonce);
    
    if ($paad == null)
    {
        $aadLen = 0;
    }
    else
    {
        for ($i = 0; $i < count($aad); $i++)
        {
            $aad[$i] = hexdec($aad[$i]);
        }

        $aadLen = sizeof($aad);
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

    $output = array_pad(array(), $inputLen - $macLen, 0);

    $result = KISA_SEED_CCM::SEED_CCM_Decryption($output, $input, $inputLen, $macLen, $nonce, $nonceLen, $aad, $aadLen, $key);

    $data = null;
    for ($i = 0; $i < sizeof($output); $i++)
    {
			$data .=  sprintf("%02X", $output[$i]).",";
	}

	$pdt = substr($data, 0, strlen($data) - 1);
    
    return $result;
}

if (isset($_POST['E_KEY']))
    $e_key = $_POST['E_KEY'];

if (isset($_POST['E_NONCE']))
    $e_nonce = $_POST['E_NONCE'];

if (($e_key!=null) && ($e_nonce != null))
{
    if (isset($_POST['E_IN']))
        $e_in = $_POST['E_IN'];

    if (isset($_POST['E_AAD']))
        $e_aad = $_POST['E_AAD'];

    if (isset($_POST['E_MAC_LEN']))
        $e_mac_len = $_POST['E_MAC_LEN'];

    $result = null;
    $result = encrypt($e_out, $e_in, $e_mac_len, $e_nonce, $e_aad, $e_key);

    $e_ret = $result;

    if ($result == 0)
    {
        $e_ret .= ", Success!";
    }
    else
    {
        $e_ret .= ", Failure!";
    }
}
else
{
    $e_in = "";
    $e_nonce = "";
    $e_aad = "";
    $e_in = "";
    $e_out = "";
    $e_ret = "";
}

if (isset($_POST['D_KEY']))
    $d_key = $_POST['D_KEY'];

if (isset($_POST['D_NONCE']))
    $d_nonce = $_POST['D_NONCE'];

if (($d_key != null) && ($d_nonce != null))
{
    if (isset($_POST['D_IN']))
        $d_in = $_POST['D_IN'];

    if (isset($_POST['D_AAD']))
        $d_aad = $_POST['D_AAD'];

    if (isset($_POST['D_MAC_LEN']))
        $d_mac_len = $_POST['D_MAC_LEN'];

    $result = null;
    $result = decrypt($d_out, $d_in, $d_mac_len, $d_nonce, $d_aad, $d_key);

    $d_ret = $result;

    if ($result == 0)
    {
        $d_ret .= ", Correct!";
    }
    else
    {
        $d_ret .= ", Incorrect!";
    }
}
else
{
    $d_in = "";
    $d_nonce = "";
    $d_aad = "";
    $d_in = "";
    $d_out = "";
    $d_ret = "";
}


?>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CCM] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CCM] 테스트 페이지</h1>
<form name="myform1" method="post" action="./KISA_SEED_CCM_index.php">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<form method="post" action="./KISA_SEED_CCM_index.php">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="E_KEY" style="width:400px;height:100px;"><?=$e_key?></textarea></td>
</tr>
<tr>
<td>초기값(NONCE) : </td> 
<td><textarea name="E_NONCE" style="width:400px;height:100px;"><?=$e_nonce?></textarea></td>
</tr>
<tr>
<td>추가인증데이터(AAD) : </td> 
<td><textarea name="E_AAD" style="width:400px;height:100px;"><?=$e_aad?></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="E_IN" style="width:400px;height:100px;"><?=$e_in?></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="E_MAC_LEN" style="width:400px;height:20px;"><?=$e_mac_len?></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ 암호화"> </td>
</tr>
<tr>
<td>암호문 : </td> 
<td><textarea name="E_OUT" style="width:400px;height:100px;"><?=$e_out?></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="E_RET" style="width:400px;height:20px;"><?=$e_ret?></textarea></td>
</tr>
</table>
</form>	
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<form name="myform2" method="post" action="./KISA_SEED_CCM_index.php">
<table border="0">
<tr><td></td><td>&lt;복호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="D_KEY" style="width:400px;height:100px;"><?=$d_key?></textarea></td>
</tr>
<tr>
<td>초기값(NONCE) : </td> 
<td><textarea name="D_NONCE" style="width:400px;height:100px;"><?=$d_nonce?></textarea></td>
</tr>
<tr>
<td>추가인증데이터(AAD) : </td> 
<td><textarea name="D_AAD" style="width:400px;height:100px;"><?=$d_aad?></textarea></td>
</tr>
<tr>
<td>암호문 : </td>
<td><textarea name="D_IN" style="width:400px;height:100px;"><?=$d_in?></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="D_MAC_LEN" style="width:400px;height:20px;"><?=$d_mac_len?></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ 복호화"> </td>
</tr>
<tr>
<td>복호문 : </td> 
<td><textarea name="D_OUT" style="width:400px;height:100px;"><?=$d_out?></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="D_RET" style="width:400px;height:20px;"><?=$d_ret?></textarea></td>
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
<td>FC,58,7C,16,26,93,E6,CD,63,EE,D5,39,B5,7B,EA,09</td>
</tr>
<tr>
<td>&lt;초기값(NONCE)&gt; : </td>
<td>5C,85,10,0A,3E,69,01</td>
</tr>
<tr>
<td>&lt;추가인증데이터(AAD)&gt; : </td>
<td>9D,8C,A7,0D,69,A3,39,17,4D,30,24,E0,98,98,4C,88</td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td>7D,97,8C,51,C1,27,06,A7,B7,A3,B8,5D,6E,2C,51,3A</td>
</tr>
<tr>
<td>&lt;인증값 길이&gt; : </td>
<td>16</td>
</tr>
<tr>
<td>&lt;암호문&gt; : </td>
<td>47,71,D9,F2,50,3C,BF,EB,B2,00,CB,ED,10,22,42,EC,AA,CD,3A,5F,54,84,86,3C,AF,97,18,8D,7B,67,D0,05</td>
</tr>
</table>
</div>
</form>
</center>
</body>
</html>