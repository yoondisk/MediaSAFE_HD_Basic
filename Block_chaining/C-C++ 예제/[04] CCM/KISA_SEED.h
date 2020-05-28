#ifndef _SEED_H_
#define _SEED_H_


// include header


// define
#define BLOCK_SIZE_SEED         16


// function declare
#ifdef __cplusplus
extern "C" 
{
#endif
void SEED_KeySched(unsigned char *mKey, unsigned int *rKey );
void SEED_Encrypt(unsigned int *pOut, unsigned int *pIn, unsigned int *rKey);
void SEED_Decrypt(unsigned int *pOut, unsigned int *pIn, unsigned int *rKey);
#ifdef __cplusplus
}
#endif



#else
#endif
