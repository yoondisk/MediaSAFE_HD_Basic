/**
@file KISA_SEED_CTR.h
@brief SEED CTR 암호 알고리즘
@author Copyright (c) 2013 by KISA
@remarks http://seed.kisa.or.kr/
*/

#ifndef SEED_CTR_H
#define SEED_CTR_H

#ifdef  __cplusplus
extern "C" {
#endif

#ifndef OUT
#define OUT
#endif

#ifndef IN
#define IN
#endif

#ifndef INOUT
#define INOUT
#endif


#ifndef _KISA_ENC_DEC_
#define _KISA_ENC_DEC_
typedef enum _SEED_ENC_DEC
{
	KISA_DECRYPT,
	KISA_ENCRYPT,
}KISA_ENC_DEC;
#endif

#ifndef _KISA_SEED_KEY_
#define _KISA_SEED_KEY_
typedef struct kisa_seed_key_st 
{
	DWORD key_data[32];
} KISA_SEED_KEY;
#endif

#ifndef _KISA_SEED_INFO_
#define _KISA_SEED_INFO_
typedef struct kisa_seed_info_st 
{	
	KISA_ENC_DEC	encrypt;				
	DWORD			ctr[4];				
	KISA_SEED_KEY	seed_key;				
	DWORD			cbc_buffer[4];			
	int				buffer_length;			
	DWORD			cbc_last_block[4];		
	int				last_block_flag;		
} KISA_SEED_INFO;
#endif

#ifndef _NONCE_TYPE_
#define _NONCE_TYPE_
typedef enum _NONCE_TYPE
{
	NONCE_NONE,
	NONCE_OR,
	NONCE_AND,
	NONCE_XOR,
}NONCE_TYPE;
#endif

#ifdef  __cplusplus
}
#endif

#endif