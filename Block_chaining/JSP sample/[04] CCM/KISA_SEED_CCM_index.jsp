<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="KISA_SEED_CCM.jsp" %>
<%!
public byte[] getBytes(String data)
{
	String[] str = data.split(",");
	byte[] result = new byte[str.length];

	for (int i = 0; i < result.length; i++)
    {
		result[i] = getHex(str[i]);
	}

	return result;
}

public String getString(byte[] data)
{
	String result = "";

	for (int i = 0; i < data.length; i++)
    {
		result = result + toHex(data[i]);

		if (i < data.length - 1)
			result = result + ",";
	}

	return result;
}

public byte getHex(String str)
{
	str = str.trim();

	if (str.length() == 0)
		str = "00";
	else if (str.length() == 1)
		str = "0" + str;
	
	str = str.toUpperCase();

	return (byte)(getHexNibble(str.charAt(0)) * 16 + getHexNibble(str.charAt(1)));
}

public byte getHexNibble(char c)
{
	if ((c >= '0') && (c <= '9'))
		return (byte)(c - '0');
    
	if ((c >= 'A') && (c <='F'))
		return (byte)(c - 'A' + 10);

	return 0;
}

public String toHex(int b)
{
	char c[] = new char[2];

	c[0] = toHexNibble((b >> 4) & 0x0f);
	c[1] = toHexNibble(b & 0x0f);

	return new String(c);
}

public char toHexNibble(int b)
{
	if ((b >= 0) && (b <= 9))
		return (char)(b + '0');

	if ((b >= 0x0a) && (b <= 0x0f))
		return (char)(b + 'A' - 10);

	return '0';
}

%>

<%
String method = request.getParameter("method");

String e_key = "";
String e_nonce = "";
String e_aad = "";
String e_mac_len = "";
String e_in = "";
String e_out = "";
String e_ret = "";

String d_key = "";
String d_nonce = "";
String d_aad = "";
String d_mac_len = "";
String d_in = "";
String d_out = "";
String d_ret = "";

if ((method != null) && (method.equals("e")))
{
	byte[] key;
	String keyStr = request.getParameter("e_key");

	if (keyStr != null)
	{
		key = getBytes(keyStr);

        String inputStr = request.getParameter("e_in");
        byte[] input = getBytes(inputStr);
        String nonceStr = request.getParameter("e_nonce");
        byte[] nonce = getBytes(nonceStr);
        String aadStr = request.getParameter("e_aad");
        byte[] aad = getBytes(aadStr);
		byte macLen = (byte)Integer.parseInt(request.getParameter("e_mac_len"));
		byte inputLen = 0;
		byte aadLen = 0;

        String outputStr;

		int ret = 0;

		if ((inputStr == null) || (inputStr.equals("null")) || (inputStr.equals("")))
			inputLen = 0;
		else
			inputLen = (byte)input.length;
			
        byte[] output = new byte[inputLen + macLen];

		if ((aadStr == null) || (aadStr.equals("null")) || (aadStr.equals("")))
			aadLen = 0;
		else
			aadLen = (byte)aad.length;

        ret = SEED_CCM_Encryption(output, input, inputLen, macLen, nonce, nonce.length, aad, aadLen, key);

        outputStr = getString(output);
        
        e_key = keyStr;
        e_nonce = nonceStr;
		e_aad = aadStr;
		e_mac_len = String.format("%d", macLen);
        e_in = inputStr;
        e_out = outputStr;

		if (ret == 0)
			e_ret = String.format("%d, Success!", ret);
		else
			e_ret = String.format("%d, Failure!", ret);
	}
}
else if ((method != null) && (method.equals("d")))
{
	byte[] key;
	String keyStr = request.getParameter("d_key");

	if (keyStr != null)
	{
		key = getBytes(keyStr);

        String inputStr = request.getParameter("d_in");
        byte[] input = getBytes(inputStr);
        String nonceStr = request.getParameter("d_nonce");
        byte[] nonce = getBytes(nonceStr);
        String aadStr = request.getParameter("d_aad");
        byte[] aad = getBytes(aadStr);
		byte macLen = (byte)Integer.parseInt(request.getParameter("d_mac_len"));
		byte inputLen = 0;
		byte aadLen = 0;

        String outputStr;

		int ret = 0;

		if ((inputStr == null) || (inputStr.equals("null")) || (inputStr.equals("")))
			inputLen = 0;
		else
			inputLen = (byte)input.length;

        byte[] output = new byte[inputLen - macLen];

		if ((aadStr == null) || (aadStr.equals("null")) || (aadStr.equals("")))
			aadLen = 0;
		else
			aadLen = (byte)aad.length;
        
        ret = SEED_CCM_Decryption(output, input, inputLen, macLen, nonce, nonce.length, aad, aadLen, key);
        
        outputStr = getString(output);

        d_key = keyStr;
        d_nonce = nonceStr;
		d_aad = aadStr;

		d_mac_len = String.format("%d", macLen);
        d_in = inputStr;
        d_out = outputStr;

		if (ret == 0)
			d_ret = String.format("%d, Correct!", ret);
		else
			d_ret = String.format("%d, Incorrect!", ret);
	}
}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CCM] 테스트 페이지</title>
<script type="text/javascript">
function encrypt()
{
	var frm = document.myform;
	document.getElementById("method").value = "e";
	frm.submit();
}

