<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="EUC-KR"%>
<%@ include file="KISA_SEED_CTR.jsp" %>
<%!
public byte[] getBytes(String data) {
	String[] str = data.split(",");
	byte[] result = new byte[str.length];
	for(int i=0; i<result.length; i++) {
		result[i] = getHex(str[i]);
	}
	return result;
}

public String getString(byte[] data) {
	String result = "";
	for(int i=0; i<data.length; i++) {
		result = result + toHex(data[i]);
		if(i<data.length-1)
			result = result + ",";
	}
	return result;
}

public byte getHex(String str) {
	str = str.trim();
	if(str.length() == 0)
		str = "00";
	else if(str.length() == 1)
		str = "0" + str;
	
	str = str.toUpperCase();
	return (byte)(getHexNibble(str.charAt(0)) * 16 + getHexNibble(str.charAt(1)));
}

public byte getHexNibble(char c) {
	if(c >= '0' && c<='9')
		return (byte)(c - '0');
	if(c >= 'A' && c<='F')
		return (byte)(c - 'A' + 10);
	return 0;
}

public String toHex(int b) {
	char c[] = new char[2];
	c[0] = toHexNibble((b>>4) & 0x0f);
	c[1] = toHexNibble(b & 0x0f);
	return new String(c);
}

public char toHexNibble(int b) {
	if(b >= 0 && b <= 9)
		return (char)(b + '0');
	if(b >= 0x0a && b <= 0x0f)
		return (char)(b + 'A' - 10);
	return '0';
}
%>

<%
byte bszUser_key[] = {
		(byte)0x088, (byte)0x0e3, (byte)0x04f, (byte)0x08f,
		(byte)0x008, (byte)0x017, (byte)0x079, (byte)0x0f1,
		(byte)0x0e9, (byte)0x0f3, (byte)0x094, (byte)0x037,
		(byte)0x00a, (byte)0x0d4, (byte)0x005, (byte)0x089
};

