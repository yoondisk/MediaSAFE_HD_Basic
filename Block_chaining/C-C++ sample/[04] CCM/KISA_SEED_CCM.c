#include "KISA_SEED.h"
#include "KISA_SEED_CCM.h"


#define SHIFTR(x,n)                                     \
    (x)[3] = ((x)[3] >> (n)) ^ ((x)[2] << (32 - (n)));  \
    (x)[2] = ((x)[2] >> (n)) ^ ((x)[1] << (32 - (n)));  \
    (x)[1] = ((x)[1] >> (n)) ^ ((x)[0] << (32 - (n)));  \
    (x)[0] = ((x)[0] >> (n));

#define XOR128( R, A, B )       \
    (R)[0] = (A)[0] ^ (B)[0],   \
    (R)[1] = (A)[1] ^ (B)[1],   \
    (R)[2] = (A)[2] ^ (B)[2],   \
    (R)[3] = (A)[3] ^ (B)[3]

#define INCREASE( ctr )    ((ctr)[3] == 0xFFFFFFFF) ? ((ctr)[2]++, (ctr)[3] = 0) : ((ctr)[3]++);
#define ZERO128(a)    a[0] = 0x00000000, a[1] = 0x00000000, a[2] = 0x00000000, a[3] = 0x00000000


void Byte2Word(unsigned int *dst, const unsigned char *src, const int srcLen)
{
    int i = 0;
    int remain = 0;

    for (i = 0; i < srcLen; i++)
    {
        remain = i & 3;

        if (remain == 0)
            dst[i >> 2]  = ((unsigned int)src[i] << 24);
        else if (remain == 1)
            dst[i >> 2] ^= ((unsigned int)src[i] << 16);
        else if (remain == 2)
            dst[i >> 2] ^= ((unsigned int)src[i] << 8);
        else
            dst[i >> 2] ^= ((unsigned int)src[i] & 0x000000FF);
    }
}

void Word2Byte(unsigned char *dst, const unsigned int *src, const int srcLen)
{
    int i = 0;
    int remain = 0;

    for (i = 0; i < srcLen; i++)
    {
        remain = i & 3;

        if (remain == 0)
            dst[i] = (unsigned char)(src[i >> 2] >> 24);
        else if (remain == 1)
            dst[i] = (unsigned char)(src[i >> 2] >> 16);
        else if (remain == 2)
            dst[i] = (unsigned char)(src[i >> 2] >> 8);
        else
            dst[i] = (unsigned char) src[i >> 2];
    }
}


int SEED_CCM_Encryption(
    unsigned char *ct, unsigned int *ctLen,
    unsigned char *pt, unsigned int ptLen,
    unsigned int macLen,
    unsigned char *nonce, unsigned int nonceLen,
    unsigned char *aad, unsigned int aadLen,
    unsigned char *mKey)
{
    unsigned int CTR_in[4] = { 0, }, CTR_out[4] = { 0, };
    unsigned int CBC_in[4] = { 0, }, CBC_out[4] = { 0, };
    unsigned int MAC[4] = { 0, }, tmp[8] = { 0, };
    unsigned int rKey[32] = { 0x00, };
    unsigned int i, flag, tmpLen = 0;

    if (macLen > BLOCK_SIZE_SEED)
    {
        *ctLen = 0;

        return 1;
    }

    SEED_KeySched(mKey, rKey);

    Byte2Word(CTR_in, nonce, nonceLen);
    SHIFTR(CTR_in, 8);

    flag = 14 - nonceLen;

    CTR_in[0] ^= (flag << 24);
    
    SEED_Encrypt(MAC, CTR_in, rKey);

    for (i = 0; i < ptLen; i += BLOCK_SIZE_SEED)
    {
        INCREASE(CTR_in);

        ZERO128(tmp);

        if ((ptLen - i) < BLOCK_SIZE_SEED)
            Byte2Word(tmp, pt + i, ptLen - i);
        else
            Byte2Word(tmp, pt + i, BLOCK_SIZE_SEED);

        SEED_Encrypt(CTR_out, CTR_in, rKey);

        XOR128(tmp, CTR_out, tmp);

        if ((ptLen - i) < BLOCK_SIZE_SEED)
            Word2Byte(ct + i, tmp, ptLen - i);
        else
            Word2Byte(ct + i, tmp, BLOCK_SIZE_SEED);
    }

    Byte2Word(CBC_in, nonce, nonceLen);
    SHIFTR(CBC_in, 8);

    flag = aadLen ? (unsigned int)0x00000040 : (unsigned int)0x00000000;
    flag ^= ((macLen - 2) >> 1) << 3;
    flag ^= 14 - nonceLen;

    CBC_in[0] ^= (flag << 24);
    CBC_in[3] ^= ptLen;

    SEED_Encrypt(CBC_out, CBC_in, rKey);

    if (aadLen > 0)
    {
        if (aadLen > 14)
            tmpLen = 14;
        else
            tmpLen = aadLen;
        
        ZERO128(CBC_in);

        Byte2Word(CBC_in, aad, tmpLen);
        SHIFTR(CBC_in, 16);

        CBC_in[0] ^= (aadLen << 16);

        XOR128(CBC_in, CBC_in, CBC_out);

        SEED_Encrypt(CBC_out, CBC_in, rKey);

        for (i = tmpLen; i < aadLen; i += BLOCK_SIZE_SEED)
        {
            ZERO128(CBC_in);

            if ((aadLen - i) < BLOCK_SIZE_SEED)
                Byte2Word(CBC_in, aad + i, aadLen - i);
            else
                Byte2Word(CBC_in, aad + i, BLOCK_SIZE_SEED);
            
            XOR128(CBC_in, CBC_in, CBC_out);

            SEED_Encrypt(CBC_out, CBC_in, rKey);
        }
    }

    for (i = 0; i < ptLen; i += BLOCK_SIZE_SEED)
    {
        ZERO128(tmp);

        if ((ptLen - i) < BLOCK_SIZE_SEED)
            Byte2Word(tmp, pt + i, ptLen - i);
        else
            Byte2Word(tmp, pt + i, BLOCK_SIZE_SEED);
        
        XOR128(CBC_in, tmp, CBC_out);

        SEED_Encrypt(CBC_out, CBC_in, rKey);
    }

    XOR128(MAC, MAC, CBC_out);

    Word2Byte(ct + ptLen, MAC, macLen);

    *ctLen = ptLen + macLen;

    return 0;
}

