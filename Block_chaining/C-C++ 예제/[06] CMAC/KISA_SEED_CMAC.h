#ifndef _SEED_CMAC_H_
#define _SEED_CMAC_H_

#ifdef __cplusplus
extern "C"
{
#endif
void SEED_CMAC_SubkeySched(unsigned char *sKey);
int SEED_Generate_CMAC(unsigned char *pMAC, int macLen, unsigned char *pIn, int inLen, unsigned char *mKey);
int SEED_Verify_CMAC(unsigned char *pMAC, int macLen, unsigned char *pIn, int inLen, unsigned char *mKey);
#ifdef __cplusplus
}
#endif

#else
#endif