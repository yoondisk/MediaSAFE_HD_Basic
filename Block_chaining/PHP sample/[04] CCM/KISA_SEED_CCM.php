<?php
require_once ('KISA_SEED.php');

class KISA_SEED_CCM
{
    static function SHIFTR8(&$x)
    {
        $x[3] = (($x[3] >> 8) & 0x00FFFFFF) ^ (($x[2] << 24) & 0xFF000000);
        $x[2] = (($x[2] >> 8) & 0x00FFFFFF) ^ (($x[1] << 24) & 0xFF000000);
        $x[1] = (($x[1] >> 8) & 0x00FFFFFF) ^ (($x[0] << 24) & 0xFF000000);
        $x[0] = (($x[0] >> 8) & 0x00FFFFFF);
    }

    static function SHIFTR16(&$x)
    {
        $x[3] = (($x[3] >> 16) & 0x0000FFFF) ^ (($x[2] << 16) & 0xFFFF0000);
        $x[2] = (($x[2] >> 16) & 0x0000FFFF) ^ (($x[1] << 16) & 0xFFFF0000);
        $x[1] = (($x[1] >> 16) & 0x0000FFFF) ^ (($x[0] << 16) & 0xFFFF0000);
        $x[0] = (($x[0] >> 16) & 0x0000FFFF);
    }

    static function XOR128(&$R, $A, $B)
    {
        $R[0] = $A[0] ^ $B[0];
        $R[1] = $A[1] ^ $B[1];
        $R[2] = $A[2] ^ $B[2];
        $R[3] = $A[3] ^ $B[3];
    }

    static function INCREASE(&$ctr)
    {
        if ($ctr[3] == 0xFFFFFFFF)
        {
            $ctr[2]++;
            $ctr[3] = 0;
        }
        else
        {
            $ctr[3]++;
        }
    }

    static function ZERO128(&$a)
    {
        $a[0] = 0x00000000;
        $a[1] = 0x00000000;
        $a[2] = 0x00000000;
        $a[3] = 0x00000000;
    }

    static function Byte2Word(&$dst, $src, $src_offset, $srcLen)
    {
        for ($i = 0; $i < $srcLen; $i++)
        {
            $remain = $i & 3;
            
            if ($remain == 0)
                $dst[$i >> 2]  = (($src[$src_offset + $i] & 0x0FF) << 24);
            else if ($remain == 1)
                $dst[$i >> 2] ^= (($src[$src_offset + $i] & 0x0FF) << 16);
            else if ($remain == 2)
                $dst[$i >> 2] ^= (($src[$src_offset + $i] & 0x0FF) <<  8);
            else
                $dst[$i >> 2] ^= ( $src[$src_offset + $i] & 0x0FF);
        }
    }

    static function Word2Byte(&$dst, $dst_offset, $src, $srcLen)
    {
        for ($i = 0; $i < $srcLen; $i++)
        {
            $remain = $i & 3;

            if ($remain == 0)
                $dst[$dst_offset + $i] = ($src[$i >> 2] >> 24) & 0x0FF;
            else if ($remain == 1)
                $dst[$dst_offset + $i] = ($src[$i >> 2] >> 16) & 0x0FF;
            else if ($remain == 2)
                $dst[$dst_offset + $i] = ($src[$i >> 2] >>  8) & 0x0FF;
            else
                $dst[$dst_offset + $i] = ($src[$i >> 2]      ) & 0x0FF;
        }
    }

