#include "KISA_SEED.h"
#include "KISA_SEED_GCM.h"


#define SHIFTR( R, n )                              \
    (R)[3] = ((R)[3] >> n) ^ ((R)[2] << (32 - n)),  \
    (R)[2] = ((R)[2] >> n) ^ ((R)[1] << (32 - n)),  \
    (R)[1] = ((R)[1] >> n) ^ ((R)[0] << (32 - n)),  \
    (R)[0] = ((R)[0] >> n)

#define XOR128( R, A, B )       \
    (R)[0] = (A)[0] ^ (B)[0],   \
    (R)[1] = (A)[1] ^ (B)[1],   \
    (R)[2] = (A)[2] ^ (B)[2],   \
    (R)[3] = (A)[3] ^ (B)[3]

#define INCREASE( ctr )	((ctr)[3] == 0xFFFFFFFF) ? ((ctr)[2]++, (ctr)[3] = 0) : ((ctr)[3]++);
#define ZERO128(a)    a[0] = 0x00000000, a[1] = 0x00000000, a[2] = 0x00000000, a[3] = 0x00000000;


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


static const unsigned int R8[256] =
{
    0x00000000, 0x01c20000, 0x03840000, 0x02460000, 0x07080000, 0x06ca0000, 0x048c0000, 0x054e0000,
    0x0e100000, 0x0fd20000, 0x0d940000, 0x0c560000, 0x09180000, 0x08da0000, 0x0a9c0000, 0x0b5e0000,
    0x1c200000, 0x1de20000, 0x1fa40000, 0x1e660000, 0x1b280000, 0x1aea0000, 0x18ac0000, 0x196e0000,
    0x12300000, 0x13f20000, 0x11b40000, 0x10760000, 0x15380000, 0x14fa0000, 0x16bc0000, 0x177e0000,
    0x38400000, 0x39820000, 0x3bc40000, 0x3a060000, 0x3f480000, 0x3e8a0000, 0x3ccc0000, 0x3d0e0000,
    0x36500000, 0x37920000, 0x35d40000, 0x34160000, 0x31580000, 0x309a0000, 0x32dc0000, 0x331e0000,
    0x24600000, 0x25a20000, 0x27e40000, 0x26260000, 0x23680000, 0x22aa0000, 0x20ec0000, 0x212e0000,
    0x2a700000, 0x2bb20000, 0x29f40000, 0x28360000, 0x2d780000, 0x2cba0000, 0x2efc0000, 0x2f3e0000,
    0x70800000, 0x71420000, 0x73040000, 0x72c60000, 0x77880000, 0x764a0000, 0x740c0000, 0x75ce0000,
    0x7e900000, 0x7f520000, 0x7d140000, 0x7cd60000, 0x79980000, 0x785a0000, 0x7a1c0000, 0x7bde0000,
    0x6ca00000, 0x6d620000, 0x6f240000, 0x6ee60000, 0x6ba80000, 0x6a6a0000, 0x682c0000, 0x69ee0000,
    0x62b00000, 0x63720000, 0x61340000, 0x60f60000, 0x65b80000, 0x647a0000, 0x663c0000, 0x67fe0000,
    0x48c00000, 0x49020000, 0x4b440000, 0x4a860000, 0x4fc80000, 0x4e0a0000, 0x4c4c0000, 0x4d8e0000,
    0x46d00000, 0x47120000, 0x45540000, 0x44960000, 0x41d80000, 0x401a0000, 0x425c0000, 0x439e0000,
    0x54e00000, 0x55220000, 0x57640000, 0x56a60000, 0x53e80000, 0x522a0000, 0x506c0000, 0x51ae0000,
    0x5af00000, 0x5b320000, 0x59740000, 0x58b60000, 0x5df80000, 0x5c3a0000, 0x5e7c0000, 0x5fbe0000,
    0xe1000000, 0xe0c20000, 0xe2840000, 0xe3460000, 0xe6080000, 0xe7ca0000, 0xe58c0000, 0xe44e0000,
    0xef100000, 0xeed20000, 0xec940000, 0xed560000, 0xe8180000, 0xe9da0000, 0xeb9c0000, 0xea5e0000,
    0xfd200000, 0xfce20000, 0xfea40000, 0xff660000, 0xfa280000, 0xfbea0000, 0xf9ac0000, 0xf86e0000,
    0xf3300000, 0xf2f20000, 0xf0b40000, 0xf1760000, 0xf4380000, 0xf5fa0000, 0xf7bc0000, 0xf67e0000,
    0xd9400000, 0xd8820000, 0xdac40000, 0xdb060000, 0xde480000, 0xdf8a0000, 0xddcc0000, 0xdc0e0000,
    0xd7500000, 0xd6920000, 0xd4d40000, 0xd5160000, 0xd0580000, 0xd19a0000, 0xd3dc0000, 0xd21e0000,
    0xc5600000, 0xc4a20000, 0xc6e40000, 0xc7260000, 0xc2680000, 0xc3aa0000, 0xc1ec0000, 0xc02e0000,
    0xcb700000, 0xcab20000, 0xc8f40000, 0xc9360000, 0xcc780000, 0xcdba0000, 0xcffc0000, 0xce3e0000,
    0x91800000, 0x90420000, 0x92040000, 0x93c60000, 0x96880000, 0x974a0000, 0x950c0000, 0x94ce0000,
    0x9f900000, 0x9e520000, 0x9c140000, 0x9dd60000, 0x98980000, 0x995a0000, 0x9b1c0000, 0x9ade0000,
    0x8da00000, 0x8c620000, 0x8e240000, 0x8fe60000, 0x8aa80000, 0x8b6a0000, 0x892c0000, 0x88ee0000,
    0x83b00000, 0x82720000, 0x80340000, 0x81f60000, 0x84b80000, 0x857a0000, 0x873c0000, 0x86fe0000,
    0xa9c00000, 0xa8020000, 0xaa440000, 0xab860000, 0xaec80000, 0xaf0a0000, 0xad4c0000, 0xac8e0000,
    0xa7d00000, 0xa6120000, 0xa4540000, 0xa5960000, 0xa0d80000, 0xa11a0000, 0xa35c0000, 0xa29e0000,
    0xb5e00000, 0xb4220000, 0xb6640000, 0xb7a60000, 0xb2e80000, 0xb32a0000, 0xb16c0000, 0xb0ae0000,
    0xbbf00000, 0xba320000, 0xb8740000, 0xb9b60000, 0xbcf80000, 0xbd3a0000, 0xbf7c0000, 0xbebe0000
};


