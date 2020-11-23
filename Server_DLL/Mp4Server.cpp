#include "stdafx.h"
#include "Server.h"

//-----------------------------------------------------------------------------
// module - 
//-----------------------------------------------------------------------------
CMp4Server	_Module;


#define PROCTEXT(x) (LPCSTR)(x)
//-----------------------------------------------------------------------------
// dllmain
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// GetExtensionVersion
//-----------------------------------------------------------------------------


BOOL WINAPI GetExtensionVersion(HSE_VERSION_INFO* pVer)
{
	OutputDebugString("[GetExtensionVersion] Yoondisk Drm Mp4 GetExtensionVersion \n");
    pVer->dwExtensionVersion = MAKELONG(HSE_VERSION_MINOR, HSE_VERSION_MAJOR);
	::strncpy(pVer->lpszExtensionDesc, "Yoondisk Drm Mp4 Extension",HSE_MAX_EXT_DLL_NAME_LEN);
	return TRUE;
}

//-----------------------------------------------------------------------------
// TerminateExtension
//-----------------------------------------------------------------------------

BOOL WINAPI TerminateExtension(DWORD dwFlags)
{
	OutputDebugString("[TerminateExtension] Yoondisk Drm Mp4 TerminateExtension \n");
	return TRUE;
}


//-----------------------------------------------------------------------------
// HttpExtensionProc
//-----------------------------------------------------------------------------


DWORD WINAPI HttpExtensionProc(EXTENSION_CONTROL_BLOCK* pECB)
{
	//-------------------------------------------------------------------------
	// we delegate everything to our application object
	//-------------------------------------------------------------------------

	try
	{
		OutputDebugString("[HttpExtensionProc] Yoondisk Drm Mp4 HttpExtensionProc Start !! \n");
			_Module.ServiceRequest(pECB);
		OutputDebugString("[HttpExtensionProc] Yoondisk Drm Mp4 HttpExtensionProc End !! \n");
		return 1;
	}
	catch(...)
	{
	}
	return HSE_STATUS_ERROR;
}
 
