<%@page contentType="text/html; charset=UTF-8" %>
<%@page pageEncoding="UTF-8" %>
<%@ include file="./seed/KISA_SEED_CBC.jsp" %>
<%@ include file="./seed/SEED_FUNCTION.jsp" %>
<%

byte bszUser_key[] = {
		(byte)0x088, (byte)0x0e3, (byte)0x04f, (byte)0x08f,
		(byte)0x008, (byte)0x017, (byte)0x079, (byte)0x0f1,
		(byte)0x0e9, (byte)0x0f3, (byte)0x094, (byte)0x037,
		(byte)0x00a, (byte)0x0d4, (byte)0x005, (byte)0x089
};
byte bszIV[] = {
		(byte)0x026, (byte)0x08d, (byte)0x066, (byte)0x0a7,
		(byte)0x035, (byte)0x0a8, (byte)0x01a, (byte)0x081,
		(byte)0x06f, (byte)0x0ba, (byte)0x0d9, (byte)0x0fa,
		(byte)0x036, (byte)0x016, (byte)0x025, (byte)0x001
};

	
String url_org="http://openos.yoondisk.co.kr/test1_1080.mp4";


String encstring=encrypt(bszIV,bszUser_key,url_org);
String decstring=decrypt(bszIV,bszUser_key,encstring);




%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CBC] </title>
</head>
<body>
<center>
<h1>[YoonDisk] [SEED-CBC] JSP URL 암호화 데모</h1>
<p><font color=red>*. 동영상 URL 암호화 처리 [새로고침시 암호화된 encstring 는 계속 값이 변함]</font>
<p>1. <b>url_org</b> => <%=url_org%>
<p>2. encstring => <b><%=encstring%></b>
<p>3. decstring => <%=decstring%>
</center>
</body>
</html>