    static function SEED_CCM_Encryption(
        &$ct,
        $pt, $ptLen,
        $macLen,
        $nonce, $nonceLen,
        $aad, $aadLen,
        $mKey)
    {
        $CTR_in = array_pad(array(),4,0);
        $CTR_out = array_pad(array(),4,0);
        $CBC_in = array_pad(array(),4,0);
        $CBC_out = array_pad(array(),4,0);
        $MAC = array_pad(array(),4,0);
        $tmp = array_pad(array(),8,0);
        $rKey = array_pad(array(),32,0);
        $i = 0; $flag = 0; $tmpLen = 0;
        
        if ($macLen > 16)
            return 1;

        KISA_SEED::SEED_KeySched($mKey, $rKey);

        KISA_SEED_CCM::Byte2Word($CTR_in, $nonce, 0, $nonceLen);
        KISA_SEED_CCM::SHIFTR8($CTR_in);

        $flag = 14 - $nonceLen;

        $CTR_in[0] ^= ($flag << 24);
        
        KISA_SEED::SEED_Encrypt($MAC, $CTR_in, $rKey);

        for ($i = 0; $i < $ptLen; $i += 16)
        {
            KISA_SEED_CCM::INCREASE($CTR_in);

            KISA_SEED_CCM::ZERO128($tmp);

            if (($ptLen - $i) < 16)
                KISA_SEED_CCM::Byte2Word($tmp, $pt, $i, $ptLen - $i);
            else
                KISA_SEED_CCM::Byte2Word($tmp, $pt, $i, 16);

            KISA_SEED::SEED_Encrypt($CTR_out, $CTR_in, $rKey);

            KISA_SEED_CCM::XOR128($tmp, $CTR_out, $tmp);

            if (($ptLen - $i) < 16)
                KISA_SEED_CCM::Word2Byte($ct, $i, $tmp, $ptLen - $i);
            else
                KISA_SEED_CCM::Word2Byte($ct, $i, $tmp, 16);
        }

        KISA_SEED_CCM::Byte2Word($CBC_in, $nonce, 0, $nonceLen);
        KISA_SEED_CCM::SHIFTR8($CBC_in);

        if ($aadLen > 0)
            $flag = 0x00000040;
        else
            $flag = 0x00000000;
        $flag ^= (($macLen - 2) >> 1) << 3;
        $flag ^= 14 - $nonceLen;

        $CBC_in[0] ^= ($flag << 24);
        $CBC_in[3] ^= $ptLen;

        KISA_SEED::SEED_Encrypt($CBC_out, $CBC_in, $rKey);

        if ($aadLen > 0)
        {
            if ($aadLen > 14)
                $tmpLen = 14;
            else
                $tmpLen = $aadLen;
            
            KISA_SEED_CCM::ZERO128($CBC_in);

            KISA_SEED_CCM::Byte2Word($CBC_in, $aad, 0, $tmpLen);
            KISA_SEED_CCM::SHIFTR16($CBC_in);

            $CBC_in[0] ^= (($aadLen << 16) & 0xFFFF0000);

            KISA_SEED_CCM::XOR128($CBC_in, $CBC_in, $CBC_out);

            KISA_SEED::SEED_Encrypt($CBC_out, $CBC_in, $rKey);

            for ($i = $tmpLen; $i < $aadLen; $i += 16)
            {
                KISA_SEED_CCM::ZERO128($CBC_in);

                if (($aadLen - $i) < 16)
                    KISA_SEED_CCM::Byte2Word($CBC_in, $aad, $i, $aadLen - $i);
                else
                    KISA_SEED_CCM::Byte2Word($CBC_in, $aad, $i, 16);
                
                KISA_SEED_CCM::XOR128($CBC_in, $CBC_in, $CBC_out);

                KISA_SEED::SEED_Encrypt($CBC_out, $CBC_in, $rKey);
            }
        }

        for ($i = 0; $i < $ptLen; $i += 16)
        {
            KISA_SEED_CCM::ZERO128($tmp);

            if (($ptLen - $i) < 16)
                KISA_SEED_CCM::Byte2Word($tmp, $pt, $i, $ptLen - $i);
            else
                KISA_SEED_CCM::Byte2Word($tmp, $pt, $i, 16);
            
            KISA_SEED_CCM::XOR128($CBC_in, $tmp, $CBC_out);

            KISA_SEED::SEED_Encrypt($CBC_out, $CBC_in, $rKey);
        }

        KISA_SEED_CCM::XOR128($MAC, $MAC, $CBC_out);

        KISA_SEED_CCM::Word2Byte($ct, $ptLen, $MAC, $macLen);

        return 0;
    }


