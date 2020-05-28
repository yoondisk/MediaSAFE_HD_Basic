<!--#include file="KISA_SEED.asp" -->
<%

class KISA_SEED_CCM_C
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

    private function SHIFTR8(v)
        v(3) = (SRShift(v(3),8) and HFFFFFF) xor SLShift(v(2),24)
        v(2) = (SRShift(v(2),8) and HFFFFFF) xor SLShift(v(1),24)
        v(1) = (SRShift(v(1),8) and HFFFFFF) xor SLShift(v(0),24)
        v(0) =  SRShift(v(0),8) and HFFFFFF
    end function

    private function SHIFTR16(v)
        v(3) = (SRShift(v(3),16) and HFFFF) xor SLShift(v(2),16)
        v(2) = (SRShift(v(2),16) and HFFFF) xor SLShift(v(1),16)
        v(1) = (SRShift(v(1),16) and HFFFF) xor SLShift(v(0),16)
        v(0) =  SRShift(v(0),16) and HFFFF
    end function

    private function XOR128(c, a, b)
        c(3) = a(3) xor b(3)
        c(2) = a(2) xor b(2)
        c(1) = a(1) xor b(1)
        c(0) = a(0) xor b(0)
    end function

    private function INCREASE(ctr)
        if ctr(3) = HFFFFFFFF then
            ctr(2) = ctr(2) + 1
            ctr(3) = 0
        else
            ctr(3) = ctr(3) + 1
        end if
    end function

    private function ZERO128(a)
        a(3) = 0
        a(2) = 0
        a(1) = 0
        a(0) = 0
    end function

    private function Byte2Word(byref dst, src, src_offset, src_len)
        dim i
        dim temp
        dim remain

        for i = 0 to (src_len - 1)
            remain = i mod 4
            temp = (int)(i / 4)

            if remain = 0 then
                dst(temp) = SLShift(MASK(src(src_offset+i),HFF),24)
            elseif remain = 1 then
                dst(temp) = dst(temp) or SLShift(MASK(src(src_offset+i),HFF),16)
            elseif remain = 2 then
                dst(temp) = dst(temp) or SLShift(MASK(src(src_offset+i),HFF),8)
            else
                dst(temp) = dst(temp) or SLShift(MASK(src(src_offset+i),HFF),0)
            end if
        next
    end function

    private function Word2Byte(byref dst, dst_offset, src, src_len)
        dim i
        dim temp
        dim remain

        for i = 0 to (src_len - 1)
            remain = i mod 4
            temp = (int)(i / 4)

            if remain = 0 then
                dst(dst_offset + i) = HFF and (SRShift(src(temp),24))
            elseif remain = 1 then
                dst(dst_offset + i) = HFF and (SRShift(src(temp),16))
            elseif remain = 2 then
                dst(dst_offset + i) = HFF and (SRShift(src(temp),8))
            else
                dst(dst_offset + i) = HFF and (SRShift(src(temp),0))
            end if
        next
    end function

    public function SEED_CCM_Encryption(byref ct, pt, ptLen, macLen, nonce, nonceLen, aad, aadLen, mKey)
        dim CTR_in(3)
        dim CTR_out(3)
        dim CBC_in(3)
        dim CBC_out(3)
        dim eMAC(3)
        dim tmp(7)
        dim rKey(31)
        dim i
        dim flag
        dim tmpLen
        
        if macLen > 16 then
            SEED_CCM_Encryption = 1
        end if

        call KISA_SEED.SEED_KeySched(mKey, rKey)

        call Byte2Word(CTR_in, nonce, 0, nonceLen)
        call SHIFTR8(CTR_in)

        flag = 14 - nonceLen

        CTR_in(0) = (CTR_in(0) xor SLShift(flag, 24)) and HFFFFFFFF

        call KISA_SEED.SEED_Encrypt(eMAC, CTR_in, rKey)

        for i=0 to (ptLen - 1) step 16
            call INCREASE(CTR_in)

            call ZERO128(tmp)

            if (ptLen - 1) < 16 then
                call Byte2Word(tmp, pt, i, ptLen - i)
            else
                call Byte2Word(tmp, pt, i, 16)
            end if

            call KISA_SEED.SEED_Encrypt(CTR_out, CTR_in, rKey)

            call XOR128(tmp, CTR_out, tmp)

            if (ptLen - i) < 16 then
                call Word2Byte(ct, i, tmp, ptLen - i)
            else
                call Word2Byte(ct, i, tmp, 16)
            end if
        next

        call Byte2Word(CBC_in, nonce, o, nonceLen)
        call SHIFTR8(CBC_in)

        if aadLen > 0 then
            flag = 64
        else
            flag = 0
        end if

        flag = flag xor ((int)((macLen - 2) / 2) * 8)
        flag = flag xor (14 - nonceLen)

        CBC_in(0) = CBC_in(0) xor SLShift(flag,24)
        CBC_in(3) = CBC_in(3) xor ptLen

        call KISA_SEED.SEED_Encrypt(CBC_out, CBC_in, rKey)

        if aadLen > 0 then
            if aadLen > 14 then
                tmpLen = 14
            else
                tmpLen = aadLen
            end if

            call ZERO128(CBC_in)

            call Byte2Word(CBC_in, aad, 0, tmpLen)
            call SHIFTR16(CBC_in)

            CBC_in(0) = CBC_in(0) xor SLShift(aadLen, 16)

            call XOR128(CBC_in, CBC_in, CBC_out)

            call KISA_SEED.SEED_Encrypt(CBC_out, CBC_in, rKey)

            for i=tmpLen to aadLen - 1 step 16
                call ZERO128(CBC_in)

                if (aadLen - i) < 16 then
                    call Byte2Word(CBC_in, aad, i, aadLen - i)
                else
                    call Byte2Word(CBC_in, aad, i, 16)
                end if

                call XOR128(CBC_in, CBC_in, CBC_out)

                call KISA_SEED.SEED_Encrypt(CBC_out, CBC_in, rKey)
            next
        end if

        for i=0 to ptLen - 1 step 16
            call ZERO128(tmp)

            if (ptLen - i) < 16 then
                call Byte2Word(tmp, pt, i, ptLen - i)
            else
                call Byte2Word(tmp, pt, i, 16)
            end if

            call XOR128(CBC_in, tmp, CBC_out)

            call KISA_SEED.SEED_Encrypt(CBC_out, CBC_in, rKey)
        next

        call XOR128(eMAC, eMAC, CBC_out)

        call Word2Byte(ct, ptLen, eMAC, macLen)
        
        SEED_CCM_Encryption = 0
    end function

    public function SEED_CCM_Decryption(byref pt, ct, ctLen, macLen, nonce, nonceLen, aad, aadLen, mKey)
        dim CTR_in(3)
        dim CTR_out(3)
        dim CBC_in(3)
        dim CBC_out(3)
        dim eMAC(3)
        dim tMAC(15)
        dim tmp(7)
        dim rKey(31)
        dim i
        dim flag
        dim tmpLen
        
        if macLen > 16 then
            SEED_CCM_Decryption = 1
        end if

        call KISA_SEED.SEED_KeySched(mKey, rKey)

        call Byte2Word(CTR_in, nonce, 0, nonceLen)
        call SHIFTR8(CTR_in)

        flag = 14 - nonceLen

        CTR_in(0) = (CTR_in(0) xor SLShift(flag, 24)) and HFFFFFFFF

        call KISA_SEED.SEED_Encrypt(eMAC, CTR_in, rKey)

        for i = 0 to (ctLen - macLen - 1) step 16
            call INCREASE(CTR_in)

            call ZERO128(tmp)

            if (ctLen - macLen - 1) < 16 then
                call Byte2Word(tmp, ct, i, ctLen - macLen - i)
            else
                call Byte2Word(tmp, ct, i, 16)
            end if

            call KISA_SEED.SEED_Encrypt(CTR_out, CTR_in, rKey)

            call XOR128(tmp, CTR_out, tmp)

            if (ctLen - macLen - i) < 16 then
                call Word2Byte(pt, i, tmp, ctLen - macLen - i)
            else
                call Word2Byte(pt, i, tmp, 16)
            end if
        next

        call Byte2Word(CBC_in, nonce, o, nonceLen)
        call SHIFTR8(CBC_in)

        if aadLen > 0 then
            flag = 64
        else
            flag = 0
        end if

        flag = flag xor ((int)((macLen - 2) / 2) * 8)
        flag = flag xor (14 - nonceLen)

        CBC_in(0) = CBC_in(0) xor SLShift(flag,24)
        CBC_in(3) = CBC_in(3) xor (ctLen - macLen)

        call KISA_SEED.SEED_Encrypt(CBC_out, CBC_in, rKey)

        if aadLen > 0 then
            if aadLen > 14 then
                tmpLen = 14
            else
                tmpLen = aadLen
            end if

            call ZERO128(CBC_in)

            call Byte2Word(CBC_in, aad, 0, tmpLen)
            call SHIFTR16(CBC_in)

            CBC_in(0) = CBC_in(0) xor SLShift(aadLen, 16)

            call XOR128(CBC_in, CBC_in, CBC_out)

            call KISA_SEED.SEED_Encrypt(CBC_out, CBC_in, rKey)

            for i = tmpLen to aadLen - 1 step 16
                call ZERO128(CBC_in)

                if (aadLen - i) < 16 then
                    call Byte2Word(CBC_in, aad, i, aadLen - i)
                else
                    call Byte2Word(CBC_in, aad, i, 16)
                end if

                call XOR128(CBC_in, CBC_in, CBC_out)

                call KISA_SEED.SEED_Encrypt(CBC_out, CBC_in, rKey)
            next
        end if

        for i = 0 to ctLen - macLen - 1 step 16
            call ZERO128(tmp)

            if (ctLen - macLen - i) < 16 then
                call Byte2Word(tmp, pt, i, ctLen - macLen - i)
            else
                call Byte2Word(tmp, pt, i, 16)
            end if

            call XOR128(CBC_in, tmp, CBC_out)

            call KISA_SEED.SEED_Encrypt(CBC_out, CBC_in, rKey)
        next

        call XOR128(eMAC, eMAC, CBC_out)

        call Word2Byte(tMAC, 0, eMAC, macLen)

        for i = 0 to macLen - 1
            if tMAC(i) <> ct(ctLen - macLen + i) then
                SEED_CCM_Decryption = 1
                exit function
            end if
        next

        SEED_CCM_Decryption = 0
    end function
end class

set KISA_SEED_CCM = new KISA_SEED_CCM_C

%>