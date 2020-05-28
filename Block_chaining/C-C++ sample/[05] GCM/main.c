#include <stdio.h>
#include <stdlib.h>
#include "KISA_SEED.h"
#include "KISA_SEED_GCM.h"

int asc2hex(unsigned char *dst, const char *src);
void print_title(const char *title);
void print_hex(const char *valName, const unsigned char *data, const int dataLen);
void print_result(const char *func, int ret);

int main()
{
    unsigned char key[160] = { 0x00, };
    unsigned char in[160] = { 0x00, };
    unsigned char out1[160] = { 0x00, };
    unsigned char out2[160] = { 0x00, };
    unsigned char nonce[160] = { 0x00, };
    unsigned char aad[160] = { 0x00, };

    int keyLen = 0, inLen = 0, out1Len = 0, out2Len = 0, nonceLen = 0, aadLen = 0, macLen = 16;

    print_title("Test SEED GCM - 1");

    keyLen = asc2hex(key, "1032F990B76B0686C0CF9BBB80AEE08C");
    nonceLen = asc2hex(nonce, "75E2534A34F65F85A28E318A");
    aadLen = asc2hex(aad, "9DEA72038744675F026877F23C1F6056F77700BA38ADB2E33F50DB71BCA4C06440459BDEF20CED2A833615FE64C322FD361DE68082FA4B96AA83EB4A1FB6DA24D509C6F2F45043C7D1E060451CF57E185B5162C39626889F5436BA20C739E25B447F1DC5F6D6103ED2AE7F4ECD7B1BAE4D5B9C0ADEF9100527B1737E1CF57F11");
    inLen = asc2hex(in, "6702C72AA04D49BDD4269D672A6C369AD9C72CDCDF8D92CBF6E2045EC4247F6D52867574BFFA2194365519DA1DAD22C48F0647010D2E2D7970E6A18D224273A08E5387D6D503291BC33FA168015C07418CB35983658FCB5C8B4A5E9B26B2B42A05B123D84A2E085C642E5E973E3F8F1AB61689E85177157D2D55640F373BEB13");

	macLen = 12;

    print_result("SEED GCM Encryption", SEED_GCM_Encryption(out1, (unsigned int *)&out1Len, in, inLen, macLen, nonce, nonceLen, aad, aadLen, key));

    print_hex("key", key, keyLen);
    print_hex("in", in, inLen);
    print_hex("nonce", nonce, nonceLen);
    print_hex("aad", aad, aadLen);
    print_hex("out1", out1, out1Len);

    print_result("SEED GCM Decryption", SEED_GCM_Decryption(out2, (unsigned int *)&out2Len, out1, out1Len, macLen, nonce, nonceLen, aad, aadLen, key));

    print_hex("in", out1, out1Len);
    print_hex("out2", out2, out2Len);

	print_title("Test SEED GCM - 2");

	keyLen = asc2hex(key, "11B13AD70556009DA9D0A8A8C11E4199");
	nonceLen = asc2hex(nonce, "FC80175A2ADF87A8A96911CF207CAFB5");
	aadLen = asc2hex(aad, "");
	inLen = asc2hex(in, "");

	macLen = 16;

	print_result("SEED GCM Encryption", SEED_GCM_Encryption(out1, (unsigned int *)&out1Len, in, inLen, macLen, nonce, nonceLen, aad, aadLen, key));

	print_hex("key", key, keyLen);
	print_hex("in", in, inLen);
	print_hex("nonce", nonce, nonceLen);
	print_hex("aad", aad, aadLen);
	print_hex("out1", out1, out1Len);

	print_result("SEED GCM Decryption", SEED_GCM_Decryption(out2, (unsigned int *)&out2Len, out1, out1Len, macLen, nonce, nonceLen, aad, aadLen, key));

	print_hex("in", out1, out1Len);
	print_hex("out2", out2, out2Len);

    return 0;
}


int asc2hex(unsigned char *dst, const char *src)
{
    unsigned char temp = 0x00;
    int i = 0;

    while (src[i] != 0x00)
    {
        temp = 0x00;

        if ((src[i] >= 0x30) && (src[i] <= 0x39))
            temp = src[i] - '0';
        else if ((src[i] >= 0x41) && (src[i] <= 0x5A))
            temp = src[i] - 'A' + 10;
        else if ((src[i] >= 0x61) && (src[i] <= 0x7A))
            temp = src[i] - 'a' + 10;
        else
            temp = 0x00;

        (i & 1) ? (dst[i >> 1] ^= temp & 0x0F) : (dst[i >> 1] = 0, dst[i >> 1] = temp << 4);

        i++;
    }

    return ((i + 1) / 2);
}


void print_title(const char *title)
{
    printf("================================================\n");
    printf("  %s\n", title);
    printf("================================================\n");
}


void print_hex(const char *valName, const unsigned char *data, const int dataLen)
{
    int i = 0;

    printf("%s [%dbyte] :", valName, dataLen);
    for (i = 0; i < dataLen; i++)
    {
        if (!(i & 0x0F))
            printf("\n");
        printf(" %02X", data[i]);
    }
    printf("\n");
}

void print_result(const char *func, int ret)
{
    if (ret)
    {
        printf("================================================\n");
        printf("  %s Failure!\n", func);
		printf("================================================\n");

        exit(0);
    }
    else
    {
        printf("================================================\n");
        printf("  %s Success!\n", func);
        printf("================================================\n");
    }
}
