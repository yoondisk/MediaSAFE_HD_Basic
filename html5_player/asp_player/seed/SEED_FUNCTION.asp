<%
' ==========================================================
' Base64 Char Set
' ==========================================================
Const sBASE_64_CHARACTERS = _
           "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

' ==========================================================
' Base64Decode
' ==========================================================
function Base64decode(ByVal asContents)
           Dim lsResult
           Dim lnPosition
           Dim lsGroup64, lsGroupBinary
           Dim Char1, Char2, Char3, Char4
           Dim Byte1, Byte2, Byte3
           if Len(asContents) Mod 4 > 0 _
          Then asContents = asContents & String(4 - (Len(asContents) Mod 4), " ")
           lsResult = ""

           For lnPosition = 1 To Len(asContents) Step 4
                   lsGroupBinary = ""
                   lsGroup64 = Mid(asContents, lnPosition, 4)
                   Char1 = INSTR(sBASE_64_CHARACTERS, Mid(lsGroup64, 1, 1)) - 1
                   Char2 = INSTR(sBASE_64_CHARACTERS, Mid(lsGroup64, 2, 1)) - 1
                   Char3 = INSTR(sBASE_64_CHARACTERS, Mid(lsGroup64, 3, 1)) - 1
                   Char4 = INSTR(sBASE_64_CHARACTERS, Mid(lsGroup64, 4, 1)) - 1
                   Byte1 = ChrW(((Char2 And 48) \ 16) Or (Char1 * 4) And &HFF)
                   Byte2 = lsGroupBinary & ChrW(((Char3 And 60) \ 4) Or (Char2 * 16) And &HFF)
                   Byte3 = ChrW((((Char3 And 3) * 64) And &HFF) Or (Char4 And 63))
                   lsGroupBinary = Byte1 & Byte2 & Byte3

                   lsResult = lsResult + lsGroupBinary
           Next
Base64decode = lsResult
End function

' ==========================================================
' Base64encode
' ==========================================================
function Base64encode(ByVal asContents)
        Dim lnPosition
        Dim lsResult
        Dim Char1
        Dim Char2
        Dim Char3
        Dim Char4
        Dim Byte1
        Dim Byte2
        Dim Byte3
        Dim SaveBits1
        Dim SaveBits2
        Dim lsGroupBinary
        Dim lsGroup64

        if Len(asContents) Mod 3 > 0 Then _
        asContents = asContents & String(3 - (Len(asContents) Mod 3), " ")
        lsResult = ""

        For lnPosition = 1 To Len(asContents) Step 3
               lsGroup64 = ""
               lsGroupBinary = Mid(asContents, lnPosition, 3)

               Byte1 = AscW(Mid(lsGroupBinary, 1, 1)): SaveBits1 = Byte1 And 3
               Byte2 = AscW(Mid(lsGroupBinary, 2, 1)): SaveBits2 = Byte2 And 15
               Byte3 = AscW(Mid(lsGroupBinary, 3, 1))

               Char1 = Mid(sBASE_64_CHARACTERS, ((Byte1 And 252) \ 4) + 1, 1)
               Char2 = Mid(sBASE_64_CHARACTERS, (((Byte2 And 240) \ 16) Or _
               (SaveBits1 * 16) And &HFF) + 1, 1)
               Char3 = Mid(sBASE_64_CHARACTERS, (((Byte3 And 192) \ 64) Or _
               (SaveBits2 * 4) And &HFF) + 1, 1)
               Char4 = Mid(sBASE_64_CHARACTERS, (Byte3 And 63) + 1, 1)
               lsGroup64 = Char1 & Char2 & Char3 & Char4

               lsResult = lsResult + lsGroup64
         Next

         Base64encode = lsResult
End Function

' ==========================================================
' ASP UnixTimeStamp String
' ==========================================================
Function ConvertToUnixTimeStamp()
	Dim d 
	d = CDate(Now()) 
	ConvertToUnixTimeStamp = CStr(DateDiff("s", "01/01/1970 00:00:00", d)) 
End Function

