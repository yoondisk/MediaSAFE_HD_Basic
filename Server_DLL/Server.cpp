// CMp4Server class.
//
//////////////////////////////////////////////////////////////////////
#inlcude <cmath>
#include "stdafx.h"
#include "Server.h"
#include <assert.h>
#include <stdio.h>
#include "KISA_SEED_CTR.c" 
#include <math.h>  

/*
	CTR Key, Counter
	*) 반드시 변경후, YoonAgent - config_ctr.c 와 일치후 사용하세요.
*/
BYTE pbszUserKey[16] = {0x088, 0x0e3, 0x04f, 0x08f, 0x008, 0x017, 0x079, 0x0f1, 0x0e9, 0x0f3, 0x094, 0x037, 0x00a, 0x0d4, 0x005, 0x089}; 
BYTE pbszCounter[16] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe};

#define PROCTEXT(x) (LPCSTR)(x)

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CMp4Server::CMp4Server(){

}

CMp4Server::~CMp4Server(){
	
}

//-----------------------------------------------------------------------------
// Video Mime Type 
//-----------------------------------------------------------------------------
char *  drm_info(){
	return "mp4";
}

//-----------------------------------------------------------------------------
// Error 404 Page 
//-----------------------------------------------------------------------------
void CMp4Server::S404(EXTENSION_CONTROL_BLOCK* pECB){
	HSE_SEND_HEADER_EX_INFO info={0};
	DWORD size=sizeof(HSE_SEND_HEADER_EX_INFO);
	info.fKeepConn=false;
	char * httpBody="\r\n<h1>404 Not Found</h1><p>404 page not found the page you requested was not found. <h1><b>By YoonDisk Drm Open OS Version 1.0 Date : 2020-06-15 </b></h1></br><b>Contact us : https://github.com/yoondisk/MediaSAFE_HD_Basic<p>";
	char httpHeader[500];
	info.pszStatus="200 OK";
	sprintf(httpHeader,"Content-Type: text/html\r\nContent-Length: %d\r\n\r\n",strlen(httpBody));
	info.pszHeader=httpHeader;
	info.cchHeader=(DWORD)strlen(httpHeader);
	
	DWORD sizex=(DWORD)strlen(httpBody);
	pECB->ServerSupportFunction(pECB->ConnID,HSE_REQ_SEND_RESPONSE_HEADER_EX,&info,&sizex,0);
	pECB->WriteClient(pECB->ConnID,(LPVOID)httpBody,&sizex,0);
}

//-----------------------------------------------------------------------------
// ServiceRequest
//-----------------------------------------------------------------------------
DWORD CMp4Server::ServiceRequest(EXTENSION_CONTROL_BLOCK* pECB)
{
	DWORD ret = HSE_STATUS_ERROR;
	double start=0;
	double end=0;

	/*==============================================*/
	/* SEED CTR 암호검증 테스트                    */
	/*
	BYTE InputText[128] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
		0x00, 0x02, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
		0x00, 0x03, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
		0x00, 0x04, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A,
		0x00, 0x05, 0x02, 0x03, 0x04, 0x05, 0x06, 0x06, 0x06};
	BYTE pbszOutputText[128] = {0x00};
	BYTE pbszInputText[128] = {0x00};
	int i;
	int nInputTextLen=128;
	int nOutputTextLen;

	OutputDebugString("\n[Seed_test_ctr] Start ================================= \n");
	
	OutputDebugString ("Key	: ");
	for (i=0;i<16;i++)	{
		CString v="";v.Format("%02X ",pbszUserKey[i]);
		OutputDebugString(v);
	}

	OutputDebugString ("\nCounter	: ");
	for (i=0;i<16;i++)	{
		CString v="";v.Format("%02X ",pbszCounter[i]);
		OutputDebugString(v);
	}

	
	printf ("\n\nPlaintext(%d)  : ", nInputTextLen);
	for (i=0;i<nInputTextLen;i++)	{
		CString v="";v.Format("%02X ",InputText[i]);
		OutputDebugString(v);
	}

	OutputDebugString ("\n\nEncryption....\n");
	// Encryption Algorithm //
	nOutputTextLen = SEED_CTR_Encrypt( pbszUserKey, pbszCounter, InputText, nInputTextLen, pbszOutputText);

	
	CString v="";v.Format("\nCiphertext(%d) : ", nOutputTextLen);
	OutputDebugString(v);

	for (i=0;i<nOutputTextLen;i++)	{
		CString v="";v.Format("%02X ", pbszOutputText[i]);
		OutputDebugString(v);
	}

	OutputDebugString ("\n\nDecryption....");

	// Decryption Algorithm //
	nInputTextLen = SEED_CTR_Decrypt( pbszUserKey, pbszCounter, pbszOutputText, nOutputTextLen, pbszInputText );

	v.Format("\n\nPlaintext(%d)  : ", nInputTextLen);
	OutputDebugString(v);

	for (i=0;i<nInputTextLen;i++)	{
		CString v="";v.Format("%02X ", pbszInputText[i]);
		OutputDebugString(v);

	}

	OutputDebugString ("\n\n\n");
	OutputDebugString ("[Seed_test_ctr] End ================================= \n");

	*/
    /*==============================================*/

	ret = mp4_start(pECB,start,end);

	return 1;
}


