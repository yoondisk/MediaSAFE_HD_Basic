<!--#include file="KISA_SEED_CMAC.asp" -->
<%
dim g_mac
dim g_ret

dim v_ret

g_key = Trim(request.form("G_KEY"))
g_in = Trim(request.form("G_IN"))
g_mac_len = request.form("G_MAC_LEN")

v_key = Trim(request.form("V_KEY"))
v_in = Trim(request.form("V_IN"))
v_mac = Trim(request.form("V_MAC"))
v_mac_len = request.form("V_MAC_LEN")

function generate(byref mac, macLen, input, key)
	dim i
    dim data
	dim result
	dim temp

    redim data(macLen)

	result = KISA_SEED_CMAC.SEED_Generate_CMAC(data, macLen, input, ubound(input) + 1, key)
	
	if result <> 0 then
		g_ret = result & ", Failure!"
		exit function
	else
		g_ret = result & ", Success!"
	end if

	temp = ""
	for i = 0 to (ubound(data))
		temp = temp & Right("0000" & hex(data(i)), 2)
		
		if (i <> ubound(data)) then
			temp = temp & ","
		end if
	Next

	mac = temp
end function

function verify(byref mac, macLen, input, key)
	dim result

	result = KISA_SEED_CMAC.SEED_Verify_CMAC(mac, macLen, input, ubound(input) + 1, key)

	if (result <> 0) then
		v_ret = result & ", Incorrect!"
		exit function
	else
		v_ret = result & ", Correct!"
	end if
end function

dim arrKEY
dim arrPT
dim arrMAC

dim tempKEY
dim tempPT
dim tempMAC

if (IsNull(g_key) or Len(Trim(g_key)) = 0) then
else
	tempPT = split(g_in,",")
	redim arrPT(ubound(tempPT))

	for i = 0 to (ubound(tempPT))
		arrPT(i) = (Cbyte)("&H" & (right("0000" & tempPT(i), 4)))
	Next

	tempKEY = split(g_key,",")
	redim arrKEY(ubound(tempKEY))

	for i = 0 to (ubound(tempKEY))
		arrKEY(i) = (Cbyte)("&H" & (right("0000" & tempKEY(i), 4)))
	Next
	
	call generate(g_mac, g_mac_len, arrPT, arrKEY)
end if
 if (IsNull(v_key) or Len(Trim(v_key)) = 0) then
else
	tempPT = split(v_in,",")
	redim arrPT(ubound(tempPT))

	for i = 0 to (ubound(tempPT))
		arrPT(i) = (Cbyte)("&H" & (right("0000" & tempPT(i), 4)))
	Next

	tempKEY = split(v_key,",")
	redim arrKEY(ubound(tempKEY))

	for i = 0 to (ubound(tempKEY))
		arrKEY(i) = (Cbyte)("&H" & (right("0000" & tempKEY(i), 4)))
	Next

	tempMAC = split(v_mac,",")
	redim arrMAC(ubound(tempMAC))
	
	for i = 0 to (ubound(tempMAC))
		arrMAC(i) = (Cbyte)("&H" & (right("0000" & tempMAC(i), 4)))
	Next
	
	call verify(arrMAC, v_mac_len, arrPT, arrKEY)
end if
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<title>국산암호 [SEED - CMAC] 테스트 페이지</title>
</head>
<body>
<center>
<h1>국산 암호 [SEED-CMAC] 테스트 페이지</h1>
<form name="myform" method="post" action="./KISA_SEED_CMAC_index.asp">
<input type="hidden" name="method" id="method" />
<table border="0">
<tr>
<td style="text-align:center;">
<form method="post" action="./KISA_SEED_CMAC_index.asp">
<table border="0">
<tr><td></td><td>&lt;MAC 생성 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="G_KEY" style="width:400px;height:100px;"><%=g_key%></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="G_IN" style="width:400px;height:100px;"><%=g_in%></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="G_MAC_LEN" style="width:400px;height:20px;"><%=g_mac_len%></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ MAC 생성"> </td>
</tr>
<tr>
<td>MAC : </td> 
<td><textarea name="G_MAC" style="width:400px;height:100px;"><%=g_mac%></textarea></td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="G_RET" style="width:400px;height:20px;"><%=g_ret%></textarea></td>
</tr>
</table>
</form>	
</td>
<td style="width:1px;background-color:#aaaaff;">
</td>
<td style="text-align:center;">
<form method="post" action="./KISA_SEED_CMAC_index.asp">
<table border="0">
<tr><td></td><td>&lt;MAC 검증 예제&gt;</td></tr>
<tr>
<td>키(KEY) : </td> 
<td><textarea name="V_KEY" style="width:400px;height:100px;"><%=v_key%></textarea></td>
</tr>
<tr>
<td>평문 : </td>
<td><textarea name="V_IN" style="width:400px;height:100px;"><%=v_in%></textarea></td>
</tr>
<tr>
<td>MAC : </td> 
<td><textarea name="V_MAC" style="width:400px;height:100px;"><%=v_mac%></textarea></td>
</tr>
<tr>
<td>인증값 길이 : </td>
<td><textarea name="V_MAC_LEN" style="width:400px;height:20px;"><%=v_mac_len%></textarea></td>
</tr>
<tr>
<td></td>
<td><input type="submit" name="gogo" value="▼ MAC 검증"> </td>
</tr>
<tr>
<td>결과값 : </td>
<td><textarea name="V_RET" style="width:400px;height:20px;"><%=v_ret%></textarea></td>
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