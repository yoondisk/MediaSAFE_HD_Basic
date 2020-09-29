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

#if __alpha__	||	__alpha	||	__i386__	||	i386	||	_M_I86	||	_M_IX86	||	\
	__OS2__		||	sun386	||	__TURBOC__	||	vax		||	vms		||	VMS		||	__VMS || __linux__
//#define LITTLE_ENDIAN
#else
#define BIG_ENDIAN
#endif

typedef unsigned int        DWORD;
typedef unsigned short      WORD;
typedef unsigned char       BYTE;

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

/**
@brief SEED_CTR_init에 사용하는 초기값(BYTE *pbszCounter)을 설정한다.
@param type : OR, AND, XOR 연산할 타입 지정
@param pbszIV : IV(초기 벡터) 배열 포인터
@param pbszCounter : 카운터 초기 값
@param pbszNonce : IV 와 Counter를 type에 따라 비트 연산된 결과 값
*/
void InitNonce_SEED( IN NONCE_TYPE type, IN BYTE *pbszIV, IN BYTE *pbszCounter, OUT BYTE *pbszNonce );

/**
@brief BYTE 배열을 int 배열로 변환한다.
@param in :변환할 BYTE 포인터
@param inLen : 변환할 BYTE 배열 갯수
@return 인자로 받은 BYTE 배열의 int로 변환된 포인터를 반환한다. (내부적으로 malloc함으로 free를 꼭 해줘야 한다)
@remarks 전반적으로 동일한 기능의 함수가 SEED CTR, CBC, HIGHT CTR, CBC에 있으나 include 시 
동일 함수일 경우 충돌 때문에 뒤에 구분할 수 있도록 운영모드를 붙인다.
*/
DWORD* chartoint32_for_SEED_CTR( IN BYTE *in, IN int inLen );

/**
@brief int 배열을 BYTE 배열로 변환한다.
@param in :변환할 int 포인터
@param inLen : 변환할 int 배열 갯수
@return 인자로 받은 int 배열을 char로 변환한 포인터를 반환한다. (내부적으로 malloc함으로 free를 꼭 해줘야 한다)
@remarks 전반적으로 동일한 기능의 함수가 SEED CTR, CBC, HIGHT CTR, CBC에 있으나 include 시 
동일 함수일 경우 충돌 때문에 뒤에 구분할 수 있도록 운영모드를 붙인다.
*/
BYTE* int32tochar_for_SEED_CTR( IN DWORD *in, IN int inLen );

/**
@brief SEED CTR 알고리즘 초기화 함수
@param pInfo : CBC 내부에서 사용되는 구조체로써 유저가 변경하면 안된다.(메모리 할당되어 있어야 한다.)
@param enc : 암호화 및 복호화 모드 지정
@param pbszUserKey : 사용자가 지정하는 입력 키(16 BYTE)
@param pbszIV : 사용자가 지정하는 초기화 벡터(16 BYTE)
*/
int SEED_CTR_init( OUT KISA_SEED_INFO *pInfo, IN KISA_ENC_DEC enc, IN BYTE *pszUserKey, IN BYTE *pbszCounter );

/**
@brief SEED CTR 다중 블럭 암호화/복호화 함수
@param pInfo : SEED_CTR_init 에서 설정된 KISA_HIGHT_INFO 구조체
@param in : 평문/암호문 ( 평문은 chartoint32_for_SEED_CTR를 사용하여 int로 변환된 데이터)
@param inLen : 평문/암호문 길이(BYTE 단위)
@param out : 평문/암호문 버퍼
@param outLen : 진행된 평문/암호문의 길이(BYTE 단위로 넘겨준다)
@return 0: inLen의 값이 0보다 작은 경우, KISA_SEED_INFO 구조체나 in, out에 널 포인터가 할당되었을 경우
        1: 성공
*/
int SEED_CTR_Process( OUT KISA_SEED_INFO *pInfo, IN DWORD *in, IN int inLen, OUT DWORD *out, OUT int *outLen );

/**
@brief 처리하고자 하는 데이터가 적을 경우에 사용
@param pbszUserKey : 사용자가 지정하는 입력 키(16 BYTE)
@param pszbIV : 사용자가 지정하는 초기화 벡터(16 BYTE)
@param pbszPlainText : 사용자 입력 평문
@param nPlainTextLen : 평문 길이(BYTE 단위의 평문길이)
@param pbszCipherText : 암호문 출력 버퍼
@return 암호화가 진행길 길이(char 단위)
@remarks 패딩 로직때문에 16바이트 블럭으로 처리함으로 pbszCipherText는 평문보다 16바이트 커야 한다.
(평문이 16바이트 블럭 시 패딩 데이타가 16바이트가 들어간다.)
*/
int SEED_CTR_Encrypt( IN BYTE *pbszUserKey, IN BYTE *pbszIV, IN BYTE *pbszPlainText, IN int nPlainTextLen, OUT BYTE *pbszCipherText );

/**
@brief 처리하고자 하는 데이터가 적을 경우에 사용
@param pbszUserKey : 사용자가 지정하는 입력 키(16 BYTE)
@param pszbIV : 사용자가 지정하는 초기화 벡터(16 BYTE)
@param pbszCipherText : 암호문
@param nCipherTextLen : 암호문 길이(BYTE 단위의 평문길이)
@param pbszPlainText : 평문 출력 버퍼
@return 복호화가 진행길 길이(char 단위)
*/
int SEED_CTR_Decrypt( IN BYTE *pbszUserKey, IN BYTE *pbszIV, IN BYTE *pbszCipherText, IN int nCipherTextLen, OUT BYTE *pbszPlainText );

void seed_test_ctr();


#ifdef  __cplusplus
}
#endif

#endif
