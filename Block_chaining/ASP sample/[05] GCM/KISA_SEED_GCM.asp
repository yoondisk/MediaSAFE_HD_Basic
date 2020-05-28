<!--#include file="KISA_SEED.asp" -->
<%

const HE1000000 = -520093696

class KISA_SEED_GCM_C
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
        for i=1 to (s-1)
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

    private function SHIFTR1(v)
        v(3) = (SRShift(v(3),1) and H7FFFFFFF) xor SLShift(v(2),31)
        v(2) = (SRShift(v(2),1) and H7FFFFFFF) xor SLShift(v(1),31)
        v(1) = (SRShift(v(1),1) and H7FFFFFFF) xor SLShift(v(0),31)
        v(0) =  SRShift(v(0),1) and H7FFFFFFF
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

        for i=0 to (src_len-1)
            remain = i mod 4
            temp = (int)(i/4)

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

        for i=0 to (src_len-1)
            remain = i mod 4
            temp = (int)(i/4)

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

    private function GHASH(byref output, input, H)
        dim W(3)
        dim Z(3)
        dim i
        
        call ZERO128(W)
        call ZERO128(Z)

        call XOR128(Z, output, input)

        for i=0 to 127
            if (HFF and SRShift(H((int)(i / 32)), (31 - (i and 31))) and 1) = 1 then
                call XOR128(W, W, Z)
            end if

            if (Z(3) and 1)=1 then
                call SHIFTR1(Z)
                Z(0) = Z(0) xor HE1000000
            else
                call SHIFTR1(Z)
            end if
        next

        output(0) = W(0)
        output(1) = W(1)
        output(2) = W(2)
        output(3) = W(3)
    end function

    public function SEED_GCM_Encryption(byref ct, pt, ptLen, macLen, nonce, nonceLen, aad, aadLen, mKey)
        dim rKey(31)
        dim H(3)
        dim Z(3)
        dim tmp(7)
        dim GCTR_in(3)
        dim GCTR_out(3)
        dim GHASH_in(3)
        dim GHASH_out(3)
        dim i

        if macLen > 16 then
            SEED_GCM_Encryption = 1
        end if

        call KISA_SEED.SEED_KeySched(mKey, rKey)

        call ZERO128(H)
        call KISA_SEED.SEED_Encrypt(H, H, rKey)

        if (nonceLen = 12) then
            call Byte2Word(GCTR_in, nonce, 0, nonceLen)

            GCTR_in(3) = 1

            call KISA_SEED.SEED_Encrypt(Z, GCTR_in, rKey)
        else
            for i=1 to nonceLen step 16
                call ZERO128(tmp)

                if (nonceLen - i + 1) < 16 then
                    call Byte2Word(tmp, nonce, i - 1, nonceLen - i + 1)
                else
                    call Byte2Word(tmp, nonce, i - 1, 16)
                end if

                call GHASH(GCTR_in, tmp, H)
            next

            call ZERO128(tmp)
            tmp(3) = nonceLen * 8

            call GHASH(GCTR_in, tmp, H)

            call KISA_SEED.SEED_Encrypt(Z, GCTR_in, rKey)
        end if

        for i=1 to ptLen step 16
            call ZERO128(tmp)

            call INCREASE(GCTR_in)

            call KISA_SEED.SEED_Encrypt(GCTR_out, GCTR_in, rKey)

            if (ptLen - i + 1) < 16 then
                call Byte2Word(tmp, pt, i - 1, ptLen - i + 1)
                call XOR128(GCTR_out, GCTR_out, tmp)
                call Word2Byte(ct, i - 1, GCTR_out, ptLen - i + 1)
            else
                call Byte2Word(tmp, pt, i - 1, 16)
                call XOR128(GCTR_out, GCTR_out, tmp)
                call Word2Byte(ct, i - 1, GCTR_out, 16)
            end if
        next

        for i=1 to aadLen step 16
            call ZERO128(GHASH_in)

            if (aadLen - i - 1) < 16 then
                call Byte2Word(GHASH_in, aad, i - 1, aadLen - i + 1)
            else
                call Byte2Word(GHASH_in, aad, i - 1, 16)
            end if

            call GHASH(GHASH_out, GHASH_in, H)
        next

        for i=1 to ptLen step 16
            call ZERO128(GHASH_in)

            if (ptLen - i - 1) < 16 then
                call Byte2Word(GHASH_in, ct, i - 1, ptLen - i + 1)
            else
                call Byte2Word(GHASH_in, ct, i - 1, 16)
            end if

            call GHASH(GHASH_out, GHASH_in, H)
        next

        call ZERO128(GHASH_in)

        GHASH_in(1) = GHASH_in(1) xor (aadLen * 8)
        GHASH_in(3) = GHASH_in(3) xor (ptLen * 8)

        call GHASH(GHASH_out, GHASH_in, H)

        call XOR128(GHASH_out, GHASH_out, Z)

        call Word2Byte(ct, ptLen, GHASH_out, macLen)

        SEED_GCM_Encryption = 0
    end function

    public function SEED_GCM_Decryption(byref pt, ct, ctLen, macLen, nonce, nonceLen, aad, aadLen, mKey)
        dim rKey(31)
        dim H(3)
        dim Z(3)
        dim tmp(7)
        dim GCTR_in(3)
        dim GCTR_out(3)
        dim GHASH_in(3)
        dim GHASH_out(3)
        dim tMAC(15)
        dim i

        if macLen > 16 then
            SEED_GCM_Decryption = 1
        end if

        call KISA_SEED.SEED_KeySched(mKey, rKey)

        call ZERO128(H)
        call KISA_SEED.SEED_Encrypt(H, H, rKey)

        if (nonceLen=12) then
            call Byte2Word(GCTR_in, nonce, 0, nonceLen)

            GCTR_in(3) = 1

            call KISA_SEED.SEED_Encrypt(Z, GCTR_in, rKey)
        else
            for i = 1 to nonceLen step 16
                call ZERO128(tmp)

                if (nonceLen - i + 1) < 16 then
                    call Byte2Word(tmp, nonce, i - 1, nonceLen - i + 1)
                else
                    call Byte2Word(tmp, nonce, i - 1, 16)
                end if

                call GHASH(GCTR_in, tmp, H)
            next

            call ZERO128(tmp)
            tmp(3) = nonceLen * 8

            call GHASH(GCTR_in, tmp, H)

            call KISA_SEED.SEED_Encrypt(Z, GCTR_in, rKey)
        end if

        for i = 1 to ctLen - macLen step 16
            call ZERO128(tmp)

            call INCREASE(GCTR_in)

            call KISA_SEED.SEED_Encrypt(GCTR_out, GCTR_in, rKey)

            if (ctLen - macLen - i + 1) < 16 then
                call Byte2Word(tmp, ct, i - 1, ctLen - macLen - i + 1)
                call XOR128(GCTR_out, GCTR_out, tmp)
                call Word2Byte(pt, i - 1, GCTR_out, ctLen - macLen - i + 1)
            else
                call Byte2Word(tmp, ct, i - 1, 16)
                call XOR128(GCTR_out, GCTR_out, tmp)
                call Word2Byte(pt, i - 1, GCTR_out, 16)
            end if
        next

        for i = 1 to aadLen step 16
            call ZERO128(GHASH_in)

            if (aadLen - i + 1) < 16 then
                call Byte2Word(GHASH_in, aad, i - 1, aadLen - i + 1)
            else
                call Byte2Word(GHASH_in, aad, i - 1, 16)
            end if

            call GHASH(GHASH_out, GHASH_in, H)
        next

        for i = 1 to ctLen - macLen step 16
            call ZERO128(GHASH_in)

            if (ctLen - macLen - i + 1) < 16 then
                call Byte2Word(GHASH_in, ct, i - 1, ctLen - macLen - i + 1)
            else
                call Byte2Word(GHASH_in, ct, i - 1, 16)
            end if

            call GHASH(GHASH_out, GHASH_in, H)
        next

        call ZERO128(GHASH_in)

        GHASH_in(1) = GHASH_in(1) xor (aadLen * 8)
        GHASH_in(3) = GHASH_in(3) xor ((ctLen - macLen) * 8)

        call GHASH(GHASH_out, GHASH_in, H)

        call XOR128(GHASH_out, GHASH_out, Z)

        call Word2Byte(tMAC, 0, GHASH_out, macLen)

        for i = 1 to macLen
            if tMAC(i - 1) <> ct(ctLen - macLen + i - 1) then
                SEED_GCM_Decryption = 1
                exit function
            end if
        next

        SEED_GCM_Decryption = 0
    end function
end class

set KISA_SEED_GCM = new KISA_SEED_GCM_C

%>