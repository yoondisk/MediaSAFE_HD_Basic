<%@ include file="KISA_SEED.jsp" %>
<%!

private static void SHIFTR8(int[] x)
{
    x[3] = ((x[3] >> 8) & 0x00FFFFFF) ^ ((x[2] << 24) & 0xFF000000);
    x[2] = ((x[2] >> 8) & 0x00FFFFFF) ^ ((x[1] << 24) & 0xFF000000);
    x[1] = ((x[1] >> 8) & 0x00FFFFFF) ^ ((x[0] << 24) & 0xFF000000);
    x[0] = ((x[0] >> 8) & 0x00FFFFFF);
}

private static void SHIFTR16(int[] x)
{
    x[3] = ((x[3] >> 16) & 0x0000FFFF) ^ ((x[2] << 16) & 0xFFFF0000);
    x[2] = ((x[2] >> 16) & 0x0000FFFF) ^ ((x[1] << 16) & 0xFFFF0000);
    x[1] = ((x[1] >> 16) & 0x0000FFFF) ^ ((x[0] << 16) & 0xFFFF0000);
    x[0] = ((x[0] >> 16) & 0x0000FFFF);
}

private static void XOR128(int[] R, int[] A, int[] B)
{
    R[0] = A[0] ^ B[0];
    R[1] = A[1] ^ B[1];
    R[2] = A[2] ^ B[2];
    R[3] = A[3] ^ B[3];
}

private static void INCREASE(int[] ctr)
{
    if (ctr[3] == 0xFFFFFFFF)
    {
        ctr[2]++;
        ctr[3] = 0;
    }
    else
    {
        ctr[3]++;
    }
}
private static void ZERO128(int[] a) { a[0] = 0x00000000; a[1] = 0x00000000; a[2] = 0x00000000; a[3] = 0x00000000; }

private static void Byte2Word(int[] dst, byte[] src, int src_offset, int srcLen)
{
    int i = 0;
    int remain = 0;

    for (i = 0; i < srcLen; i++)
    {
        remain = i & 3;

        if (remain == 0)
            dst[i >> 2]  = ((src[src_offset + i] & 0x0FF) << 24);
        else if (remain == 1)
            dst[i >> 2] ^= ((src[src_offset + i] & 0x0FF) << 16);
        else if (remain == 2)
            dst[i >> 2] ^= ((src[src_offset + i] & 0x0FF) <<  8);
        else
            dst[i >> 2] ^= ( src[src_offset + i] & 0x0FF);
    }
}

private static void Word2Byte(byte[] dst, int dst_offset, int[] src, int srcLen)
{
    int i = 0;
    int remain = 0;

    for (i = 0; i < srcLen; i++)
    {
        remain = i & 3;

        if (remain == 0)
            dst[dst_offset + i] = (byte)(src[i >> 2] >> 24);
        else if (remain == 1)
            dst[dst_offset + i] = (byte)(src[i >> 2] >> 16);
        else if (remain == 2)
            dst[dst_offset + i] = (byte)(src[i >> 2] >> 8);
        else
            dst[dst_offset + i] = (byte) src[i >> 2];
    }
}

public static int SEED_CCM_Encryption(
    byte[] ct,
    byte[] pt, int ptLen,
    int macLen,
    byte[] nonce, int nonceLen,
    byte[] aad, int aadLen,
    byte[] mKey)
{
    int[] CTR_in = new int[4];
    int[] CTR_out = new int[4];
    int[] CBC_in = new int[4];
    int[] CBC_out = new int[4];
    int[] MAC = new int[4];
    int[] tmp = new int[8];
    int[] rKey = new int[32];
    int i, flag, tmpLen = 0;

    if (macLen > 16)
        return 1;

    SEED_KeySched(mKey, rKey);

    Byte2Word(CTR_in, nonce, 0, nonceLen);
    SHIFTR8(CTR_in);

    flag = 14 - nonceLen;

    CTR_in[0] ^= (flag << 24);
    
    SEED_Encrypt(MAC, CTR_in, rKey);

    for (i = 0; i < ptLen; i += 16)
    {
        INCREASE(CTR_in);

        ZERO128(tmp);

        if ((ptLen - i) < 16)
            Byte2Word(tmp, pt, i, ptLen - i);
        else
            Byte2Word(tmp, pt, i, 16);

        SEED_Encrypt(CTR_out, CTR_in, rKey);

        XOR128(tmp, CTR_out, tmp);

        if ((ptLen - i) < 16)
            Word2Byte(ct, i, tmp, ptLen - i);
        else
            Word2Byte(ct, i, tmp, 16);
    }

    Byte2Word(CBC_in, nonce, 0, nonceLen);
    SHIFTR8(CBC_in);

    if (aadLen > 0)
        flag = 0x00000040;
    else
        flag = 0x00000000;
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

        Byte2Word(CBC_in, aad, 0, tmpLen);
        SHIFTR16(CBC_in);

        CBC_in[0] ^= ((aadLen << 16) & 0xFFFF0000);

        XOR128(CBC_in, CBC_in, CBC_out);

        SEED_Encrypt(CBC_out, CBC_in, rKey);

        for (i = tmpLen; i < aadLen; i += 16)
        {
            ZERO128(CBC_in);

            if ((aadLen - i) < 16)
                Byte2Word(CBC_in, aad, i, aadLen - i);
            else
                Byte2Word(CBC_in, aad, i, 16);
            
            XOR128(CBC_in, CBC_in, CBC_out);

            SEED_Encrypt(CBC_out, CBC_in, rKey);
        }
    }

    for (i = 0; i < ptLen; i += 16)
    {
        ZERO128(tmp);

        if ((ptLen - i) < 16)
            Byte2Word(tmp, pt, i, ptLen - i);
        else
            Byte2Word(tmp, pt, i, 16);
        
        XOR128(CBC_in, tmp, CBC_out);

        SEED_Encrypt(CBC_out, CBC_in, rKey);
    }

    XOR128(MAC, MAC, CBC_out);

    Word2Byte(ct, ptLen, MAC, macLen);

    return 0;
}