int SEED_CCM_Decryption(
    unsigned char *pt, unsigned int *ptLen,
    unsigned char *ct, unsigned int ctLen,
    unsigned int macLen,
    unsigned char *nonce, unsigned int nonceLen,
    unsigned char *aad, unsigned int aadLen,
    unsigned char *mKey)
{
    unsigned int CTR_in[4] = { 0, }, CTR_out[4] = { 0, };
    unsigned int CBC_in[4] = { 0, }, CBC_out[4] = { 0, };
    unsigned int MAC[4] = { 0, }, tmp[8] = { 0, };
    unsigned char tMAC[16] = { 0x00, };
    unsigned int rKey[32] = { 0x00, };
    unsigned int i, j, flag, tmpLen = 0;

    if (macLen > BLOCK_SIZE_SEED)
    {
        *ptLen = 0;

        return 1;
    }

    SEED_KeySched(mKey, rKey);

    Byte2Word(CTR_in, nonce, nonceLen);
    SHIFTR(CTR_in, 8);

    flag = 14 - nonceLen;

    CTR_in[0] ^= (flag << 24);
    
    SEED_Encrypt(MAC, CTR_in, rKey);

    for (i = 0; i < ctLen - macLen; i += BLOCK_SIZE_SEED)
    {
        INCREASE(CTR_in);

        ZERO128(tmp);

        if ((ctLen - macLen - i) < BLOCK_SIZE_SEED)
            Byte2Word(tmp, ct + i, ctLen - macLen - i);
        else
            Byte2Word(tmp, ct + i, BLOCK_SIZE_SEED);

        SEED_Encrypt(CTR_out, CTR_in, rKey);

        XOR128(tmp, CTR_out, tmp);

        if ((ctLen - macLen - i) < BLOCK_SIZE_SEED)
            Word2Byte(pt + i, tmp, ctLen - macLen - i);
        else
            Word2Byte(pt + i, tmp, BLOCK_SIZE_SEED);
    }

    Byte2Word(CBC_in, nonce, nonceLen);
    SHIFTR(CBC_in, 8);

    flag = aadLen ? (unsigned int)0x00000040 : (unsigned int)0x00000000;
    flag ^= ((macLen - 2) >> 1) << 3;
    flag ^= 14 - nonceLen;

    CBC_in[0] ^= (flag << 24);
    CBC_in[3] ^= ctLen - macLen;

    SEED_Encrypt(CBC_out, CBC_in, rKey);

    if (aadLen > 0)
    {
        if (aadLen > 14)
            tmpLen = 14;
        else
            tmpLen = aadLen;
        
        ZERO128(CBC_in);

        Byte2Word(CBC_in, aad, tmpLen);
        SHIFTR(CBC_in, 16);

        CBC_in[0] ^= (aadLen << 16);

        XOR128(CBC_in, CBC_in, CBC_out);

        SEED_Encrypt(CBC_out, CBC_in, rKey);

        for (i = tmpLen; i < aadLen; i += BLOCK_SIZE_SEED)
        {
            ZERO128(CBC_in);

            if ((aadLen - i) < BLOCK_SIZE_SEED)
                Byte2Word(CBC_in, aad + i, aadLen - i);
            else
                Byte2Word(CBC_in, aad + i, BLOCK_SIZE_SEED);
            
            XOR128(CBC_in, CBC_in, CBC_out);

            SEED_Encrypt(CBC_out, CBC_in, rKey);
        }
    }

    for (i = 0; i < ctLen - macLen; i += BLOCK_SIZE_SEED)
    {
        ZERO128(tmp);

        if ((ctLen - macLen - i) < BLOCK_SIZE_SEED)
            Byte2Word(tmp, pt + i, ctLen - macLen - i);
        else
            Byte2Word(tmp, pt + i, BLOCK_SIZE_SEED);
        
        XOR128(CBC_in, tmp, CBC_out);

        SEED_Encrypt(CBC_out, CBC_in, rKey);
    }

    XOR128(MAC, MAC, CBC_out);

    Word2Byte(tMAC, MAC, macLen);

    for (i = 0; i < macLen; i++)
    {
        if (tMAC[i] != ct[ctLen - macLen + i])
        {
            for (j = 0; j < ctLen - macLen; j++)
                pt[j] = 0;
                
            return 1;
        }
    }

    *ptLen = ctLen - macLen;

    return 0;
}