function decrypt()
{
	var frm = document.myform;
	document.getElementById("method").value = "d";
	frm.submit();
}
</script>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CCM] 테스트 페이지</h1>
<form name="myform" method="post" action="KISA_SEED_CCM_index.jsp">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="e_key" style="width:400px;height:100px;"><%=e_key %></textarea></td>
</tr>
<tr>
<td>초기값(NONCE) : </td> 
<td><textarea name="e_nonce" style="width:400px;height:100px;"><%=e_nonce %></textarea></td>
</tr>
<tr>
<td>추가인증데이터(AAD) : </td> 
<td><textarea name="e_aad" style="width:400px;height:100px;"><%=e_aad %></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="e_in" style="width:400px;height:100px;"><%=e_in %></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="e_mac_len" style="width:400px;height:20px;"><%=e_mac_len %></textarea></td>
</tr>
<tr>
<td></td>
<td><button onclick="encrypt();">▼ 암호화</button></td>
</tr>
<tr>
<td>암호문 : </td> 
<td><textarea name="e_out" style="width:400px;height:100px;"><%=e_out %></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="e_ret" style="width:400px;height:20px;"><%=e_ret %></textarea></td>
</tr>
</table>
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<table border="0">
<tr><td></td><td>&lt;복호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="d_key" style="width:400px;height:100px;"><%=d_key %></textarea></td>
</tr>
<tr>
<td>초기값(NONCE) : </td> 
<td><textarea name="d_nonce" style="width:400px;height:100px;"><%=d_nonce %></textarea></td>
</tr>
<tr>
<td>추가인증데이터(AAD) : </td> 
<td><textarea name="d_aad" style="width:400px;height:100px;"><%=d_aad %></textarea></td>
</tr>
<tr>
<td>암호문 : </td>
<td><textarea name="d_in" style="width:400px;height:100px;"><%=d_in %></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="d_mac_len" style="width:400px;height:20px;"><%=d_mac_len %></textarea></td>
</tr>
<tr>
<td></td>
<td><button onclick="decrypt();">▼ 복호화</button></td>
</tr>
<tr>
<td>복호문 : </td> 
<td><textarea name="d_out" style="width:400px;height:100px;"><%=d_out %></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="d_ret" style="width:400px;height:20px;"><%=d_ret %></textarea></td>
</tr>
</table>
</td>
</tr>
</table>
<div style="margin-top:20px;margin-bottom:20px;"><font color="#ff0000">※ 평문 및 암호문은 Hex 값의 0x를 제외하고 콤마로 구분하여 띄어쓰기 없이 입력합니다.(ex : 00,01,0A,0B)</font></div>
<div style="border: 1px solid #aaaaff; background-color:#ddddff;">
<table border="0">
<tr>
<td>&lt;키(KEY)&gt; : </td>
<td><% out.print("FC,58,7C,16,26,93,E6,CD,63,EE,D5,39,B5,7B,EA,09"); %></td>
</tr>
<tr>
<td>&lt;초기값(NONCE)&gt; : </td>
<td><% out.print("5C,85,10,0A,3E,69,01"); %></td>
</tr>
<tr>
<td>&lt;추가인증데이터(AAD)&gt; : </td>
<td><% out.print("9D,8C,A7,0D,69,A3,39,17,4D,30,24,E0,98,98,4C,88"); %></td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td><% out.print("7D,97,8C,51,C1,27,06,A7,B7,A3,B8,5D,6E,2C,51,3A"); %></td>
</tr>
<tr>
<td>&lt;인증값 길이&gt; : </td>
<td><% out.print("16"); %></td>
</tr>
<tr>
<td>&lt;암호문&gt; : </td>
<td><% out.print("47,71,D9,F2,50,3C,BF,EB,B2,00,CB,ED,10,22,42,EC,AA,CD,3A,5F,54,84,86,3C,AF,97,18,8D,7B,67,D0,05"); %></td>
</tr>
</table>
</div>
</form>
</center>
</body>
</html>