//-----------------------------------------------------------------------------
// Cstring String Splite Function 
//-----------------------------------------------------------------------------
int s_splite(CString strTemp, CString divider, CString *returnString1){
	int count,start,CountArray;
    CString *ArrayList;
	
    //스트링을 탐색하여 배열의 갯수를 카운트한다.
    for(count=0,start=0,CountArray=0;count<strTemp.GetLength();count++)
        if(strTemp[count]==divider)    {
            // --> (1) if(!strTemp.Mid(start,count-start).IsEmpty())
			CountArray++;
            start = count+1;
        }
		if(strTemp[strTemp.GetLength()-1]!=divider)
			CountArray++;
		//
		
		ArrayList = new CString[CountArray];
		
		//스트링을 divider를 기준으로 나누어 배열에 저장한다.
		for(count=0,start=0,CountArray=0;count<strTemp.GetLength();count++)
			if(strTemp[count]==divider)    {
				if(!strTemp.Mid(start,count-start).IsEmpty())
					ArrayList[CountArray++] = strTemp.Mid(start,count-start);
				else //-> (2)
					ArrayList[CountArray++] = ""; //(3)
				start = count+1;
			}
			
			if(strTemp[strTemp.GetLength()-1]!=divider)
				ArrayList[CountArray++] = strTemp.Mid(start,count-start);
			
			for(count=0;count<CountArray;count++){
				returnString1[count] = ArrayList[count];
			}
			
			
			delete [] ArrayList;
			return CountArray;
}

//-----------------------------------------------------------------------------
// WriteContext : Data Send Client
//-----------------------------------------------------------------------------
bool CMp4Server::WriteContext( EXTENSION_CONTROL_BLOCK *pECB,LPCTSTR pStrContent,DWORD dwSize )
{
	DWORD size;
	size=dwSize;
	return pECB->WriteClient(pECB->ConnID,(LPVOID)pStrContent,&size,HSE_IO_SYNC);
}

//-----------------------------------------------------------------------------
// httpstring : HTTP mode Return String
//-----------------------------------------------------------------------------
CString CMp4Server::httpstring(EXTENSION_CONTROL_BLOCK* pECB,char* mode){
	DWORD dwsize=1000;
	TCHAR tszBuffer[1000] = {0,}; // URL
	CString htext="";
	pECB->GetServerVariable(pECB->ConnID,mode, tszBuffer, &dwsize);
	htext.Format("%s",tszBuffer);
	return htext;
}

//-----------------------------------------------------------------------------
// httpurl : HTTP Url	
//-----------------------------------------------------------------------------
CString CMp4Server::httpurl(EXTENSION_CONTROL_BLOCK* pECB,int gubun){
	CString ct=httpstring(pECB,"HTTP_URL");
	CString get_s="";

	CString *decs = new CString[100];
		int cnt1=s_splite(ct,"?",decs);
		if (cnt1>1){
			get_s=decs[1];
		}
	delete []decs;
	
	if (get_s!=""){
		CString *decsx = new CString[100];
		int cnt1=s_splite(get_s,"&",decsx);
		if (cnt1<gubun || cnt1<1){
			get_s="";
		}else{
			get_s=decsx[gubun];
		}
		delete []decsx;
	}
	return get_s;
}

//-----------------------------------------------------------------------------
// ctimes : timestamp to Cstring
//-----------------------------------------------------------------------------
CString ctimes(){
	time_t timer;
	struct tm *t;
	timer = time(NULL); // 현재 시각을 초 단위로 얻기
	t = localtime(&timer); 
	CString tmpTime="";
	tmpTime.Format("%d%02d%02d%02d%02d%02d",t->tm_year + 1900,t->tm_mon + 1,t->tm_mday,t->tm_hour,t->tm_min,t->tm_sec);
	return tmpTime;
}

