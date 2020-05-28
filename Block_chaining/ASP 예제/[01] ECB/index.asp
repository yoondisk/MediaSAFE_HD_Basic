<!--#include file="KISA_SEED_ECB.asp" -->
<%response.Charset = "utf-8"%>
<%

enc = Trim(request.form("ENC"))
dec = Trim(request.form("DEC"))
g_pbUserKey = Trim(request.form("KEY"))
Dim arrEnc
Dim arrDec
dim sampleData1
dim sampleData2
Dim enc2
Dim dec2
Dim arrKey
If(IsNull(g_pbUserKey) Or Len(Trim(g_pbUserKey))=0) Then
g_pbUserKey = "2B,7E,15,16,28,AE,D2,A6,AB,F7,15,88,09,CF,4F,3C"
End if

If(IsNull(enc) Or Len(Trim(enc))=0) Then

Else

	arrEnc = split(enc,",")
	redim sampleData1(ubound(arrEnc))

	for i=0 to (ubound(arrEnc))
		sampleData1(i) = (Cbyte)("&H" & (right("0000" & arrEnc(i), 4)))
	Next
	arrKey = split(g_pbUserKey,",")
	redim sampleKey1(ubound(arrKey))

	for i=0 to (ubound(arrKey))
		sampleKey1(i) = (Cbyte)("&H" & (right("0000" & arrKey(i), 4)))
	Next
	enc2 = test1(sampleData1,sampleKey1)

End If

If(IsNull(dec) Or Len(Trim(dec))=0) Then

Else
	arrDec = split(dec,",")
	redim sampleData2(ubound(arrDec))

	for i=0 to (ubound(arrDec))
		sampleData2(i) = (Cbyte)("&H" & (right("0000" & arrDec(i), 4)))
	Next
	arrKey = split(g_pbUserKey,",")
	redim sampleKey1(ubound(arrKey))

	for i=0 to (ubound(arrKey))
		sampleKey1(i) = (Cbyte)("&H" & (right("0000" & arrKey(i), 4)))
	Next
	dec2 = test2(sampleData2,sampleKey1)

End If



function test1(bszPlainText,g_bszUser_key)
	Dim i
	Dim bszChiperText
	Dim temp

	'방법1
	bszChiperText = KISA_SEED_ECB.SEED_ECB_Encrypt(g_bszUser_key, bszPlainText, 0, UBound(bszPlainText)+1)
	for i=0 to (UBound(bszChiperText))
		temp = temp & Right("0000" & hex(bszChiperText(i)), 2)
		If(i <> UBound(bszChiperText)) then
			temp = temp & ","
		End if
	Next

	test1 = temp

'	'방법2
'	Dim info
'	Dim outbuf
'	Dim data
'	Dim cdata
'	Dim outlen
'	Dim nRetOutLeng
'	Dim nPaddingLeng
'	Dim message_length
'	Dim process_blockLeng
'	Dim remainleng
'
'	Set info = new KISA_SEED_INFO_4ECB
'	outlen = 0
'	nRetOutLeng = 0
'	nPaddingLeng = 0
'	process_blockLeng = 32
'
'	Dim newpbszPlainText
'
'	message_length = UBound(bszPlainText)+1
'	
'	nPlainTextPadding = KISA_SEED_ECB.BLOCK_SIZE_SEED - (DMOD(message_length,KISA_SEED_ECB.BLOCK_SIZE_SEED))
'
'	ReDim newpbszPlainText(process_blockLeng-1)
'	
'	ReDim bszChiperText(message_length + nPlainTextPadding -1)
'	
'	outlen = process_blockLeng/4
'	ReDim outbuf(outlen-1)
'	Call arrayinit(outbuf, 0, outlen)
'
'	Call KISA_SEED_ECB.SEED_ECB_init( info, KISA_SEED_ECB.KISA_ENCRYPT, g_bszUser_key )
'
'	i = 0
'	Do While (i< message_length - process_blockLeng)
'		Call arraycopy_system(bszPlainText, i, newpbszPlainText, 0, process_blockLeng)
'		data = KISA_SEED_ECB.chartoint32_for_SEED_ECB(newpbszPlainText, process_blockLeng)
'		Call KISA_SEED_ECB.SEED_ECB_Process( info, data, process_blockLeng, outbuf, nRetOutLeng )
'		cdata = KISA_SEED_ECB.int32tochar_for_SEED_ECB(outbuf, nRetOutLeng)
'		Call arraycopy_system(cdata, 0, bszChiperText, i, nRetOutLeng )
'		i = i + nRetOutLeng
'		
'	Loop
'
'	remainleng = DMOD(message_length, process_blockLeng)
'	If remainleng = 0 Then 
'		remainleng = process_blockLeng
'	End If
'	Call arraycopy_system(bszPlainText, i, newpbszPlainText, 0, remainleng)
'	data = KISA_SEED_ECB.chartoint32_for_SEED_ECB(newpbszPlainText, remainleng)
'	Call KISA_SEED_ECB.SEED_ECB_Process( info, data, remainleng, outbuf, nRetOutLeng )
'	cdata = KISA_SEED_ECB.int32tochar_for_SEED_ECB(outbuf, nRetOutLeng)
'	Call arraycopy_system(cdata, 0, bszChiperText, i, nRetOutLeng )
'	
'	i = i + nRetOutLeng
'
'	Call KISA_SEED_ECB.SEED_ECB_Close( info, outbuf, 0, nPaddingLeng )
'	cdata = KISA_SEED_ECB.int32tochar_for_SEED_ECB(outbuf, nPaddingLeng)
'	Call arraycopy_system(cdata, 0, bszChiperText, i, nPaddingLeng )
'
'	for i=0 to (UBound(bszChiperText))
'		temp = temp & Right("0000" & hex(bszChiperText(i)), 2)
'		If(i <> UBound(bszChiperText)) then
'			temp = temp & ","
'		End if
'	Next
'
'	test1 = temp

