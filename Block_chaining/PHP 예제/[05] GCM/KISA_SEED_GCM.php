<?php
require_once ('KISA_SEED.php');

class KISA_SEED_GCM
{
    static function SHIFTR1(&$x)
    {
        $x[3] = (($x[3] >> 1) & 0x7FFFFFFF) ^ (($x[2] << 31) & 0x80000000);
        $x[2] = (($x[2] >> 1) & 0x7FFFFFFF) ^ (($x[1] << 31) & 0x80000000);
        $x[1] = (($x[1] >> 1) & 0x7FFFFFFF) ^ (($x[0] << 31) & 0x80000000);
        $x[0] = (($x[0] >> 1) & 0x7FFFFFFF);
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

    static function GHASH(&$out, $in, $H)
    {
        $W = array_pad(array(),4,0);
        $Z = array_pad(array(),4,0);
        $i = 0;
    
        KISA_SEED_GCM::XOR128($Z, $out, $in);
    
        for ($i = 0; $i < 128; $i++)
        {
            if (($H[$i >> 5] >> (31 - ($i & 31))) & 1)
            {
                KISA_SEED_GCM::XOR128($W, $W, $Z);
            }
            
            if ($Z[3] & 0x01)
            {
                KISA_SEED_GCM::SHIFTR1($Z);
                $Z[0] ^= 0xE1000000;
            }
            else
            {
                KISA_SEED_GCM::SHIFTR1($Z);
            }
        }
    
        $out[0] = $W[0];
        $out[1] = $W[1];
        $out[2] = $W[2];
        $out[3] = $W[3];
    }

    static function SEED_GCM_Encryption(
        &$ct,
        $pt, $ptLen,
        $macLen,
        $nonce, $nonceLen,
        $aad, $aadLen,
        $mKey)
    {
        $rKey = array_pad(array(),32,0);
        $H = array_pad(array(),4,0);
        $Z = array_pad(array(),4,0);
        $tmp = array_pad(array(),8,0);
        $GCTR_in = array_pad(array(),4,0);
        $GCTR_out = array_pad(array(),4,0);
        $GHASH_in = array_pad(array(),4,0);
        $GHASH_out = array_pad(array(),4,0);
        $i = 0;
    
        if ($macLen > 16)
            return 1;
    
        KISA_SEED::SEED_KeySched($mKey, $rKey);
    
        KISA_SEED::SEED_Encrypt($H, $H, $rKey);
    
        if ($nonceLen == 12)
        {
            KISA_SEED_GCM::Byte2Word($GCTR_in, $nonce, 0, $nonceLen);
    
            $GCTR_in[3] = 1;
            
            KISA_SEED::SEED_Encrypt($Z, $GCTR_in, $rKey);
        }
        else
        {
            for ($i = 0; $i < $nonceLen; $i += 16)
            {
                KISA_SEED_GCM::ZERO128($tmp);
    
                if (($nonceLen - $i) < 16)
                    KISA_SEED_GCM::Byte2Word($tmp, $nonce, $i, $nonceLen - $i);
                else
                    KISA_SEED_GCM::Byte2Word($tmp, $nonce, $i, 16);
                
                KISA_SEED_GCM::GHASH($GCTR_in, $tmp, $H);
            }
    
            KISA_SEED_GCM::ZERO128($tmp);
            $tmp[3] = ($nonceLen << 3);
    
            KISA_SEED_GCM::GHASH($GCTR_in, $tmp, $H);
    
            KISA_SEED::SEED_Encrypt($Z, $GCTR_in, $rKey);
        }
    
        for ($i = 0; $i < $ptLen; $i += 16)
        {
            KISA_SEED_GCM::ZERO128($tmp);
    
            KISA_SEED_GCM::INCREASE($GCTR_in);
    
            KISA_SEED::SEED_Encrypt($GCTR_out, $GCTR_in, $rKey);
    
            if (($ptLen - $i) < 16)
            {
                KISA_SEED_GCM::Byte2Word($tmp, $pt, $i, $ptLen - $i);
                KISA_SEED_GCM::XOR128($GCTR_out, $GCTR_out, $tmp);
                KISA_SEED_GCM::Word2Byte($ct, $i, $GCTR_out, $ptLen - $i);
            }
            else
            {
                KISA_SEED_GCM::Byte2Word($tmp, $pt, $i, 16);
                KISA_SEED_GCM::XOR128($GCTR_out, $GCTR_out, $tmp);
                KISA_SEED_GCM::Word2Byte($ct, $i, $GCTR_out, 16);
            }
        }
    
        for ($i = 0; $i < $aadLen; $i += 16)
        {
            KISA_SEED_GCM::ZERO128($GHASH_in);
    
            if (($aadLen - $i) < 16)
                KISA_SEED_GCM::Byte2Word($GHASH_in, $aad, $i, $aadLen - $i);
            else
                KISA_SEED_GCM::Byte2Word($GHASH_in, $aad, $i, 16);
    
            KISA_SEED_GCM::GHASH($GHASH_out, $GHASH_in, $H);
        }
    
        for ($i = 0; $i < $ptLen; $i += 16)
        {
            KISA_SEED_GCM::ZERO128($GHASH_in);
    
            if (($ptLen - $i) < 16)
                KISA_SEED_GCM::Byte2Word($GHASH_in, $ct, $i, $ptLen - $i);
            else
                KISA_SEED_GCM::Byte2Word($GHASH_in, $ct, $i, 16);
    
            KISA_SEED_GCM::GHASH($GHASH_out, $GHASH_in, $H);
        }
    
        KISA_SEED_GCM::ZERO128($GHASH_in);
    
        $GHASH_in[1] ^= $aadLen << 3;
        $GHASH_in[3] ^= $ptLen << 3;
    
        KISA_SEED_GCM::GHASH($GHASH_out, $GHASH_in, $H);
    
        KISA_SEED_GCM::XOR128($GHASH_out, $GHASH_out, $Z);
    
        KISA_SEED_GCM::Word2Byte($ct, $ptLen, $GHASH_out, $macLen);

        return 0;
    }

    static function SEED_GCM_Decryption(
        &$pt,
        $ct, $ctLen,
        $macLen,
        $nonce, $nonceLen,
        $aad, $aadLen,
        $mKey)
    {
        $rKey = array_pad(array(),32,0);
        $H = array_pad(array(),4,0);
        $Z = array_pad(array(),4,0);
        $tmp = array_pad(array(),8,0);
        $GCTR_in = array_pad(array(),4,0);
        $GCTR_out = array_pad(array(),4,0);
        $GHASH_in = array_pad(array(),4,0);
        $GHASH_out = array_pad(array(),4,0);
        $MAC = array_pad(array(),16,0);
        $i = 0;
        $j = 0;
    
        if ($macLen > 16)
            return 1;
    
        KISA_SEED::SEED_KeySched($mKey, $rKey);
    
        KISA_SEED::SEED_Encrypt($H, $H, $rKey);
    
        if ($nonceLen == 12)
        {
            KISA_SEED_GCM::Byte2Word($GCTR_in, $nonce, 0, $nonceLen);
    
            $GCTR_in[3] = 1;
            
            KISA_SEED::SEED_Encrypt($Z, $GCTR_in, $rKey);
        }
        else
        {
            for ($i = 0; $i < $nonceLen; $i += 16)
            {
                KISA_SEED_GCM::ZERO128($tmp);
    
                if (($nonceLen - $i) < 16)
                    KISA_SEED_GCM::Byte2Word($tmp, $nonce, $i, $nonceLen - $i);
                else
                    KISA_SEED_GCM::Byte2Word($tmp, $nonce, $i, 16);
                
                KISA_SEED_GCM::GHASH($GCTR_in, $tmp, $H);
            }
    
            KISA_SEED_GCM::ZERO128($tmp);
            $tmp[3] = ($nonceLen << 3);
    
            KISA_SEED_GCM::GHASH($GCTR_in, $tmp, $H);
            
            KISA_SEED::SEED_Encrypt($Z, $GCTR_in, $rKey);
        }
    
        for ($i = 0; $i < $ctLen - $macLen; $i += 16)
        {
            KISA_SEED_GCM::ZERO128($tmp);
    
            KISA_SEED_GCM::INCREASE($GCTR_in);
    
            KISA_SEED::SEED_Encrypt($GCTR_out, $GCTR_in, $rKey);
    
            if (($ctLen - $macLen - $i) < 16)
            {
                KISA_SEED_GCM::Byte2Word($tmp, $ct, $i, $ctLen - $macLen - $i);
                KISA_SEED_GCM::XOR128($GCTR_out, $GCTR_out, $tmp);
                KISA_SEED_GCM::Word2Byte($pt, $i, $GCTR_out, $ctLen - $macLen - $i);
            }
            else
            {
                KISA_SEED_GCM::Byte2Word($tmp, $ct, $i, 16);
                KISA_SEED_GCM::XOR128($GCTR_out, $GCTR_out, $tmp);
                KISA_SEED_GCM::Word2Byte($pt, $i, $GCTR_out, 16);
            }
        }
    
        for ($i = 0; $i < $aadLen; $i += 16)
        {
            KISA_SEED_GCM::ZERO128($GHASH_in);
    
            if (($aadLen - $i) < 16)
                KISA_SEED_GCM::Byte2Word($GHASH_in, $aad, $i, $aadLen - $i);
            else
                KISA_SEED_GCM::Byte2Word($GHASH_in, $aad, $i, 16);
    
            KISA_SEED_GCM::GHASH($GHASH_out, $GHASH_in, $H);
        }
    
        for ($i = 0; $i < $ctLen - $macLen; $i += 16)
        {
            KISA_SEED_GCM::ZERO128($GHASH_in);
    
            if (($ctLen - $macLen - $i) < 16)
                KISA_SEED_GCM::Byte2Word($GHASH_in, $ct, $i, $ctLen - $macLen - $i);
            else
                KISA_SEED_GCM::Byte2Word($GHASH_in, $ct, $i, 16);
    
            KISA_SEED_GCM::GHASH($GHASH_out, $GHASH_in, $H);
        }
    
        KISA_SEED_GCM::ZERO128($GHASH_in);
    
        $GHASH_in[1] = $aadLen << 3;
        $GHASH_in[3] = ($ctLen - $macLen) << 3;
    
        KISA_SEED_GCM::GHASH($GHASH_out, $GHASH_in, $H);
    
        KISA_SEED_GCM::XOR128($GHASH_out, $GHASH_out, $Z);
    
        KISA_SEED_GCM::Word2Byte($MAC, 0, $GHASH_out, $macLen);
    
        for ($i = 0; $i < $macLen; $i++)
        {
            if ($ct[$ctLen - $macLen + $i] != $MAC[$i])
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