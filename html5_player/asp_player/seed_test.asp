<%@Language="VBScript" CODEPAGE="65001" %>
<%
Response.CharSet="utf-8"
Session.codepage="65001"
Response.codepage="65001"
Response.ContentType="text/html;charset=utf-8"
%>
<!--#include file="seed/KISA_SEED_CBC.asp" -->
<!--#include file="seed/SEED_FUNCTION.asp" -->
<%

Dim g_bszUser_key
Dim g_bszIV 
Dim url_org
Dim encstring
Dim decstring

' 암화화 key,iv 선언.
g_bszUser_key = "88,E3,4F,8F,08,17,79,F1,E9,F3,94,37,0A,D4,05,89"
g_bszIV = "26,8D,66,A7,35,A8,1A,81,6F,BA,D9,FA,36,16,25,01"


url_org="rtsp://openosmp4.yoondisk.co.kr/1080"

encstring = encrypt(g_bszIV,g_bszUser_key,url_org)

decstring = decrypt(g_bszIV,g_bszUser_key,encstring)

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CBC] </title>
</head>
<body>
<center>
<h1>[YoonDisk] [SEED-CBC] ASP URL 암호화 데모</h1>
<p><font color=red>*. 동영상 URL 암호화 처리 [새로고침시 암호화된 encstring 는 계속 값이 변함]</font>
<p>1. <b>url_org</b> => <%=url_org%>
<p>2. encstring => <b><%=encstring%></b>
<p>3. decstring => <%=decstring%>
</center>
</body>
</html>