public static int SEED_CCM_Decryption(
    byte[] pt,
    byte[] ct, int ctLen,
    int macLen,
    byte[] nonce, int nonceLen,
    byte[] aad, int aadLen,
    byte[] mKey)
{
    int[] CTR_in = new int[4];
    int[] CTR_out = new int[4];
    int[] CBC_in = new int[4];
    int[] CBC_out = new int[4];
    int[] MAC = new int[4];
    byte[] tMAC = new byte[16];
    int[] tmp = new int[8];
    int[] rKey = new int[32];
    int i, j, flag, tmpLen = 0;

    if (macLen > 16)
        return 1;

    SEED_KeySched(mKey, rKey);

    Byte2Word(CTR_in, nonce, 0, nonceLen);
    SHIFTR8(CTR_in);

    flag = 14 - nonceLen;

    CTR_in[0] ^= (flag << 24);
    
    SEED_Encrypt(MAC, CTR_in, rKey);

    for (i = 0; i < ctLen - macLen; i += 16)
    {
        INCREASE(CTR_in);

        ZERO128(tmp);

        if ((ctLen - macLen - i) < 16)
            Byte2Word(tmp, ct, i, ctLen - macLen - i);
        else
            Byte2Word(tmp, ct, i, 16);

            SEED_Encrypt(CTR_out, CTR_in, rKey);

        XOR128(tmp, CTR_out, tmp);

        if ((ctLen - macLen - i) < 16)
            Word2Byte(pt, i, tmp, ctLen - macLen - i);
        else
            Word2Byte(pt, i, tmp, 16);
    }

    Byte2Word(CBC_in, nonce, 0, nonceLen);
    SHIFTR8(CBC_in);

    if (aadLen > 0)
        flag = 0x00000040;
    else
        flag = 0x00000000;
    
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

        Byte2Word(CBC_in, aad, 0, tmpLen);
        SHIFTR16(CBC_in);

        CBC_in[0] ^= (aadLen << 16);

        XOR128(CBC_in, CBC_in, CBC_out);

        SEED_Encrypt(CBC_out, CBC_in, rKey);

        for (i = tmpLen; i < aadLen; i += 16)
        {
            ZERO128(CBC_in);

            if ((aadLen - i) < 16)
                Byte2Word(CBC_in, aad, i, aadLen - i);
            else
                Byte2Word(CBC_in, aad, i, 16);

            XOR128(CBC_in, CBC_in, CBC_out);

            SEED_Encrypt(CBC_out, CBC_in, rKey);
        }
    }

    for (i = 0; i < ctLen - macLen; i += 16)
    {
        ZERO128(tmp);

        if ((ctLen - macLen - i) < 16)
            Byte2Word(tmp, pt, i, ctLen - macLen - i);
        else
            Byte2Word(tmp, pt, i, 16);

        XOR128(CBC_in, tmp, CBC_out);

        SEED_Encrypt(CBC_out, CBC_in, rKey);
    }

    XOR128(MAC, MAC, CBC_out);

    Word2Byte(tMAC, 0, MAC, macLen);

    for (i = 0; i < macLen; i++)
    {
        if (tMAC[i] != ct[ctLen - macLen + i])
        {
            for (j = 0; j < ctLen - macLen; j++)
                pt[j] = 0;
            
            return 1;
        }
    }

    return 0;
}

%>