    static function SEED_CCM_Decryption(
        &$pt,
        $ct, $ctLen,
        $macLen,
        $nonce, $nonceLen,
        $aad, $aadLen,
        $mKey)
    {
        $CTR_in = array_pad(array(),4,0);
        $CTR_out = array_pad(array(),4,0);
        $CBC_in = array_pad(array(),4,0);
        $CBC_out = array_pad(array(),4,0);
        $MAC = array_pad(array(),4,0);
        $tMAC = array_pad(array(),16,0);
        $tmp = array_pad(array(),8,0);
        $rKey = array_pad(array(),32,0);
        $i = 0; $j = 0; $flag = 0; $tmpLen = 0;    

        if ($macLen > 16)
            return 1;

        KISA_SEED::SEED_KeySched($mKey, $rKey);

        KISA_SEED_CCM::Byte2Word($CTR_in, $nonce, 0, $nonceLen);
        KISA_SEED_CCM::SHIFTR8($CTR_in);

        $flag = 14 - $nonceLen;

        $CTR_in[0] ^= ($flag << 24);
        
        KISA_SEED::SEED_Encrypt($MAC, $CTR_in, $rKey);

        for ($i = 0; $i < $ctLen - $macLen; $i += 16)
        {
            KISA_SEED_CCM::INCREASE($CTR_in);

            KISA_SEED_CCM::ZERO128($tmp);

            if (($ctLen - $macLen - $i) < 16)
                KISA_SEED_CCM::Byte2Word($tmp, $ct, $i, $ctLen - $macLen - $i);
            else
                KISA_SEED_CCM::Byte2Word($tmp, $ct, $i, 16);

                KISA_SEED::SEED_Encrypt($CTR_out, $CTR_in, $rKey);

            KISA_SEED_CCM::XOR128($tmp, $CTR_out, $tmp);

            if (($ctLen - $macLen - $i) < 16)
                KISA_SEED_CCM::Word2Byte($pt, $i, $tmp, $ctLen - $macLen - $i);
            else
                KISA_SEED_CCM::Word2Byte($pt, $i, $tmp, 16);
        }

        KISA_SEED_CCM::Byte2Word($CBC_in, $nonce, 0, $nonceLen);
        KISA_SEED_CCM::SHIFTR8($CBC_in);

        if ($aadLen > 0)
            $flag = 0x00000040;
        else
            $flag = 0x00000000;
        
        $flag ^= (($macLen - 2) >> 1) << 3;
        $flag ^= 14 - $nonceLen;

        $CBC_in[0] ^= ($flag << 24);
        $CBC_in[3] ^= $ctLen - $macLen;

        KISA_SEED::SEED_Encrypt($CBC_out, $CBC_in, $rKey);

        if ($aadLen > 0)
        {
            if ($aadLen > 14)
                $tmpLen = 14;
            else
                $tmpLen = $aadLen;

            KISA_SEED_CCM::ZERO128($CBC_in);

            KISA_SEED_CCM::Byte2Word($CBC_in, $aad, 0, $tmpLen);
            KISA_SEED_CCM::SHIFTR16($CBC_in);

            $CBC_in[0] ^= ($aadLen << 16);

            KISA_SEED_CCM::XOR128($CBC_in, $CBC_in, $CBC_out);

            KISA_SEED::SEED_Encrypt($CBC_out, $CBC_in, $rKey);

            for ($i = $tmpLen; $i < $aadLen; $i += 16)
            {
                KISA_SEED_CCM::ZERO128($CBC_in);

                if (($aadLen - $i) < 16)
                    KISA_SEED_CCM::Byte2Word($CBC_in, $aad, $i, $aadLen - $i);
                else
                    KISA_SEED_CCM::Byte2Word($CBC_in, $aad, $i, 16);

                KISA_SEED_CCM::XOR128($CBC_in, $CBC_in, $CBC_out);

                KISA_SEED::SEED_Encrypt($CBC_out, $CBC_in, $rKey);
            }
        }

        for ($i = 0; $i < $ctLen - $macLen; $i += 16)
        {
            KISA_SEED_CCM::ZERO128($tmp);

            if (($ctLen - $macLen - $i) < 16)
                KISA_SEED_CCM::Byte2Word($tmp, $pt, $i, $ctLen - $macLen - $i);
            else
                KISA_SEED_CCM::Byte2Word($tmp, $pt, $i, 16);

            KISA_SEED_CCM::XOR128($CBC_in, $tmp, $CBC_out);

            KISA_SEED::SEED_Encrypt($CBC_out, $CBC_in, $rKey);
        }

        KISA_SEED_CCM::XOR128($MAC, $MAC, $CBC_out);

        KISA_SEED_CCM::Word2Byte($tMAC, 0, $MAC, $macLen);

        for ($i = 0; $i < $macLen; $i++)
        {
            if ($tMAC[$i] != $ct[$ctLen - $macLen + $i])
            {
                for ($j = 0; $j < $ctLen - $macLen; $j++)
                    $pt[$j] = 0;

                return 1;
            }
        }

        return 0;
    }


}
?>