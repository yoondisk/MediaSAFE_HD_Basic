<!--#include file="KISA_SEED_CCM.asp" -->
<%

dim e_out
dim e_ret

dim d_out
dim d_ret

e_key = Trim(request.form("E_KEY"))
e_nonce = Trim(request.form("E_NONCE"))
e_aad = Trim(request.form("E_AAD"))
e_in = Trim(request.form("E_IN"))
e_mac_len = request.form("E_MAC_LEN")

d_key = Trim(request.form("D_KEY"))
d_nonce = Trim(request.form("D_NONCE"))
d_aad = Trim(request.form("D_AAD"))
d_in = Trim(request.form("D_IN"))
d_mac_len = request.form("D_MAC_LEN")

function encrypt(byref output, input, macLen, nonce, aad, key)
	dim i
    dim data
	dim result
	dim temp

    redim data(ubound(input) + macLen)

	result = KISA_SEED_CCM.SEED_CCM_Encryption(data, input, ubound(input) + 1, macLen, nonce, ubound(nonce) + 1, aad, ubound(aad) + 1, key)
	
	if result <> 0 then
		e_ret = result & ", Failure!"
		exit function
	else
		e_ret = result & ", Success!"
	end if

	temp = ""
	for i = 0 to (ubound(data))
		temp = temp & Right("0000" & hex(data(i)), 2)
		
		if (i <> ubound(data)) then
			temp = temp & ","
		end if
	Next

	output = temp
end function

function decrypt(byref output, input, macLen, nonce, aad, key)
	dim i
    dim data
	dim result
	dim temp
	
    redim data(ubound(input) - macLen)

	result = KISA_SEED_CCM.SEED_CCM_Decryption(data, input, ubound(input) + 1, macLen, nonce, ubound(nonce) + 1, aad, ubound(aad) + 1, key)

	if (result <> 0) then
		d_ret = result & ", Incorrect!"
		exit function
	else
		d_ret = result & ", Correct!"
	end if

	temp = ""
	for i = 0 to (ubound(data))
		temp = temp & Right("0000" & hex(data(i)), 2)
		
		if (i <> ubound(data)) then
			temp = temp & ","
		end if
	Next

	output = temp
end function

dim arrKEY
dim arrPT
dim arrNONCE
dim arrAAD

dim tempKEY
dim tempPT
dim tempNONCE
dim tempAAD

if ((IsNull(e_key) or Len(Trim(e_key)) = 0) or (IsNull(e_nonce) or Len(Trim(e_nonce)) = 0)) then
else
	tempPT = split(e_in,",")
	redim arrPT(ubound(tempPT))

	for i = 0 to (ubound(tempPT))
		arrPT(i) = (Cbyte)("&H" & (right("0000" & tempPT(i), 4)))
	Next

	tempKEY = split(e_key,",")
	redim arrKEY(ubound(tempKEY))

	for i = 0 to (ubound(tempKEY))
		arrKEY(i) = (Cbyte)("&H" & (right("0000" & tempKEY(i), 4)))
	Next

	tempNONCE = split(e_nonce,",")
	redim arrNONCE(ubound(tempNONCE))

	for i = 0 to (ubound(tempNONCE))
		arrNONCE(i) = (Cbyte)("&H" & (right("0000" & tempNONCE(i), 4)))
	Next

	tempAAD = split(e_aad,",")
	redim arrAAD(ubound(tempAAD))

	for i = 0 to (ubound(tempAAD))
		arrAAD(i) = (Cbyte)("&H" & (right("0000" & tempAAD(i), 4)))
	Next
	
	call encrypt(e_out, arrPT, e_mac_len, arrNONCE, arrAAD, arrKEY)
end if

if ((IsNull(d_key) or Len(Trim(d_key)) = 0) or (IsNull(d_nonce) or Len(Trim(d_nonce)) = 0)) then
else
	tempPT = split(d_in,",")
	redim arrPT(ubound(tempPT))

	for i = 0 to (ubound(tempPT))
		arrPT(i) = (Cbyte)("&H" & (right("0000" & tempPT(i), 4)))
	Next

	tempKEY = split(d_key,",")
	redim arrKEY(ubound(tempKEY))

	for i = 0 to (ubound(tempKEY))
		arrKEY(i) = (Cbyte)("&H" & (right("0000" & tempKEY(i), 4)))
	Next

	tempNONCE = split(d_nonce,",")
	redim arrNONCE(ubound(tempNONCE))

	for i = 0 to (ubound(tempNONCE))
		arrNONCE(i) = (Cbyte)("&H" & (right("0000" & tempNONCE(i), 4)))
	Next

	tempAAD = split(d_aad,",")
	redim arrAAD(ubound(tempAAD))

	for i = 0 to (ubound(tempAAD))
		arrAAD(i) = (Cbyte)("&H" & (right("0000" & tempAAD(i), 4)))
	Next
	
	call decrypt(d_out, arrPT, d_mac_len, arrNONCE, arrAAD, arrKEY)
end if

%>



<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CCM] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CCM] 테스트 페이지</h1>
<form name="myform" method="post" action="./KISA_SEED_CCM_index.asp">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<form method="post" action="./KISA_SEED_CCM_index.asp">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="E_KEY" style="width:400px;height:100px;"><%=e_key%></textarea></td>
</tr>
<tr>
<td>초기값(NONCE) : </td> 
<td><textarea name="E_NONCE" style="width:400px;height:100px;"><%=e_nonce%></textarea></td>
</tr>
<tr>
<td>추가인증데이터(AAD) : </td> 
<td><textarea name="E_AAD" style="width:400px;height:100px;"><%=e_aad%></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="E_IN" style="width:400px;height:100px;"><%=e_in%></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="E_MAC_LEN" style="width:400px;height:20px;"><%=e_mac_len%></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ 암호화"> </td>
</tr>
<tr>
<td>암호문 : </td> 
<td><textarea name="E_OUT" style="width:400px;height:100px;"><%=e_out%></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="E_RET" style="width:400px;height:20px;"><%=e_ret%></textarea></td>
</tr>
</table>
</form>	
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<form method="post" action="./KISA_SEED_CCM_index.asp">
<table border="0">
<tr><td></td><td>&lt;암호화 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="D_KEY" style="width:400px;height:100px;"><%=d_key%></textarea></td>
</tr>
<tr>
<td>초기값(NONCE) : </td> 
<td><textarea name="D_NONCE" style="width:400px;height:100px;"><%=d_nonce%></textarea></td>
</tr>
<tr>
<td>추가인증데이터(AAD) : </td> 
<td><textarea name="D_AAD" style="width:400px;height:100px;"><%=d_aad%></textarea></td>
</tr>
<tr>
<td>암호문 : </td>
<td><textarea name="D_IN" style="width:400px;height:100px;"><%=d_in%></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="D_MAC_LEN" style="width:400px;height:20px;"><%=d_mac_len%></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ 복호화"> </td>
</tr>
<tr>
<td>복호문 : </td> 
<td><textarea name="D_OUT" style="width:400px;height:100px;"><%=d_out%></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="D_RET" style="width:400px;height:20px;"><%=d_ret%></textarea></td>
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