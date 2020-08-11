<!--#include file="KISA_SEED_CTR.asp" -->
<%response.Charset = "utf-8"%>
<%

enc = Trim(request.form("ENC"))
dec = Trim(request.form("DEC"))
g_bszUser_key = Trim(request.form("KEY"))
g_bszCounter = Trim(request.form("CTR"))
Dim arrEnc
Dim arrDec
dim sampleData1
dim sampleData2
Dim enc2
Dim dec2
If(IsNull(g_bszUser_key) Or Len(Trim(g_bszUser_key))=0) Then
g_bszUser_key = "88,E3,4F,8F,08,17,79,F1,E9,F3,94,37,0A,D4,05,89"
End If

If(IsNull(g_bszCounter) Or Len(Trim(g_bszCounter))=0) Then
g_bszCounter = "00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FE"
End If

If(IsNull(enc) Or Len(Trim(enc))=0) Then

Else

	arrEnc = split(enc,",")
	redim sampleData1(ubound(arrEnc))

	for i=0 to (ubound(arrEnc))
		sampleData1(i) = (Cbyte)("&H" & (right("0000" & arrEnc(i), 4)))
	Next

	arrKey = split(g_bszUser_key,",")
	redim sampleKey1(ubound(arrKey))

	for i=0 to (ubound(arrKey))
		sampleKey1(i) = (Cbyte)("&H" & (right("0000" & arrKey(i), 4)))
	Next
	arrCTR = split(g_bszCounter,",")
	redim sampleCTR1(ubound(arrCTR))

	for i=0 to (ubound(arrCTR))
		sampleCTR1(i) = (Cbyte)("&H" & (right("0000" & arrCTR(i), 4)))
	Next
	
	enc2 = test1(sampleData1,sampleKey1,sampleCTR1)

End If

If(IsNull(dec) Or Len(Trim(dec))=0) Then

Else
	arrDec = split(dec,",")
	redim sampleData2(ubound(arrDec))

	for i=0 to (ubound(arrDec))
		sampleData2(i) = (Cbyte)("&H" & (right("0000" & arrDec(i), 4)))
	Next

	arrKey = split(g_bszUser_key,",")
	redim sampleKey1(ubound(arrKey))

	for i=0 to (ubound(arrKey))
		sampleKey1(i) = (Cbyte)("&H" & (right("0000" & arrKey(i), 4)))
	Next
	arrCTR = split(g_bszCounter,",")
	redim sampleCTR1(ubound(arrCTR))

	for i=0 to (ubound(arrCTR))
		sampleCTR1(i) = (Cbyte)("&H" & (right("0000" & arrCTR(i), 4)))
	Next

	dec2 = test2(sampleData2,sampleKey1,sampleCTR1)

End If

function test1(bszPlainText,g_bszUser_key,g_bszCounter)
	Dim i
	Dim bszChiperText
	Dim temp
	
	'방법1
	bszChiperText = KISA_SEED_CTR.SEED_CTR_Encrypt(g_bszUser_key, g_bszCounter, bszPlainText, 0, UBound(bszPlainText)+1)

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
'	Dim EncRmainLeng
'	Dim message_length
'	Dim process_blockLeng
'	Dim remainleng
'	Dim nPlainTextPadding
'
'	Set info = new KISA_SEED_INFO_4CTR
'	outlen = 0
'	nRetOutLeng = 0
'	EncRmainLeng = 0
'	process_blockLeng = 32
'
'	Dim newpbszPlainText
'
'	message_length = UBound(bszPlainText)+1
'
'	nPlainTextPadding = KISA_SEED_CTR.BLOCK_SIZE_CTR - (DMOD(message_length,KISA_SEED_CTR.BLOCK_SIZE_CTR))
'
'	ReDim newpbszPlainText(process_blockLeng-1)
'
'	ReDim bszChiperText(message_length + nPlainTextPadding -1)
'	
'	outlen = process_blockLeng/4
'	ReDim outbuf(outlen-1)
'	Call arrayinit(outbuf, 0, outlen)
'
'	Call KISA_SEED_CTR.SEED_CTR_init( info, KISA_SEED_CTR.KISA_ENCRYPT, g_bszUser_key, g_bszCounter )
'
'	i = 0
'	Do While (i< message_length - process_blockLeng)
'		Call arraycopy_system(bszPlainText, i, newpbszPlainText, 0, process_blockLeng)
'		data = KISA_SEED_CTR.chartoint32_for_SEED_CTR(newpbszPlainText, process_blockLeng)
'		Call KISA_SEED_CTR.SEED_CTR_Process( info, data, process_blockLeng, outbuf, nRetOutLeng )
'		cdata = KISA_SEED_CTR.int32tochar_for_SEED_CTR(outbuf, nRetOutLeng)
'		Call arraycopy_system(cdata, 0, bszChiperText, i, nRetOutLeng )
'		i = i + nRetOutLeng
'	Loop
'
'	remainleng = DMOD(message_length, process_blockLeng)
'	If remainleng = 0 Then 
'		remainleng = process_blockLeng
'	End If
'	Call arraycopy_system(bszPlainText, i, newpbszPlainText, 0, remainleng)
'	data = KISA_SEED_CTR.chartoint32_for_SEED_CTR(newpbszPlainText, remainleng)
'	Call KISA_SEED_CTR.SEED_CTR_Process( info, data, remainleng, outbuf, nRetOutLeng )
'	Call KISA_SEED_CTR.SEED_CTR_Close( info, outbuf, nRetOutLeng, EncRmainLeng )
'	cdata = KISA_SEED_CTR.int32tochar_for_SEED_CTR(outbuf, nRetOutLeng - EncRmainLeng)
'	Call arraycopy_system(cdata, 0, bszChiperText, i, nRetOutLeng - EncRmainLeng )
'	message_length = i+ remainleng - nPaddingLeng-1
'
'	for i=0 to message_length
'		temp = temp & Right("0000" & hex(bszChiperText(i)), 2)
'		If(i <> message_length) then
'			temp = temp & ","
'		End if
'	Next
'
'	test1 = temp

