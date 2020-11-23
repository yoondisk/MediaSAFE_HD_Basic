// stdafx.h : include file for standard system include files,
//  or project specific include files that are used frequently, but
//      are changed infrequently
//

#if !defined(AFX_STDAFX_H__A3FCA8B9_1C58_11D4_95D1_00201858667A__INCLUDED_)
#define AFX_STDAFX_H__A3FCA8B9_1C58_11D4_95D1_00201858667A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef WINVER				
#define WINVER 0x0500		
#endif

// Insert your headers here
#define STRICT
#define WIN32_LEAN_AND_MEAN
#define   _STLP_NEW_PLATFORM_SDK   1
#define    _STLP_USE_MFC    1
#pragma warning (disable : 4309)
#pragma warning (disable : 4305)
#pragma warning (disable : 4800)
#pragma warning (disable : 4089)
#pragma warning (disable : 4244)

#include <afxtempl.h> 

#include <afx.h>
#include <afxwin.h>
#include <afxmt.h>		
#include <afxext.h>
#include <afxisapi.h>

#endif // !defined(AFX_STDAFX_H__A3FCA8B9_1C58_11D4_95D1_00201858667A__INCLUDED_)