void makeM8(unsigned int M[][4], const unsigned int *H)
{
    unsigned int i = 64, j = 0, temp[4] = { 0,  };

    M[128][0] = H[0];
    M[128][1] = H[1];
    M[128][2] = H[2];
    M[128][3] = H[3];

    while( i > 0 )
    {
        temp[0] = M[i << 1][0];
        temp[1] = M[i << 1][1];
        temp[2] = M[i << 1][2];
        temp[3] = M[i << 1][3];

        if( temp[3] & 0x01 )
        {
            SHIFTR( temp, 1 );
            temp[0] ^= 0xE1000000;
        }
        else
        {
            SHIFTR( temp, 1 );
        }

        M[i][0] = temp[0];
        M[i][1] = temp[1];
        M[i][2] = temp[2];
        M[i][3] = temp[3];

        i >>= 1;
    }

    i = 2;

    while( i < 256 )
    {
        for( j = 1; j < i; j++ )
        {
            M[i + j][0] = M[i][0] ^ M[j][0];
            M[i + j][1] = M[i][1] ^ M[j][1];
            M[i + j][2] = M[i][2] ^ M[j][2];
            M[i + j][3] = M[i][3] ^ M[j][3];
        }

        i <<= 1;
    }

    M[0][0] = 0;
    M[0][1] = 0;
    M[0][2] = 0;
    M[0][3] = 0;
}

void GHASH_8BIT(unsigned int *out, unsigned int *in, unsigned int M[][4], const unsigned int *R)
{
    unsigned int W[4] = { 0, }, Z[4] = {0, };
    unsigned int temp = 0, i = 0;

    XOR128( Z, out, in );

    for( i = 0; i < 15; i++ )
    {
        temp = ((Z[3 - (i >> 2)] >> ((i & 3) << 3)) & 0xFF);

        W[0] ^= M[temp][0];
        W[1] ^= M[temp][1];
        W[2] ^= M[temp][2];
        W[3] ^= M[temp][3];

        temp = W[3] & 0xFF;
        
        SHIFTR( W, 8 );
        W[0] ^= R[temp];
    }

    temp = (Z[0] >> 24) & 0xFF;

    out[0] = W[0] ^ M[temp][0];
    out[1] = W[1] ^ M[temp][1];
    out[2] = W[2] ^ M[temp][2];
    out[3] = W[3] ^ M[temp][3];
}


