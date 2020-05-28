#include <stdio.h>
#include <stdlib.h>
#include "KISA_SEED.h"
#include "KISA_SEED_CCM.h"

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

	print_title("Test SEED CCM - 1");

	keyLen = asc2hex(key, "FAB5E5DE4350E5A4E0F1DF63E46A2AA0");
	nonceLen = asc2hex(nonce, "0C911408A595DF62A99209C2");
	aadLen = asc2hex(aad, "2C62D1FFF6B7F6687266C2B3C706473644BAE95A014B1C4CC37A6FF52194CA2D");
	inLen = asc2hex(in, "E546F32BB5B35740F3C408C6E1BF0253091CB232DC94B913997AED01704EA095E89026697E");

	macLen = 16;

	print_result("SEED CCM_Encryption", SEED_CCM_Encryption(out1, (unsigned int *)&out1Len, in, inLen, macLen, nonce, nonceLen, aad, aadLen, key));

	print_hex("key", key, keyLen);
	print_hex("in", in, inLen);
	print_hex("nonce", nonce, nonceLen);
	print_hex("aad", aad, aadLen);
	print_hex("out1", out1, out1Len);
	printf("\n");

	print_result("SEED CCM_Decryption", SEED_CCM_Decryption(out2, (unsigned int *)&out2Len, out1, out1Len, macLen, nonce, nonceLen, aad, aadLen, key));

	print_hex("in", out1, out1Len);
	print_hex("out2", out2, out2Len);

	print_title("Test SEED CCM - 2");

	keyLen = asc2hex(key, "002B30E20CCC65E95DAE1FDF2411C0D5");
	nonceLen = asc2hex(nonce, "188CC310D2A428");
	aadLen = asc2hex(aad, "5CE917AF1AF4732CC220FC022979650E");
	inLen = asc2hex(in, "559869FF1ADDCC7261CDC9CB40D67626");

	macLen = 4;

	print_result("SEED CCM_Encryption", SEED_CCM_Encryption(out1, (unsigned int *)&out1Len, in, inLen, macLen, nonce, nonceLen, aad, aadLen, key));

	print_hex("key", key, keyLen);
	print_hex("in", in, inLen);
	print_hex("nonce", nonce, nonceLen);
	print_hex("aad", aad, aadLen);
	print_hex("out1", out1, out1Len);
	printf("\n");

	print_result("SEED CCM_Decryption", SEED_CCM_Decryption(out2, (unsigned int *)&out2Len, out1, out1Len, macLen, nonce, nonceLen, aad, aadLen, key));

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
