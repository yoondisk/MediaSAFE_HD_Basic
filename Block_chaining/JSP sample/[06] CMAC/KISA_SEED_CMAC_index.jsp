<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="KISA_SEED_CMAC.jsp" %>
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

String g_key = "";
String g_mac_len = "";
String g_in = "";
String g_mac = "";
String g_ret = "";

String v_key = "";
String v_mac_len = "";
String v_in = "";
String v_mac = "";
String v_ret = "";

if ((method != null) && (method.equals("g")))
{
	byte[] key;
	String keyStr = request.getParameter("g_key");

	if (keyStr != null)
	{
		key = getBytes(keyStr);

        String inputStr = request.getParameter("g_in");
        byte[] input = getBytes(inputStr);
		byte macLen = (byte)Integer.parseInt(request.getParameter("g_mac_len"));
		byte inputLen = 0;

        String macStr;

		int ret = 0;

		if ((inputStr == null) || (inputStr.equals("null")) || (inputStr.equals("")))
			inputLen = 0;
		else
			inputLen = (byte)input.length;
			
        byte[] mac = new byte[macLen];
		
		ret = SEED_Generate_CMAC(mac, macLen, input, inputLen, key);

        macStr = getString(mac);
        
        g_key = keyStr;
		g_mac_len = String.format("%d", macLen);
        g_in = inputStr;
        g_mac = macStr;

		if (ret == 0)
			g_ret = String.format("%d, Success!", ret);
		else
			g_ret = String.format("%d, Failure!", ret);
	}
}
else if ((method != null) && (method.equals("v")))
{
	byte[] key;
	String keyStr = request.getParameter("v_key");

	if (keyStr != null)
	{
		key = getBytes(keyStr);

        String inputStr = request.getParameter("v_in");
        byte[] input = getBytes(inputStr);
		String macStr = request.getParameter("v_mac");
		byte[] mac = getBytes(macStr);
		byte macLen = (byte)Integer.parseInt(request.getParameter("v_mac_len"));
		byte inputLen = 0;
		int ret = 0;

		if ((inputStr == null) || (inputStr.equals("null")) || (inputStr.equals("")))
			inputLen = 0;
		else
			inputLen = (byte)input.length;
        
        ret = SEED_Verify_CMAC(mac, macLen, input, inputLen, key);

        v_key = keyStr;

		v_mac_len = String.format("%d", macLen);
        v_in = inputStr;
        v_mac = macStr;

		if (ret == 0)
			v_ret = String.format("%d, Correct!", ret);
		else
			v_ret = String.format("%d, Incorrect!", ret);
	}
}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CMAC] 테스트 페이지</title>
<script type="text/javascript">
function generate()
{
	var frm = document.myform;
	document.getElementById("method").value = "g";
	frm.submit();
}

function verify()
{
	var frm = document.myform;
	document.getElementById("method").value = "v";
	frm.submit();
}
</script>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CMAC] 테스트 페이지</h1>
<form name="myform" method="post" action="KISA_SEED_CMAC_index.jsp">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<table border="0">
<tr><td></td><td>&lt;MAC 생성 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="g_key" style="width:400px;height:100px;"><%=g_key %></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="g_in" style="width:400px;height:100px;"><%=g_in %></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="g_mac_len" style="width:400px;height:20px;"><%=g_mac_len %></textarea></td>
</tr>
<tr>
<td></td>
<td><button onclick="generate();">▼ MAC 생성</button></td>
</tr>
<tr>
<td>MAC : </td> 
<td><textarea name="g_mac" style="width:400px;height:100px;"><%=g_mac %></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="g_ret" style="width:400px;height:20px;"><%=g_ret %></textarea></td>
</tr>
</table>
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<table border="0">
<tr><td></td><td>&lt;MAC 검증 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="v_key" style="width:400px;height:100px;"><%=v_key %></textarea></td>
</tr>
<tr>
<td>평문 : </td> 
<td><textarea name="v_in" style="width:400px;height:100px;"><%=v_in %></textarea></td>
</tr>
<tr>
<td>MAC : </td>
<td><textarea name="v_mac" style="width:400px;height:100px;"><%=v_mac %></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="v_mac_len" style="width:400px;height:20px;"><%=v_mac_len %></textarea></td>
</tr>
<tr>
<td></td>
<td><button onclick="verify();">▼ MAC 검증</button></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="v_ret" style="width:400px;height:20px;"><%=v_ret %></textarea></td>
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
<td><% out.print("B9,28,C9,8B,08,37,E8,87,45,2C,42,0E,36,07,E7,B9"); %></td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td><% out.print(""); %></td>
</tr>
<tr>
<td>&lt;인증값 길이&gt; : </td>
<td><% out.print("16"); %></td>
</tr>
<tr>
<td>&lt;MAC&gt; : </td>
<td><% out.print("6A,6F,37,8E,CF,4B,CB,F4,F8,A1,69,13,2E,D8,38,13"); %></td>
</tr>
</table>
</div>
</form>
</center>
</body>
</html>