byte bszCounter[] = {
		(byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00,
		(byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00,
		(byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00,
		(byte)0x00, (byte)0x00, (byte)0x00, (byte)0xfe
};


byte defaultPlainText[] = {
		(byte)0x00, (byte)0x01, (byte)0x02, (byte)0x03, (byte)0x04, (byte)0x05, (byte)0x06, (byte)0x07, (byte)0x08, (byte)0x09, (byte)0x0a, (byte)0x0b, (byte)0x0c, (byte)0x0d, (byte)0x0e, (byte)0x0f
};
byte[] defaultCipherText = SEED_CTR_Encrypt(bszUser_key, bszCounter, defaultPlainText, 0, defaultPlainText.length);


// method 1 start
String method = request.getParameter("method");
String encrypt_key = "";
String encrypt_Counter = "";
String encrypt_plainText = "";
String encrypt_cipherText = "";
String decrypt_key = "";
String decrypt_Counter = "";
String decrypt_plainText = "";
String decrypt_cipherText = "";
if(method != null && method.equals("e")) {
	byte[] key;
	String KeyStr = request.getParameter("encrypt_key");
	if (KeyStr == null)
	{
		key = bszUser_key;
	}
	else {
		key = getBytes(KeyStr);
	}
	byte[] Counter;
	String CounterStr = request.getParameter("encrypt_Counter");
	if (CounterStr == null)
	{
		Counter = bszCounter;
	}
	else {
		Counter = getBytes(CounterStr);
	}
	String plainTextStr = request.getParameter("encrypt_plainText");
	byte[] plainText = getBytes(plainTextStr);
	String cipherTextStr = getString(SEED_CTR_Encrypt(key, Counter, plainText, 0, plainText.length));
	
	encrypt_key = KeyStr;
	encrypt_Counter = CounterStr;
	encrypt_plainText = plainTextStr;
	encrypt_cipherText = cipherTextStr;
}
else if(method != null && method.equals("d")) {
	byte[] key;
	String KeyStr = request.getParameter("decrypt_key");
	if (KeyStr == null)
	{
		key = bszUser_key;
	}
	else {
		key = getBytes(KeyStr);
	}
	byte[] Counter;
	String CounterStr = request.getParameter("decrypt_Counter");
	if (CounterStr == null)
	{
		Counter = bszCounter;
	}
	else {
		Counter = getBytes(CounterStr);
	}
	String cipherTextStr = request.getParameter("decrypt_cipherText");
	byte[] cipherText = getBytes(cipherTextStr);
	String plainTextStr = getString(SEED_CTR_Decrypt(key, Counter, cipherText, 0, cipherText.length));
	
	decrypt_key = KeyStr;
	decrypt_Counter = CounterStr;
	decrypt_plainText = plainTextStr;
	decrypt_cipherText = cipherTextStr;
	
}
//method 1 end

/*
// method 2 start
String method = request.getParameter("method");
String encrypt_key = "";
String encrypt_Counter = "";
String encrypt_plainText = "";
String encrypt_cipherText = "";
String decrypt_key = "";
String decrypt_Counter = "";
String decrypt_plainText = "";
String decrypt_cipherText = "";
if(method != null && method.equals("e")) {
	byte[] key;
	String KeyStr = request.getParameter("encrypt_key");
	if (KeyStr == null)
	{
		key = bszUser_key;
	}
	else {
		key = getBytes(KeyStr);
	}
	byte[] Counter;
	String CounterStr = request.getParameter("encrypt_Counter");
	if (CounterStr == null)
	{
		Counter = bszCounter;
	}
	else {
		Counter = getBytes(CounterStr);
	}
	String plainTextStr = request.getParameter("encrypt_plainText");
	byte[] plainText = getBytes(plainTextStr);
	
	KISA_SEED_INFO info = new KISA_SEED_INFO();
	int message_length = plainText.length; 
	
	int process_blockLeng = 32;
	int[] outbuf = new int[process_blockLeng];
	
	SEED_CTR_init( info, KISA_ENC_DEC.KISA_ENCRYPT, key, Counter );
		
	int i;
	int[] data;
	byte[] cdata;
	int nRetOutLeng[] = new int[] { 0 };
	int nEncRmainLeng[] = new int[] { 0 };
	byte[] pbszPlainText = new byte[process_blockLeng];
	byte[] pbszCipherText = new byte[message_length];
	
	for (i = 0; i < message_length - process_blockLeng; )
	{
		arraycopy_system(plainText, i, pbszPlainText, 0, process_blockLeng);
		data = chartoint32_for_SEED_CTR(pbszPlainText, process_blockLeng);
		SEED_CTR_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );
		cdata = int32tochar_for_SEED_CTR(outbuf, nRetOutLeng[0]);
		arraycopy_system(cdata, 0, pbszCipherText, i, nRetOutLeng[0]);
		i += nRetOutLeng[0];
	}
	
	int remainleng = message_length % process_blockLeng;
	if (remainleng == 0)
	{
		remainleng = process_blockLeng;
	}
	arraycopy_system(plainText, i, pbszPlainText, 0, remainleng);
	data = chartoint32_for_SEED_CTR(pbszPlainText, remainleng);
	SEED_CTR_Process( info, data, remainleng, outbuf, nRetOutLeng );
	SEED_CTR_Close( info, outbuf, nRetOutLeng[0], nEncRmainLeng );
	cdata = int32tochar_for_SEED_CTR(outbuf, nRetOutLeng[0] - nEncRmainLeng[0]); 
	arraycopy_system(cdata, 0, pbszCipherText, i, nRetOutLeng[0] - nEncRmainLeng[0]);
	
	data = null;
	cdata = null;
	outbuf = null;
	
	encrypt_key = KeyStr;
	encrypt_Counter = CounterStr;
	encrypt_plainText = plainTextStr;
	encrypt_cipherText = getString(pbszCipherText);
}
else if(method != null && method.equals("d")) {
	byte[] key;
	String KeyStr = request.getParameter("decrypt_key");
	if (KeyStr == null)
	{
		key = bszUser_key;
	}
	else {
		key = getBytes(KeyStr);
	}
	byte[] Counter;
	String CounterStr = request.getParameter("decrypt_Counter");
	if (CounterStr == null)
	{
		Counter = bszCounter;
	}
	else {
		Counter = getBytes(CounterStr);
	}
	String cipherTextStr = request.getParameter("decrypt_cipherText");
	byte[] cipherText = getBytes(cipherTextStr);
	KISA_SEED_INFO info = new KISA_SEED_INFO();
	int message_length = cipherText.length; 
	
	int process_blockLeng = 32;
	int[] outbuf = new int[process_blockLeng];
	
	SEED_CTR_init( info, KISA_ENC_DEC.KISA_ENCRYPT, key, Counter );
		
	int i;
	int[] data;
	byte[] cdata;
	int nRetOutLeng[] = new int[] { 0 };
	int nEncRmainLeng[] = new int[] { 0 };
	byte[] pbszCipherText = new byte[process_blockLeng];
	byte[] pbszPlainText = new byte[message_length];
	
	for (i = 0; i < message_length - process_blockLeng; )
	{
		arraycopy_system(cipherText, i, pbszCipherText, 0, process_blockLeng);
		data = chartoint32_for_SEED_CTR(pbszCipherText, process_blockLeng);
		SEED_CTR_Process( info, data, process_blockLeng, outbuf, nRetOutLeng );
		cdata = int32tochar_for_SEED_CTR(outbuf, nRetOutLeng[0]);
		arraycopy_system(cdata, 0, pbszPlainText, i, nRetOutLeng[0]);
		i += nRetOutLeng[0];
	}
	
	int remainleng = message_length % process_blockLeng;
	if (remainleng == 0)
	{
		remainleng = process_blockLeng;
	}
	arraycopy_system(cipherText, i, pbszCipherText, 0, remainleng);
	data = chartoint32_for_SEED_CTR(pbszCipherText, remainleng);
	SEED_CTR_Process( info, data, remainleng, outbuf, nRetOutLeng );
	SEED_CTR_Close( info, outbuf, nRetOutLeng[0], nEncRmainLeng );
	cdata = int32tochar_for_SEED_CTR(outbuf, nRetOutLeng[0] - nEncRmainLeng[0]); 
	arraycopy_system(cdata, 0, pbszPlainText, i, nRetOutLeng[0] - nEncRmainLeng[0]);
	
	data = null;
	cdata = null;
	outbuf = null;
	
	
	decrypt_key = KeyStr;
	decrypt_Counter = CounterStr;
	decrypt_plainText = getString(pbszPlainText);
	decrypt_cipherText = cipherTextStr;
	
}
//method 2 end
*/
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>SEED CTR Example</title>
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
<h1>국산 암호 [SEED-CTR] 테스트 페이지</h1>
<form name="myform" method="post" action="index.jsp">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="encrypt_key" style="width:400px;height:100px;"><%=encrypt_key %></textarea></td>
</tr>
<tr>
<td>초기카운터(Ctr) : </td> 
<td><textarea name="encrypt_Counter" style="width:400px;height:100px;"><%=encrypt_Counter %></textarea></td>
</tr>
<tr>
<td>평문 : </td> 
<td><textarea name="encrypt_plainText" style="width:400px;height:100px;"><%=encrypt_plainText %></textarea></td>
</tr>
<tr>
<td></td>
<td><button onclick="encrypt();">▼암호화</button></td>
</tr>
<tr>
<td>암호문 : </td> 
<td><textarea name="encrypt_cipherText" style="width:400px;height:100px;"><%=encrypt_cipherText %></textarea></td>
</tr>
</table>
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<table border="0">
<tr><td></td><td>&lt;복호화 예제&gt;</td></tr>
<tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="decrypt_key" style="width:400px;height:100px;"><%=decrypt_key %></textarea></td>
</tr>
<tr>
<td>초기카운터(Ctr) : </td> 
<td><textarea name="decrypt_Counter" style="width:400px;height:100px;"><%=decrypt_Counter %></textarea></td>
</tr>
<tr>
<td>암호문 : </td>
<td><textarea name="decrypt_cipherText" style="width:400px;height:100px;"><%=decrypt_cipherText %></textarea></td>
</tr>
<tr>
<td></td>
<td><button onclick="decrypt();">▼복호화</button></td>
</tr>
<tr>
<td>평문 : </td> 
<td><textarea name="decrypt_plainText" style="width:400px;height:100px;"><%=decrypt_plainText %></textarea></td>
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
<td><% out.print(getString(bszUser_key)); %></td>
</tr>
<tr>
<td>&lt;초기카운터(Ctr)&gt; : </td>
<td><% out.print(getString(bszCounter)); %></td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td><% out.print(getString(defaultPlainText)); %></td>
</tr>
<tr>
<td>&lt;암호문&gt; : </td>
<td><% out.print(getString(defaultCipherText)); %></td>
</tr>
</table>
</div>
</form>

</center>
</body>
</html>