//-----------------------------------------------------------------------------
// minctimes : timestamp to Cstring
//-----------------------------------------------------------------------------
CString minctimes(){
	time_t timer;
	struct tm *t;
	timer = time(NULL)-3600*2; // 현재 시각을 초 단위로 얻기
	t = localtime(&timer); 
	CString tmpTime="";
	tmpTime.Format("%d%02d%02d%02d%02d%02d",t->tm_year + 1900,t->tm_mon + 1,t->tm_mday,t->tm_hour,t->tm_min,t->tm_sec);
	return tmpTime;
}


//-----------------------------------------------------------------------------
// unixtime : unixtime to Cstring
//-----------------------------------------------------------------------------
CString unixtime (int min){
	time_t timer;
	timer = time(NULL)-min; // 현재 시각을 초 단위로 얻기
	CString tmpTime="";
	tmpTime.Format("%d",timer);
	return tmpTime;
}


//-----------------------------------------------------------------------------
// drm_ : Client Agent
//-----------------------------------------------------------------------------
DWORD CMp4Server::drm_(EXTENSION_CONTROL_BLOCK* pECB,DWORD start_h,DWORD end_h,int mode){
	int drm=1;
	CString uid=httpurl(pECB,0);
	CString timex=httpurl(pECB,1);
	CString addr=httpstring(pECB,"REMOTE_ADDR");
	CString hurl=httpstring(pECB,"HTTP_URL");
	CString agent=httpstring(pECB,"HTTP_USER_AGENT");
	int nodrm=0;

    if (agent!="Yoondisk_HD") {
			drm=0;
			OutputDebugString(agent+"[NO DRM 404!! CHECK PLEASE!!] \n");
			S404(pECB);
			return -1;
	}

	return nodrm; 	
}

//-----------------------------------------------------------------------------
// datetime : time to datetime string
//-----------------------------------------------------------------------------
CString datetime(){
	time_t timer;
	struct tm *t;
	timer = time(NULL)-((60*60)*9); 
	t = localtime(&timer); 
	CString tmpTime="";
	tmpTime.Format("%d-%02d-%02d %02d:%02d:%02d",t->tm_year + 1900,t->tm_mon + 1,t->tm_mday,t->tm_hour,t->tm_min,t->tm_sec);
	return tmpTime;
}

//-----------------------------------------------------------------------------
// iis_log : Contents to IIS Log Style
//-----------------------------------------------------------------------------
void iis_log(CString logs)
{
	return;
	time_t timer;
	struct tm *t;
	timer = time(NULL);
	t = localtime(&timer); 
	CString tmpTime="";
	tmpTime.Format("yoondisk_ex%d%02d%02d%02d.log",t->tm_year + 1900,t->tm_mon + 1,t->tm_mday,t->tm_hour);
	
	FILE* flog = fopen( "c:\\yoondisk_log\\"+tmpTime, "a" );
	fprintf( flog, "%s", logs);
	fclose( flog );
}