end function

function test2(bszChiperText,g_bszUser_key)
	Dim i
	Dim bszPlainText
	Dim temp

	'방법 1
	bszPlaintext = KISA_SEED_ECB.SEED_ECB_Decrypt(g_bszUser_key, bszChiperText, 0, UBound(bszChiperText)+1)
	If isnull(bszPlaintext) Then
	else
	for i=0 to (UBound(bszPlaintext))
		temp = temp & Right("0000" & hex(bszPlaintext(i)), 2)
		If(i <> UBound(bszPlaintext)) then
			temp = temp & ","
		End if
	Next
	End if
	test2 = temp

'	'방법2
'	Dim info
'	Dim outbuf
'	Dim data
'	Dim cdata
'	Dim outlen
'	Dim nRetOutLeng
'	Dim nPaddingLeng
'	Dim message_length
'	Dim process_blockLeng
'	Dim remainleng
'
'	Set info = new KISA_SEED_INFO_4ECB
'	outlen = 0
'	nRetOutLeng = 0
'	nPaddingLeng = 0
'	process_blockLeng = 32
'
'	Dim newpbszChiperText
'
'	message_length = UBound(bszChiperText)+1
'
'	If DMOD(message_length,KISA_SEED_ECB.BLOCK_SIZE_SEED) >0 Then
'		test2 = temp
'		Exit Function
'	End if
'	
'	ReDim newpbszChiperText(process_blockLeng-1)
'
'	ReDim bszPlaintext(message_length-1)
'	
'	outlen = process_blockLeng/4
'	ReDim outbuf(outlen-1)
'	Call arrayinit(outbuf, 0, outlen)
'
'	Call KISA_SEED_ECB.SEED_ECB_init( info, KISA_SEED_ECB.KISA_DECRYPT, g_bszUser_key )
'
'	i = 0
'	Do While (i< message_length - process_blockLeng)
'		Call arraycopy_system(bszChiperText, i, newpbszChiperText, 0, process_blockLeng)
'		data = KISA_SEED_ECB.chartoint32_for_SEED_ECB(newpbszChiperText, process_blockLeng)
'		Call KISA_SEED_ECB.SEED_ECB_Process( info, data, process_blockLeng, outbuf, nRetOutLeng )
'		cdata = KISA_SEED_ECB.int32tochar_for_SEED_ECB(outbuf, nRetOutLeng)
'		Call arraycopy_system(cdata, 0, bszPlaintext, i, nRetOutLeng )
'		i = i + nRetOutLeng
'	Loop
'
'	remainleng = DMOD(message_length, process_blockLeng)
'	If remainleng = 0 Then 
'		remainleng = process_blockLeng
'	End If
'	Call arraycopy_system(bszChiperText, i, newpbszChiperText, 0, remainleng)
'	data = KISA_SEED_ECB.chartoint32_for_SEED_ECB(newpbszChiperText, remainleng)
'	Call KISA_SEED_ECB.SEED_ECB_Process( info, data, remainleng, outbuf, nRetOutLeng )
'
'	if	KISA_SEED_ECB.SEED_ECB_Close( info, outbuf, nRetOutLeng, nPaddingLeng ) > 0 then 
'		cdata = KISA_SEED_ECB.int32tochar_for_SEED_ECB(outbuf, remainleng- nPaddingLeng)
'		Call arraycopy_system(cdata, 0, bszPlaintext, i, remainleng - nPaddingLeng )
'		message_length = i+ remainleng - nPaddingLeng-1
'
'		for i=0 to message_length
'			temp = temp & Right("0000" & hex(bszPlaintext(i)), 2)
'			If (i <> message_length) Then
'				temp = temp & ","
'			End if
'		Next
'	End if
'
'	test2 = temp

end function

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - ECB] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-ECB] 테스트 페이지</h1>
<form name="myform" method="post" action="./index.asp">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<form method="post" action="./index.asp">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="KEY" style="width:400px;height:100px;"><%=g_pbUserKey%></textarea></td>
</tr>
<tr>
<td>평문 : </td> 
<td><textarea name="ENC" style="width:400px;height:100px;"><%=enc%></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ 암호화"> </td>
</tr>

<tr>
<td>암호문 : </td> 
<td><textarea name="ENC2" style="width:400px;height:100px;"><%=enc2%></textarea></td>
</tr>
</table>
</form>	
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<form method="post" action="./index.asp">
<table border="0">
<tr><td></td><td>&lt;복호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="KEY" style="width:400px;height:100px;"><%=g_pbUserKey%></textarea></td>
</tr>
<tr>
<td>암호문 : </td> 
<td><textarea name="DEC" style="width:400px;height:100px;"><%=dec%></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ 복호화"></td>
</tr>
<tr>
<td>평문 : </td> 
<td><textarea name="DEC2" style="width:400px;height:100px;"><%=dec2%></textarea></td>
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
<td>2B,7E,15,16,28,AE,D2,A6,AB,F7,15,88,09,CF,4F,3C</td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td>00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F</td>
</tr>
<tr>
<td>&lt;암호문&gt; : </td>
<TD>F7,A5,AB,AA,86,9B,E1,1E,C1,D0,3B,BA,92,76,A1,64,AD,6C,74,B7,08,D1,CA,7E,B1,AA,FF,31,96,34,C6,02</TD>
</tr>
</table>
</div>
</form>

</center>
</body>
</html>