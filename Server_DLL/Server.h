#if !defined(AFX_SERVER_H__6C217A2F_1C77_11D4_95D1_00201858667A__INCLUDED_)
#define AFX_SERVER_H__6C217A2F_1C77_11D4_95D1_00201858667A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <httpext.h>
#include <vector>
#include <map>
#include <string>


	 
#define DATABUFFER 4096

typedef unsigned char uint8_t;
typedef unsigned int uint32_t;
typedef unsigned __int64 uint64_t;
typedef int int32_t;
typedef __int64 int64_t;
typedef unsigned __int16 uint16_t; 

//-----------------------------------------------------------------------------
// CMp4Server - 
//
// This is the main application object. It's designed to be a singleton but this
// is not enforced.
//
// ServiceRequest() is the entry point for the entire application.
//-----------------------------------------------------------------------------

class CMp4Server{

public:
	CMp4Server();
	~CMp4Server();
	
    void S404(EXTENSION_CONTROL_BLOCK* pECB);
    
	DWORD HttpExtensionProc(EXTENSION_CONTROL_BLOCK* pECB);

	CString httpstring(EXTENSION_CONTROL_BLOCK* pECB,char* mode);

	CString httpurl(EXTENSION_CONTROL_BLOCK* pECB,int gubun);

	DWORD ServiceRequest(EXTENSION_CONTROL_BLOCK* pECB);
	
	DWORD drm_(EXTENSION_CONTROL_BLOCK* pECB,DWORD start_h,DWORD end_h,int mode);

	DWORD mp4_start(EXTENSION_CONTROL_BLOCK* pECB,double start, double end);

private:


	inline bool WriteContext( EXTENSION_CONTROL_BLOCK *pECB,LPCTSTR pStrContent,DWORD dwSize );
	//-------------------------------------------------------------------------
	// this function sends a file using the ISAPI transmit file function
	//-------------------------------------------------------------------------
	


private:
	// hidden
	CMp4Server(const CMp4Server&);
	CMp4Server& operator=(const CMp4Server&);
};

#endif // !defined(AFX_SERVER_H__6C217A2F_1C77_11D4_95D1_00201858667A__INCLUDED_)