int SEED_GCM_Encryption(
    unsigned char *ct, unsigned int *ctLen,
    unsigned char *pt, unsigned int ptLen,
    unsigned int macLen,
    unsigned char *nonce, unsigned int nonceLen,
    unsigned char *aad, unsigned int aadLen,
    unsigned char *mKey)
{
    unsigned int rKey[32] = { 0x00, };
    unsigned int H[4] = { 0x00, }, Z[4] = { 0x00, }, tmp[8] = { 0x00, };
    unsigned int GCTR_in[4] = { 0x00, }, GCTR_out[4] = { 0x00, };
    unsigned int GHASH_in[4] = { 0x00, }, GHASH_out[4] = { 0x00, };
    unsigned int M8[256][4] = { 0x00, }, i = 0;

    if (macLen > 16)
    {
        *ctLen = 0;

        return 1;
    }

    SEED_KeySched(mKey, rKey);

    SEED_Encrypt(H, H, rKey);

    makeM8(M8, H);

    if (nonceLen == 12)
    {
        Byte2Word(GCTR_in, nonce, nonceLen);

        GCTR_in[3] = 1;
        
        SEED_Encrypt(Z, GCTR_in, rKey);
    }
    else
    {
        for (i = 0; i < nonceLen; i += BLOCK_SIZE_SEED)
        {
            ZERO128(tmp);

            if ((nonceLen - i) < 16)
                Byte2Word(tmp, nonce + i, nonceLen - i);
            else
                Byte2Word(tmp, nonce + i, BLOCK_SIZE_SEED);
            
            GHASH_8BIT(GCTR_in, tmp, M8, R8);
        }

        ZERO128(tmp);
        tmp[3] = (nonceLen << 3);

        GHASH_8BIT(GCTR_in, tmp, M8, R8);

        SEED_Encrypt(Z, GCTR_in, rKey);
    }

    for (i = 0; i < ptLen; i += BLOCK_SIZE_SEED)
    {
        ZERO128(tmp);

        INCREASE(GCTR_in);

        SEED_Encrypt(GCTR_out, GCTR_in, rKey);

        if ((ptLen - i) < 16)
        {
            Byte2Word(tmp, pt + i, ptLen - i);
            XOR128(GCTR_out, GCTR_out, tmp);
            Word2Byte(ct + i, GCTR_out, ptLen - i);
        }
        else
        {
            Byte2Word(tmp, pt + i, BLOCK_SIZE_SEED);
            XOR128(GCTR_out, GCTR_out, tmp);
            Word2Byte(ct + i, GCTR_out, BLOCK_SIZE_SEED);
        }
    }

    for (i = 0; i < aadLen; i += BLOCK_SIZE_SEED)
    {
        ZERO128(GHASH_in);

        if ((aadLen - i) < 16)
            Byte2Word(GHASH_in, aad + i, aadLen - i);
        else
            Byte2Word(GHASH_in, aad + i, BLOCK_SIZE_SEED);

        GHASH_8BIT(GHASH_out, GHASH_in, M8, R8);
    }

    for (i = 0; i < ptLen; i += BLOCK_SIZE_SEED)
    {
        ZERO128(GHASH_in);

        if ((ptLen - i) < 16)
            Byte2Word(GHASH_in, ct + i, ptLen - i);
        else
            Byte2Word(GHASH_in, ct + i, BLOCK_SIZE_SEED);

        GHASH_8BIT(GHASH_out, GHASH_in, M8, R8);
    }

    ZERO128(GHASH_in);

    GHASH_in[1] ^= aadLen << 3;
    GHASH_in[3] ^= ptLen << 3;

    GHASH_8BIT(GHASH_out, GHASH_in, M8, R8);

    XOR128(GHASH_out, GHASH_out, Z);

    Word2Byte(ct + ptLen, GHASH_out, macLen);

    *ctLen = ptLen + macLen;

    return 0;
}