' ==========================================================
'	DECRYPT decrypt(g_bszIV, g_bszUser_key, bszPlainText)
'	Encrypt String => Base64_decode => String to hex  => SEED DECRYPT => Hex to String => TimeStamp Remove => Decrypt String
' ==========================================================
function decrypt(g_bszIV,g_bszUser_key,bszPlainText)
	Dim i
	Dim bszChiperText1
	Dim temp
	Dim CharStr

	Dim sampleData1
	Dim sampleIV1
	Dim sampleKey1
	Dim arrEnc
	Dim strHex
	Dim timestr

	bszPlainText1 = Base64Decode(bszPlainText)
	strHex =""
	For i=1 To Len(bszPlainText1)
		strHex = strHex & Hex(AscW(Mid(bszPlainText1,i,1)))&","
	Next
	strHex=left(strHex,len(strHex)-1)
	arrEnc = split(strHex,",")
	redim sampleData1(ubound(arrEnc))
	for i=0 to (ubound(arrEnc))
		sampleData1(i) = (Cbyte)("&H" & (right("0000" & arrEnc(i), 4)))
	Next

	arrKey = split(g_bszUser_key,",")
	redim sampleKey1(ubound(arrKey))
	for i=0 to (ubound(arrKey))
		sampleKey1(i) = (Cbyte)("&H" & (right("0000" & arrKey(i), 4)))
	Next

	arrIV = split(g_bszIV,",")
	redim sampleIV1(ubound(arrIV))
	for i=0 to (ubound(arrIV))
		sampleIV1(i) = (Cbyte)("&H" & (right("0000" & arrIV(i), 4)))
	Next

	bszChiperText = KISA_SEED_CBC.SEED_CBC_Decrypt(sampleKey1, sampleIV1, sampleData1, 0, UBound(sampleData1)+1)
	
	for i=0 to (UBound(bszChiperText))
		temp = temp & Right("0000" & hex(bszChiperText(i)), 2)
		CharStr = CharStr & ChrW(CInt("&H" & Right("0000" & hex(bszChiperText(i)), 2)))
		If(i <> UBound(bszChiperText)) then
			temp = temp & ","
		End if
	Next

	timestr=split(CharStr,"|")
	
	decrypt = timestr(1)
end Function

' ==========================================================
'	ENCRYPT encrypt(g_bszIV, g_bszUser_key, bszPlainText)
'	Orgin string => Timestamp|String => String to hex => SEED ENCRYPT => Hex to String => Base64_encode => Encrypt String
' ==========================================================
function encrypt(g_bszIV,g_bszUser_key,bszPlainText)
	Dim i
	Dim bszChiperText1
	Dim temp
	Dim CharStr

	Dim sampleData1
	Dim sampleIV1
	Dim sampleKey1
	Dim arrEnc
	Dim strHex
	
	bszChiperText1= ConvertToUnixTimeStamp() & "|" & bszPlainText

	strHex =""
	For i=1 To Len(bszChiperText1)
		strHex = strHex & Hex(AscW(Mid(bszChiperText1,i,1)))&","
	Next
	strHex=left(strHex,len(strHex)-1)
	arrEnc = split(strHex,",")
	redim sampleData1(ubound(arrEnc))
	for i=0 to (ubound(arrEnc))
		sampleData1(i) = (Cbyte)("&H" & (right("0000" & arrEnc(i), 4)))
	Next

	arrKey = split(g_bszUser_key,",")
	redim sampleKey1(ubound(arrKey))
	for i=0 to (ubound(arrKey))
		sampleKey1(i) = (Cbyte)("&H" & (right("0000" & arrKey(i), 4)))
	Next

	arrIV = split(g_bszIV,",")
	redim sampleIV1(ubound(arrIV))
	for i=0 to (ubound(arrIV))
		sampleIV1(i) = (Cbyte)("&H" & (right("0000" & arrIV(i), 4)))
	Next
		
	bszChiperText = KISA_SEED_CBC.SEED_CBC_Encrypt(sampleKey1, sampleIV1, sampleData1, 0, UBound(sampleData1)+1)

	for i=0 to (UBound(bszChiperText))
		temp = temp & Right("0000" & hex(bszChiperText(i)), 2)
		CharStr = CharStr & ChrW(CInt("&H" & Right("0000" & hex(bszChiperText(i)), 2)))
		If(i <> UBound(bszChiperText)) then
			temp = temp & ","
		End if
	Next

	encrypt = Base64Encode(CharStr)
end Function
%>