end function

function test2(bszPlainText,g_bszUser_key,g_bszCounter)
	Dim i
	Dim bszChiperText
	Dim temp
	
	'방법1
	bszChiperText = KISA_SEED_CTR.SEED_CTR_Encrypt(g_bszUser_key, g_bszCounter, bszPlainText, 0, UBound(bszPlainText)+1)

	for i=0 to (UBound(bszChiperText))
		temp = temp & Right("0000" & hex(bszChiperText(i)), 2)
		If(i <> UBound(bszChiperText)) then
			temp = temp & ","
		End if
	Next

	test2 = temp

'	'방법2
'	Dim info
'	Dim outbuf
'	Dim data
'	Dim cdata
'	Dim outlen
'	Dim nRetOutLeng
'	Dim EncRmainLeng
'	Dim message_length
'	Dim process_blockLeng
'	Dim remainleng
'	Dim nPlainTextPadding
'
'	Set info = new KISA_SEED_INFO_4CTR
'	outlen = 0
'	nRetOutLeng = 0
'	EncRmainLeng = 0
'	process_blockLeng = 32
'
'	Dim newpbszPlainText
'
'	message_length = UBound(bszPlainText)+1
'
'	nPlainTextPadding = KISA_SEED_CTR.BLOCK_SIZE_CTR - (DMOD(message_length,KISA_SEED_CTR.BLOCK_SIZE_CTR))
'
'	ReDim newpbszPlainText(process_blockLeng-1)
'	
'
'	ReDim bszChiperText(message_length + nPlainTextPadding -1)
'	
'	outlen = process_blockLeng/4
'	ReDim outbuf(outlen-1)
'	Call arrayinit(outbuf, 0, outlen)
'
'	Call KISA_SEED_CTR.SEED_CTR_init( info, KISA_SEED_CTR.KISA_ENCRYPT, g_bszUser_key, g_bszCounter )
'
'	i = 0
'	Do While (i< message_length - process_blockLeng)
'		Call arraycopy_system(bszPlainText, i, newpbszPlainText, 0, process_blockLeng)
'		data = KISA_SEED_CTR.chartoint32_for_SEED_CTR(newpbszPlainText, process_blockLeng)
'		Call KISA_SEED_CTR.SEED_CTR_Process( info, data, process_blockLeng, outbuf, nRetOutLeng )
'		cdata = KISA_SEED_CTR.int32tochar_for_SEED_CTR(outbuf, nRetOutLeng)
'		Call arraycopy_system(cdata, 0, bszChiperText, i, nRetOutLeng )
'		i = i + nRetOutLeng
'	Loop
'
'	remainleng = DMOD(message_length, process_blockLeng)
'	If remainleng = 0 Then 
'		remainleng = process_blockLeng
'	End If
'	Call arraycopy_system(bszPlainText, i, newpbszPlainText, 0, remainleng)
'	data = KISA_SEED_CTR.chartoint32_for_SEED_CTR(newpbszPlainText, remainleng)
'	Call KISA_SEED_CTR.SEED_CTR_Process( info, data, remainleng, outbuf, nRetOutLeng )
'	Call KISA_SEED_CTR.SEED_CTR_Close( info, outbuf, nRetOutLeng, EncRmainLeng )
'	cdata = KISA_SEED_CTR.int32tochar_for_SEED_CTR(outbuf, nRetOutLeng - EncRmainLeng)
'	Call arraycopy_system(cdata, 0, bszChiperText, i, nRetOutLeng - EncRmainLeng )
'	message_length = i+ remainleng - nPaddingLeng-1
'
'	for i=0 to message_length
'		temp = temp & Right("0000" & hex(bszChiperText(i)), 2)
'		If(i <> message_length) then
'			temp = temp & ","
'		End if
'	Next
'
'	test2 = temp

end function
	
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CTR] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CTR] 테스트 페이지</h1>
<form name="myform" method="post" action="./index.asp">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<form method="post" action="./index.ashp">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="KEY" style="width:400px;height:100px;"><%=g_bszUser_key%></textarea></td>
</tr>
<tr>
<td>카운터(CTR) : </td> 
<td><textarea name="CTR" style="width:400px;height:100px;"><%=g_bszCounter%></textarea></td>
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
<td><textarea name="KEY" style="width:400px;height:100px;"><%=g_bszUser_key%></textarea></td>
</tr>
<tr>
<td>카운터(CTR) : </td> 
<td><textarea name="CTR" style="width:400px;height:100px;"><%=g_bszCounter%></textarea></td>
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
<td>88,E3,4F,8F,08,17,79,F1,E9,F3,94,37,0A,D4,05,89</td>
</tr>
<tr>
<td>&lt;초기카운터&gt; : </td>
<td>00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,FE</td>
</tr>
<tr>
<td>&lt;평문&gt; : </td>
<td>00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F</td>
</tr>
<tr>
<td>&lt;암호문&gt; : </td>
<td>83,72,13,DF,61,DD,CB,5B,50,AC,EB,54,5B,86,43,ED</td>
</tr>
</table>
</div>
</form>

</center>
</body>
</html>