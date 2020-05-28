<!--#include file="KISA_SEED.asp" -->
<%

class KISA_SEED_CMAC_C
    private function UnsignedToLong(Value)
        if Value < 0 Or Value >= OFFSET_4 then
            UnsignedToLong = Value
        else
            if Value <= MAXINT_4 then
                UnsignedToLong = Value
            else
                UnsignedToLong = Value - OFFSET_4
            end if
        end if
    end function

    private function LongToUnsigned(Value)
        if Value < 0 then
            LongToUnsigned = Value + OFFSET_4
        else
            LongToUnsigned = Value
        end if
    end function

    private function LShift(v, s)
        if s = 0 then
            LShift = v
            exit function
        elseif s > 31 then
            LShift = 0
            exit function
        end if

        m = 1
        for i = 1 to (s - 1)
        m = m * 2 + 1
        next

        m2 = not m
        m3 = LongToUnsigned(m2)
        m4 = FIX(m3 / 2^s) + 1
        m5 = DMOD(v, m4)

        LShift = m5 * 2^s
    end function

    private function RShift(v, s)
        RShift = FIX(v / (2^s))
    end function

    private function SLShift(v, s)
        SLShift = UnsignedToLong(LShift(LongToUnsigned(v), s))
    end function

    private function SRShift(v, s)
        SRShift = UnsignedToLong(RShift(LongToUnsigned(v), s))
    end function

    private function DMOD(v, d)
        dim result
        result = v - (FIX(v / d) * d)
        DMOD = result
    end function

    private function MASK(v, m)
        MASK = UnsignedToLong(DMOD(LongToUnsigned(v), LongToUnsigned(m)+1))
    end function

    private function Byte2Word(byref dst, src, src_len)
        dim i
        dim temp
        dim remain

        for i = 0 to (src_len - 1)
            remain = i mod 4
            temp = (int)(i / 4)

            if remain = 0 then
                dst(temp) = SLShift(MASK(src(i),HFF),24)
            elseif remain = 1 then
                dst(temp) = dst(temp) or SLShift(MASK(src(i),HFF),16)
            elseif remain = 2 then
                dst(temp) = dst(temp) or SLShift(MASK(src(i),HFF),8)
            else
                dst(temp) = dst(temp) or SLShift(MASK(src(i),HFF),0)
            end if
        next
    end function

    private function Word2Byte(byref dst, src, src_len)
        dim i
        dim temp
        dim remain

        for i = 0 to (src_len - 1)
            remain = i mod 4
            temp = (int)(i / 4)

            if remain = 0 then
                dst(i) = HFF and (SRShift(src(temp),24))
            elseif remain = 1 then
                dst(i) = HFF and (SRShift(src(temp),16))
            elseif remain = 2 then
                dst(i) = HFF and (SRShift(src(temp),8))
            else
                dst(i) = HFF and (SRShift(src(temp),0))
            end if
        next
    end function
	
	private function SEED_CMAC_SubkeySched(byref sKey)
		dim i
		dim j
		dim carry
		
		carry = SRShift(sKey(0), 7)
		
		for i = 0 to (15 - 1)
			sKey(i) = (SLShift(MASK(sKey(i),HFF), 1) or SRShift(MASK(sKey(i+1),HFF), 7)) and HFF
		next
			
		sKey(i) = (SLShift(MASK(sKey(i),HFF), 1)) and HFF
		
		if carry <> 0 then
			sKey(i) = sKey(i) xor H87
		end if
			
	end function

    public function SEED_Generate_CMAC(byref pMAC, macLen, pIn, inLen, mKey)
        dim L(15)
        dim temp(15)
        dim subKey(3)
        dim temp1(3)
        dim rKey(31)
		dim blockLen
        dim i
		dim j
		dim k
        
		if macLen > 16 then
			SEED_Generate_CMAC = 1
        end if

        call KISA_SEED.SEED_KeySched(mKey, rKey)
		call KISA_SEED.SEED_Encrypt(subKey, subKey, rKey)
		
		call Word2Byte(L, subKey, 16)
		
		call SEED_CMAC_SubkeySched(L)

        if inLen = 0 then
			call SEED_CMAC_SubkeySched(L)
			
			L(0) = L(0) xor &H80
			
			call Byte2Word(subKey, L, 16)
			call KISA_SEED.SEED_Encrypt(temp1, subKey, rKey)
		else
			call SEED_CMAC_SubkeySched(L)
			
			blockLen = (int)((inLen + 16) / 16)
			
			for i = 0 to (blockLen - 2)
				call Word2Byte(temp, temp1, 16)
				for j = 0 to 16 - 1
					temp(j) = temp(j) xor pIn(16 * i + j)
				next
				call Byte2Word(temp1, temp, 16)
				call KISA_SEED.SEED_Encrypt(temp1, temp1, rKey)
			next
			
			call Word2Byte(temp, temp1, 16)
			
			j = 0
			for k = 16 * i + j to (inLen - 1)
				temp(j) = temp(j) xor (pIn(16 * i + j) xor L(j))
				j = j + 1
			next
			temp(j) = temp(j) xor (&H80 xor L(j))
			j = j + 1
			for j = j to (16 - 1)
				temp(j) = temp(j) xor L(j)
			next
			
			call Byte2Word(temp1, temp, 16)
			call KISA_SEED.SEED_Encrypt(temp1, temp1, rKey)
		end if
		
		call Word2Byte(temp, temp1, 16)
		
		pMAC = temp
        
        SEED_Generate_CMAC = 0
    end function
	
	public function SEED_Verify_CMAC(byref pMAC, macLen, pIn, inLen, mKey)
        dim L(15)
        dim temp(15)
        dim subKey(3)
        dim temp1(3)
        dim rKey(31)
		dim blockLen
        dim i
		dim j
		dim k
        
		if macLen > 16 then
			SEED_Verify_CMAC = 1
        end if

        call KISA_SEED.SEED_KeySched(mKey, rKey)
		call KISA_SEED.SEED_Encrypt(subKey, subKey, rKey)
		
		call Word2Byte(L, subKey, 16)
		
		call SEED_CMAC_SubkeySched(L)

        if inLen = 0 then
			call SEED_CMAC_SubkeySched(L)
			
			L(0) = L(0) xor &H80
			
			call Byte2Word(subKey, L, 16)
			call KISA_SEED.SEED_Encrypt(temp1, subKey, rKey)
		else
			call SEED_CMAC_SubkeySched(L)
			
			blockLen = (int)((inLen + 16) / 16)
			
			for i = 0 to (blockLen - 2)
				call Word2Byte(temp, temp1, 16)
				for j = 0 to 16 - 1
					temp(j) = temp(j) xor pIn(16 * i + j)
				next
				call Byte2Word(temp1, temp, 16)
				call KISA_SEED.SEED_Encrypt(temp1, temp1, rKey)
			next
			
			call Word2Byte(temp, temp1, 16)
			
			j = 0
			for k = 16 * i + j to (inLen - 1)
				temp(j) = temp(j) xor (pIn(16 * i + j) xor L(j))
				j = j + 1
			next
			temp(j) = temp(j) xor (&H80 xor L(j))
			j = j + 1
			for j = j to (16 - 1)
				temp(j) = temp(j) xor L(j)
			next
			
			call Byte2Word(temp1, temp, 16)
			call KISA_SEED.SEED_Encrypt(temp1, temp1, rKey)
		end if
		
		call Word2Byte(temp, temp1, 16)
		
		for i = 0 to macLen - 1
			if pMAC(i) <> temp(i) then
				SEED_Verify_CMAC = 1
				exit function
			end if
		next
        
        SEED_Verify_CMAC = 0
    end function
end class

set KISA_SEED_CMAC = new KISA_SEED_CMAC_C

%>