int SEED_GCM_Decryption(
    unsigned char *pt, unsigned int *ptLen,
    unsigned char *ct, unsigned int ctLen,
    unsigned int macLen,
    unsigned char *nonce, unsigned int nonceLen,
    unsigned char *aad, unsigned int aadLen,
    unsigned char *mKey)
{
    unsigned int rKey[32] = { 0x00, };
    unsigned int H[4] = { 0x00, }, Z[4] = { 0x00, }, tmp[8] = { 0x00, };
    unsigned char MAC[16] = { 0x00, };
    unsigned int GCTR_in[4] = { 0x00, }, GCTR_out[4] = { 0x00, };
    unsigned int GHASH_in[4] = { 0x00, }, GHASH_out[4] = { 0x00, };
    unsigned int M8[256][4] = { 0x00, }, i, j;

    if (macLen > 16)
    {
        *ptLen = 0;

        return 1;
    }

    SEED_KeySched(mKey, rKey);

    SEED_Encrypt(H, H, rKey);

    makeM8(M8, H);

    if (nonceLen == 12)
    {
        Byte2Word(GCTR_in, nonce, nonceLen);

        GCTR_in[3] = 1;
        
        SEED_Encrypt(Z, GCTR_in, rKey);
    }
    else
    {
        for (i = 0; i < nonceLen; i += BLOCK_SIZE_SEED)
        {
            ZERO128(tmp);

            if ((nonceLen - i) < 16)
                Byte2Word(tmp, nonce + i, nonceLen - i);
            else
                Byte2Word(tmp, nonce + i, BLOCK_SIZE_SEED);
            
            GHASH_8BIT(GCTR_in, tmp, M8, R8);
        }

        ZERO128(tmp);
        tmp[3] = (nonceLen << 3);

        GHASH_8BIT(GCTR_in, tmp, M8, R8);
        
        SEED_Encrypt(Z, GCTR_in, rKey);
    }

    for (i = 0; i < ctLen - macLen; i += BLOCK_SIZE_SEED)
    {
        ZERO128(tmp);

        INCREASE(GCTR_in);

        SEED_Encrypt(GCTR_out, GCTR_in, rKey);

        if ((ctLen - macLen - i) < 16)
        {
            Byte2Word(tmp, ct + i, ctLen - macLen - i);
            XOR128(GCTR_out, GCTR_out, tmp);
            Word2Byte(pt + i, GCTR_out, ctLen - macLen - i);
        }
        else
        {
            Byte2Word(tmp, ct + i, BLOCK_SIZE_SEED);
            XOR128(GCTR_out, GCTR_out, tmp);
            Word2Byte(pt + i, GCTR_out, BLOCK_SIZE_SEED);
        }
    }

    for (i = 0; i < aadLen; i += BLOCK_SIZE_SEED)
    {
        ZERO128(GHASH_in);

        if ((aadLen - i) < 16)
            Byte2Word(GHASH_in, aad + i, aadLen - i);
        else
            Byte2Word(GHASH_in, aad + i, BLOCK_SIZE_SEED);

        GHASH_8BIT(GHASH_out, GHASH_in, M8, R8);
    }

    for (i = 0; i < ctLen - macLen; i += BLOCK_SIZE_SEED)
    {
        ZERO128(GHASH_in);

        if ((ctLen - macLen - i) < 16)
            Byte2Word(GHASH_in, ct + i, ctLen - macLen - i);
        else
            Byte2Word(GHASH_in, ct + i, BLOCK_SIZE_SEED);

        GHASH_8BIT(GHASH_out, GHASH_in, M8, R8);
    }

    ZERO128(GHASH_in);

    GHASH_in[1] = aadLen <<3;
    GHASH_in[3] = (ctLen - macLen) << 3;

    GHASH_8BIT(GHASH_out, GHASH_in, M8, R8);

    XOR128(GHASH_out, GHASH_out, Z);

    Word2Byte(MAC, GHASH_out, macLen);

    for (i = 0; i < macLen; i++)
    {
        if (MAC[i] != ct[ctLen - macLen + i])
        {
            for (j = 0; j < ctLen - macLen; j++)
                pt[j] = 0;
                
            return 1;
        }
    }

    *ptLen = ctLen - macLen;

    return 0;
}
