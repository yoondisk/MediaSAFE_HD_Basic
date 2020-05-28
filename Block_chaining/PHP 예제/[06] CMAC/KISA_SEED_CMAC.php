<?php
require_once ('KISA_SEED.php');

class KISA_SEED_CMAC
{
    static function Byte2Word(&$dst, $src, $srcLen)
    {
        for ($i = 0; $i < $srcLen; $i++)
        {
            $remain = $i & 3;
            
            if ($remain == 0)
                $dst[$i >> 2]  = (($src[$i] & 0x0FF) << 24);
            else if ($remain == 1)
                $dst[$i >> 2] ^= (($src[$i] & 0x0FF) << 16);
            else if ($remain == 2)
                $dst[$i >> 2] ^= (($src[$i] & 0x0FF) <<  8);
            else
                $dst[$i >> 2] ^= ( $src[$i] & 0x0FF);
        }
    }

    static function Word2Byte(&$dst, $src, $srcLen)
    {
        for ($i = 0; $i < $srcLen; $i++)
        {
            $remain = $i & 3;

            if ($remain == 0)
                $dst[$i] = ($src[$i >> 2] >> 24) & 0x0FF;
            else if ($remain == 1)
                $dst[$i] = ($src[$i >> 2] >> 16) & 0x0FF;
            else if ($remain == 2)
                $dst[$i] = ($src[$i >> 2] >>  8) & 0x0FF;
            else
                $dst[$i] = ($src[$i >> 2]      ) & 0x0FF;
        }
    }
	
	static function SEED_CMAC_SubkeySched(&$sKey)
	{
		$i = 0;
		$carry = $sKey[0] >> 7;

		for ($i = 0; $i < 15; $i++)
			$sKey[$i] = (($sKey[$i] << 1) | ($sKey[$i + 1] >> 7)) & 0xff;

		$sKey[$i] = ($sKey[$i] << 1) & 0xff;

		if ($carry)
			$sKey[$i] ^= 0x87;
	}
	
	static function SEED_Generate_CMAC(&$pMAC, $macLen, $pIn, $inLen, $mKey)
	{
		$L = array_pad(array(),16,0);
		$temp = array_pad(array(),16,0);
		$subKey = array_pad(array(),4,0);
		$temp1 = array_pad(array(),4,0);
		$rKey = array_pad(array(),32,0);
		$blockLen = 0;
		$i = 0;
		$j = 0;

		if ($macLen > 16)
			return 1;

		KISA_SEED::SEED_KeySched($mKey, $rKey);
		KISA_SEED::SEED_Encrypt($subKey, $subKey, $rKey);

		KISA_SEED_CMAC::Word2Byte($L, $subKey, 16);

		// make K1
		KISA_SEED_CMAC::SEED_CMAC_SubkeySched($L);

		if ($inLen == 0)
		{
			// make K2
			KISA_SEED_CMAC::SEED_CMAC_SubkeySched($L);

			$L[0] ^= 0x80;

			KISA_SEED_CMAC::Byte2Word($subKey, $L, 16);
			KISA_SEED::SEED_Encrypt($temp1, $subKey, $rKey);
		}
		else
		{
			// make K2
			KISA_SEED_CMAC::SEED_CMAC_SubkeySched($L);

			$blockLen = ($inLen + 16) / 16;

			for ($i = 0; $i < $blockLen - 1; $i++)
			{
				KISA_SEED_CMAC::Word2Byte($temp, $temp1, 16);
				for ($j = 0; $j < 16; $j++)
					$temp[$j] ^= $pIn[16 * $i + $j];

				KISA_SEED_CMAC::Byte2Word($temp1, $temp, 16);

				KISA_SEED::SEED_Encrypt($temp1, $temp1, $rKey);
			}

			KISA_SEED_CMAC::Word2Byte($temp, $temp1, 16);

			for ($j = 0; (16 * $i + $j) < $inLen; $j++)
				$temp[$j] ^= $pIn[16 * $i + $j] ^ $L[$j];
			$temp[$j] ^= 0x80 ^ $L[$j];
			for ($j += 1; $j < 16; $j++)
				$temp[$j] ^= $L[$j];

			KISA_SEED_CMAC::Byte2Word($temp1, $temp, 16);

			KISA_SEED::SEED_Encrypt($temp1, $temp1, $rKey);
		}

		KISA_SEED_CMAC::Word2Byte($temp, $temp1, 16);

		for ($i = 0; $i < $macLen; $i++)
			$pMAC[$i] = $temp[$i];

		return 0;
	}

    static function SEED_Verify_CMAC($pMAC, $macLen, $pIn, $inLen, $mKey)
	{
		$L = array_pad(array(),16,0);
		$temp = array_pad(array(),16,0);
		$subKey = array_pad(array(),4,0);
		$temp1 = array_pad(array(),4,0);
		$rKey = array_pad(array(),32,0);
		$blockLen = 0;
		$i = 0;
		$j = 0;

		if ($macLen > 16)
			return 1;

		KISA_SEED::SEED_KeySched($mKey, $rKey);
		KISA_SEED::SEED_Encrypt($subKey, $subKey, $rKey);

		KISA_SEED_CMAC::Word2Byte($L, $subKey, 16);

		// make K1
		KISA_SEED_CMAC::SEED_CMAC_SubkeySched($L);

		if ($inLen == 0)
		{
			// make K2
			KISA_SEED_CMAC::SEED_CMAC_SubkeySched($L);

			$L[0] ^= 0x80;

			KISA_SEED_CMAC::Byte2Word($subKey, $L, 16);
			KISA_SEED::SEED_Encrypt($temp1, $subKey, $rKey);
		}
		else
		{
			// make K2
			KISA_SEED_CMAC::SEED_CMAC_SubkeySched($L);

			$blockLen = ($inLen + 16) / 16;

			for ($i = 0; $i < $blockLen - 1; $i++)
			{
				KISA_SEED_CMAC::Word2Byte($temp, $temp1, 16);
				for ($j = 0; $j < 16; $j++)
					$temp[$j] ^= $pIn[16 * $i + $j];

				KISA_SEED_CMAC::Byte2Word($temp1, $temp, 16);

				KISA_SEED::SEED_Encrypt($temp1, $temp1, $rKey);
			}

			KISA_SEED_CMAC::Word2Byte($temp, $temp1, 16);

			for ($j = 0; (16 * $i + $j) < $inLen; $j++)
				$temp[$j] ^= $pIn[16 * $i + $j] ^ $L[$j];
			$temp[$j] ^= 0x80 ^ $L[$j];
			for ($j += 1; $j < 16; $j++)
				$temp[$j] ^= $L[$j];

			KISA_SEED_CMAC::Byte2Word($temp1, $temp, 16);

			KISA_SEED::SEED_Encrypt($temp1, $temp1, $rKey);
		}

		KISA_SEED_CMAC::Word2Byte($temp, $temp1, 16);

		for ($i = 0; $i < $macLen; $i++)
			if($pMAC[$i] != $temp[$i])
				return 1;

		return 0;
	}
}
?>