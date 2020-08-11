#include "KISA_SEED.h"


void SEED_CMAC_SubkeySched(unsigned char *sKey)
{
	int i = 0, carry = sKey[0] >> 7;

	for (i = 0; i < 15; i++)
		sKey[i] = (sKey[i] << 1) | (sKey[i + 1] >> 7);

	sKey[i] = sKey[i] << 1;

	if (carry)
		sKey[i] ^= 0x87;
}

int SEED_Generate_CMAC(unsigned char *pMAC, int macLen, unsigned char *pIn, int inLen, unsigned char *mKey)
{
	unsigned char L[BLOCK_SIZE_SEED];
	unsigned char temp[BLOCK_SIZE_SEED];
	unsigned int subKey[BLOCK_SIZE_SEED / 4] = { 0x00, };
	unsigned int temp1[BLOCK_SIZE_SEED / 4] = { 0x00, };
	unsigned int rKey[32] = { 0x00, };
	int blockLen = 0, i = 0, j = 0;

	if (macLen > BLOCK_SIZE_SEED)
		return 1;

	SEED_KeySched(mKey, rKey);
	SEED_Encrypt(subKey, subKey, rKey);

	Word2Byte(L, subKey, BLOCK_SIZE_SEED);

	// make K1
	SEED_CMAC_SubkeySched(L);

	if (inLen == 0)
	{
		// make K2
		SEED_CMAC_SubkeySched(L);

		L[0] ^= 0x80;

		Byte2Word(subKey, L, BLOCK_SIZE_SEED);
		SEED_Encrypt(temp1, subKey, rKey);
	}
	else
	{
		// make K2
		SEED_CMAC_SubkeySched(L);

		blockLen = (inLen + BLOCK_SIZE_SEED) / BLOCK_SIZE_SEED;

		for (i = 0; i < blockLen - 1; i++)
		{
			Word2Byte(temp, temp1, BLOCK_SIZE_SEED);
			for (j = 0; j < BLOCK_SIZE_SEED; j++)
				temp[j] ^= pIn[BLOCK_SIZE_SEED * i + j];

			Byte2Word(temp1, temp, BLOCK_SIZE_SEED);

			SEED_Encrypt(temp1, temp1, rKey);
		}

		Word2Byte(temp, temp1, BLOCK_SIZE_SEED);

		for (j = 0; (BLOCK_SIZE_SEED * i + j) < inLen; j++)
			temp[j] ^= pIn[BLOCK_SIZE_SEED * i + j] ^ L[j];
		temp[j] ^= 0x80 ^ L[j];
		for (j += 1; j < BLOCK_SIZE_SEED; j++)
			temp[j] ^= L[j];

		Byte2Word(temp1, temp, BLOCK_SIZE_SEED);

		SEED_Encrypt(temp1, temp1, rKey);
	}

	Word2Byte(temp, temp1, BLOCK_SIZE_SEED);

	for (i = 0; i < macLen; i++)
		pMAC[i] = temp[i];

	return 0;
}

int SEED_Verify_CMAC(unsigned char *pMAC, int macLen, unsigned char *pIn, int inLen, unsigned char *mKey)
{
	unsigned char L[BLOCK_SIZE_SEED];
	unsigned char temp[BLOCK_SIZE_SEED];
	unsigned int subKey[BLOCK_SIZE_SEED / 4] = { 0x00, };
	unsigned int temp1[BLOCK_SIZE_SEED / 4] = { 0x00, };
	unsigned int rKey[32] = { 0x00, };
	int blockLen = 0, i = 0, j = 0;

	if (macLen > BLOCK_SIZE_SEED)
		return 1;

	SEED_KeySched(mKey, rKey);
	SEED_Encrypt(subKey, subKey, rKey);

	Word2Byte(L, subKey, BLOCK_SIZE_SEED);

	// make K1
	SEED_CMAC_SubkeySched(L);

	if (inLen == 0)
	{
		// make K2
		SEED_CMAC_SubkeySched(L);

		L[0] ^= 0x80;

		Byte2Word(subKey, L, BLOCK_SIZE_SEED);
		SEED_Encrypt(temp1, subKey, rKey);
	}
	else
	{
		// make K2
		SEED_CMAC_SubkeySched(L);

		blockLen = (inLen + BLOCK_SIZE_SEED) / BLOCK_SIZE_SEED;

		for (i = 0; i < blockLen - 1; i++)
		{
			Word2Byte(temp, temp1, BLOCK_SIZE_SEED);
			for (j = 0; j < BLOCK_SIZE_SEED; j++)
				temp[j] ^= pIn[BLOCK_SIZE_SEED * i + j];

			Byte2Word(temp1, temp, BLOCK_SIZE_SEED);

			SEED_Encrypt(temp1, temp1, rKey);
		}

		Word2Byte(temp, temp1, BLOCK_SIZE_SEED);

		for (j = 0; (BLOCK_SIZE_SEED * i + j) < inLen; j++)
			temp[j] ^= pIn[BLOCK_SIZE_SEED * i + j] ^ L[j];
		temp[j] ^= 0x80 ^ L[j];
		for (j += 1; j < BLOCK_SIZE_SEED; j++)
			temp[j] ^= L[j];

		Byte2Word(temp1, temp, BLOCK_SIZE_SEED);

		SEED_Encrypt(temp1, temp1, rKey);
	}

	Word2Byte(temp, temp1, BLOCK_SIZE_SEED);

	for (i = 0; i < macLen; i++)
		if (pMAC[i] != temp[i])
			return 1;

	return 0;
}