//-----------------------------------------------------------------------------
// mp4_start : Request Mp4 Void file to SEED CTR Ecnrypt to Client 
//-----------------------------------------------------------------------------
DWORD CMp4Server::mp4_start(EXTENSION_CONTROL_BLOCK* pECB,double start, double end){

	CString rangestring=httpstring(pECB,"ALL_HTTP");
	CString rang="HTTP_RANGE:bytes=";
	int a=rangestring.Find("HTTP_RANGE:bytes=");
	int b=rangestring.Find("\n",a);
	rangestring=rangestring.Mid(a+rang.GetLength(),b-(a+rang.GetLength()));
	
	if (a<-1 || b<-1){
		rangestring="";
	}

	/* Client User Data */
	CString addr=httpstring(pECB,"REMOTE_ADDR");
	CString sname=httpstring(pECB,"SERVER_NAME");
	CString saddr=httpstring(pECB,"SERVER_ADDR");
	CString sport=httpstring(pECB,"SERVER_PORT");
	CString cmt=httpstring(pECB,"REQUEST_METHOD");
	CString host=httpstring(pECB,"HTTP_HOST");
	CString rlen=httpstring(pECB,"CONTENT_LENGTH");
	CString hurl=httpstring(pECB,"HTTP_URL");
	CString hver=httpstring(pECB,"HTTP_VERSION");
	CString qury=httpstring(pECB,"QUERY_STRING");
	CString uni=httpstring(pECB,"PATH_INFO");
	CString agent=httpstring(pECB,"HTTP_USER_AGENT");


	CString gtime=datetime();
	CString ldata="";
	clock_t before;
	double  result;
	before  = clock();

	
	int drm=1;
	DWORD start_h=0;
	DWORD end_h=0;
	DWORD len_t=0;
	DWORD put_byte=0;
	DWORD end_byte=0;


	if (rangestring!=""){
		CString *decs = new CString[100];
		decs[1]="";
		s_splite(rangestring,"-",decs);
		CString cc="";
		cc.Format("start: %s / end: %s - ",decs[0],decs[1]);
		if (decs[0]!="") {
			start_h=(DWORD)_ttoi((LPCTSTR)decs[0]);
		}
		if (decs[1]!="") {
			end_h=(DWORD)_ttoi((LPCTSTR)decs[1]);
		}
		delete []decs;
	}

	drm=drm_(pECB,start_h,end_h,1);
	if (drm==-1){
		result = (clock() - before) ;
		ldata.Format("%s %s %s %s %s %s %s %s - %s %s %s - - %s %s 0 32 %d %s %.0f\n",gtime,"W3YOONDRM",sname,saddr,cmt,uni,qury,sport,addr,hver,agent,host,"404",0,rlen,result);
		iis_log(ldata);
		return 1;
	}

	result = (clock() - before) ;
	ldata.Format("%s %s %s %s %s %s %s %s - %s %s %s - - %s %s 0 32 %d %s %.0f\n",gtime,"W3YOONDRM",sname,saddr,cmt,uni,qury,sport,addr,hver,agent,host,"HEAD_SEND_START",0,rlen,result);
	iis_log(ldata);

	// ===========================================
	DWORD ret = HSE_STATUS_ERROR;

	char		filename[MAX_PATH+1] = {0};
	int			baseLen				 = 0;

	int nTransferData = 0;
	

	/* GET file Read */
	CFile file;
	file.Open(pECB->lpszPathTranslated,CFile::modeRead|CFile::shareDenyNone);


	/*
		HTTP Header Create Start
	*/
	DWORD start_file_start=0;
	HSE_SEND_HEADER_EX_INFO info={0};
	DWORD size=sizeof(HSE_SEND_HEADER_EX_INFO);
	info.fKeepConn=true;
	char httpHeader[500];
	if (start_h<1 && end_h==0){
		info.pszStatus="206 Partial Content";
		DWORD flen_t=file.GetLength();
		end_h=len_t=end_byte=file.GetLength();
		sprintf(httpHeader,"Content-Type: video/%s\r\naccept-ranges:bytes\r\nContent-Length: %d\r\nContent-range: bytes %d-%d/%d\r\n\r\n",drm_info(),len_t,start_h,end_h-1,flen_t);
	}else{
		info.pszStatus="206 Partial Content";
		DWORD flen_t=file.GetLength();
		end_byte=flen_t;
		if (end_h<1){
			end_h=file.GetLength()-1;
		}else{
		    end_h=end_h;
		}
		len_t=end_h-start_h+1;
	
		sprintf(httpHeader,"Content-Type: video/%s\r\naccept-ranges:bytes\r\nContent-Length: %d\r\nContent-range: bytes %d-%d/%d\r\n\r\n",drm_info(),len_t,start_h,end_h,flen_t);
		start_file_start=start_h;
	}

	OutputDebugString(httpHeader);
	info.fKeepConn=TRUE;
	info.pszHeader=httpHeader;
	info.cchHeader=(DWORD)strlen(httpHeader);
	
	/*
		HTTP Header Send
	*/
	if (!pECB->ServerSupportFunction(pECB->ConnID,HSE_REQ_SEND_RESPONSE_HEADER_EX,&info,&size,0)){
			result = (clock() - before) ;
			ldata.Format("%s %s %s %s %s %s %s %s - %s %s %s - - %s %s 0 32 %d %s %.0f\n",gtime,"W3YOONDRM",sname,saddr,cmt,uni,qury,sport,addr,hver,agent,host,"HEAD_SEND_ERR",0,rlen,result);
			iis_log(ldata);
			file.Close();
			return HSE_STATUS_ERROR;;

	}
	result = (clock() - before) ;
	ldata.Format("%s %s %s %s %s %s %s %s - %s %s %s - - %s %s 0 32 %d %s %.0f\n",gtime,"W3YOONDRM",sname,saddr,cmt,uni,qury,sport,addr,hver,agent,host,"HEAD_SEND_OK",0,rlen,result);
	iis_log(ldata);
	
	file.Close();
	/*
		HTTP Header Create End
	*/



	int Len = 0;  
	int seed_put=0;
	
	DWORD qwFileOffset = start_h;
	DWORD qwFileSize =len_t;
	CString querySQLStr="";
	DWORD lenput=0;

	result = (clock() - before) ;
	ldata.Format("%s %s %s %s %s %s %s %s - %s %s %s - - %s %s 0 32 %d %s %.0f\n",gtime,"W3YOONDRM",sname,saddr,cmt,uni,qury,sport,addr,hver,agent,host,"BODY_SEND_START",0,rlen,result);
	iis_log(ldata);



	file.Open(pECB->lpszPathTranslated,CFile::modeRead|CFile::shareDenyNone);
	file.Seek(start_h,CFile::begin);
	end_byte=len_t;
	DWORD send_byte=0;
		
		DWORD buffer_fix=DATABUFFER;

		querySQLStr.Format(" all : %d",end_byte);
		OutputDebugString("[while start] "+querySQLStr+" =========================\n");
		int ii=0;	 
		while(true){

			/* Client Socket Error Check */
			BOOL fConnected = FALSE; 
			if (!pECB->ServerSupportFunction( pECB->ConnID,HSE_REQ_IS_CONNECTED,&fConnected,NULL,NULL ) ){
				OutputDebugString("[fConnected] HSE_REQ_IS_CONNECTED break =========================\n");
			}
			if (fConnected==FALSE){
				OutputDebugString("[fConnected] break =========================\n");
				break;
			}
			char * buffer_org =new char[DATABUFFER];
			char * buffer_enc =new char[DATABUFFER];
			/* File read */
			int nRead =file.Read(buffer_org,buffer_fix);


			/* SEED_CTR_Encrypt Send */
			int nOutputTextLen;
			if (nRead==DATABUFFER){
				nOutputTextLen = SEED_CTR_Encrypt( pbszUserKey, pbszCounter, (BYTE*)buffer_org, nRead, (BYTE*)buffer_enc);
			}else{
				nOutputTextLen = SEED_CTR_Encrypt( pbszUserKey, pbszCounter, (BYTE*)buffer_org, nRead, (BYTE*)buffer_enc);
			}
			if (ii==0 && 2==3) {
				for (int i=0;i<nOutputTextLen;i++)	{
					CString v="";v.Format("%02X ",buffer_enc[i]);
					OutputDebugString(v);
				}

			}
			if(!WriteContext(pECB,buffer_enc,nRead)){
				OutputDebugString("[fConnected] WriteContext break =========================\n");
				/*Client Send Error*/
				delete[] buffer_org;
				delete[] buffer_enc;
				break;
			}

			delete[] buffer_org;
			delete[] buffer_enc;

			/* SEED_CTR_Encrypt Send */
			
			ii++;	 
			send_byte=send_byte+nRead;
			end_byte=end_byte-nRead;
			
			if (end_byte<1){
				OutputDebugString("[fConnected] end_byte break =========================\n");
				/* end length send*/
				break;
			}

			if (end_byte<=buffer_fix){
				
				buffer_fix=end_byte;
				ldata.Format("[fConnected] end_byte : %d ==================================\n",buffer_fix);
				OutputDebugString(ldata);
				
			}
		
		}

	file.Close();

	querySQLStr.Format(" push byte : %d",send_byte);
	OutputDebugString("[Yoondisk_DRM END] "+querySQLStr+" =========================\n");
	result = (clock() - before);
	ldata.Format("%s %s %s %s %s %s %s %s - %s %s %s - - %s %s 0 32 %d %s %.0f\n",gtime,"W3YOONDRM",sname,saddr,cmt,uni,qury,sport,addr,hver,agent,host,"BODY_SEND_END",0,rlen,result);
	iis_log(ldata);
	if(!pECB->ServerSupportFunction(pECB->ConnID, HSE_REQ_DONE_WITH_SESSION, 0, 0, 0)){
			// do some logging
	}

	return HSE_STATUS_SUCCESS;;
}


