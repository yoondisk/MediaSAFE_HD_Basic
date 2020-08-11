#ifndef _SEED_GCM_H_
#define _SEED_GCM_H_


// include header


// define


// function declare
#ifdef __cplusplus
extern "C" 
{
#endif
int SEED_GCM_Encryption(
    unsigned char *ct, unsigned int *ctLen,
    unsigned char *pt, unsigned int ptLen,
    unsigned int macLen,
    unsigned char *nonce, unsigned int noncelen,
    unsigned char *aad, unsigned int aadlen,
    unsigned char *mKey);
int SEED_GCM_Decryption(
    unsigned char *pt, unsigned int *ptLen,
    unsigned char *ct, unsigned int ctLen,
    unsigned int macLen,
    unsigned char *nonce, unsigned int nonceLen,
    unsigned char *aad, unsigned int aadLen,
    unsigned char *mKey);
#ifdef __cplusplus
}
#endif



#else
#endif
