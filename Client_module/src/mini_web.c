#include <stdio.h> //표준입출력라이브러리
#include <stdlib.h> //표준입출력라이브러리
#include <unistd.h> //fork사용라이브러리
#include <errno.h> //오류코드 매크로 정의
#include <string.h> //문자열처리 라이브러리
#include <fcntl.h> //파일관련 라이브러리
#include <signal.h> //시그널처리 라이브러리
#include <sys/types.h> //시스템관련 라이브러리
#include <sys/socket.h> //네트워크통신 라이브러리
#include <netinet/in.h> //인터넷주소체계 사용 라이브러리
#include <arpa/inet.h> //버클리소켓사용 라이브러리
#include <sys/stat.h> // 파일정보 라이브러리
#include <netdb.h>
#include <netdb.h>
#include "config_ctr.c"

#define BUFSIZE 1012 // 버프사이즈 정의
#define MP4_BUFSIZE 4096 // 버프사이즈 정의
#define LOG   44 //로그 정의
#define MAX_PID   100 //pid 최대 수 정의
#define HOME /index.html //home 정의



char  key_byffers[100][1000]; //key buffers
int key_cnt=0;
pid_t pid[MAX_PID];

// BASE64 ARRAY
static char __base64_table[] ={
   'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
   'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
   'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
   'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
   '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/', '\0'
};

static char __base64_pad = '=';


struct stat s; //아래에서 파일 크기를 구하기 위해서 사용함 
struct {//구조체 
	char *ext; //char 형식 변수 선언
	char *filetype; // char 형식 변수 선언
} extensions [] = {
	{"gif", "image/gif" },  //gif 
	{"jpg", "image/jpg"},    //jpg
	{"jpeg","image/jpeg"},   //jpeg
	{"png", "image/png" },  //png
	{"htm", "text/html" },  //htm
	{"html","text/html" },  //html
	{"mp4","video/mp4" },  //mp4
	{"css","text/css" },  //mp4
	{0,0} };//NULL



void log(char *s1, char *s2, int size)//로그 매개변수 
{
	int fpp;//로그에 쓰기 위해서 선언 
	char logbuffer[200];//로그 버 퍼 
	sprintf(logbuffer,"%s %s %d\n",s1, s2,size); //s0=send/req, s1= ip ,s2= path/filename , size=크기,num=숫자    
	if((fpp= open("./logs/server.log",O_WRONLY | O_APPEND,0644)) >= 0) {// 파일을 연다. 
		write(fpp,logbuffer,strlen(logbuffer)); //버퍼의 내용을 로그에 작성한다. 
		close(fpp);//type을 close해준다. 
	}
}

/*
	char to base64 decode 
*/
unsigned char *__base64_decode(const unsigned char *str,int length,int *ret_length) {
   const unsigned char *current = str;
   int ch, i = 0, j = 0, k;
   /* this sucks for threaded environments */
   static short reverse_table[1000];
   static int table_built;
   unsigned char *result;

   if (++table_built == 1) {
      char *chp;
      for(ch = 0; ch < 1000; ch++) {
         chp = strchr(__base64_table, ch);
         if(chp) {
            reverse_table[ch] = chp - __base64_table;
         } else {
            reverse_table[ch] = -1;
         }
      }
   }

   result = (unsigned char *)malloc(length + 1);
   if (result == NULL) {
      return NULL;
   }

   /* run through the whole string, converting as we go */
   while ((ch = *current++) != '\0') {
      if (ch == __base64_pad) break;

      /* When Base64 gets POSTed, all pluses are interpreted as spaces.
         This line changes them back.  It's not exactly the Base64 spec,
         but it is completely compatible with it (the spec says that
         spaces are invalid).  This will also save many people considerable
         headache.  - Turadg Aleahmad <turadg@wise.berkeley.edu>
      */

      if (ch == ' ') ch = '+';

      ch = reverse_table[ch];
      if (ch < 0) continue;

      switch(i % 4) {
      case 0:
         result[j] = ch << 2;
         break;
      case 1:
         result[j++] |= ch >> 4;
         result[j] = (ch & 0x0f) << 4;
         break;
      case 2:
         result[j++] |= ch >>2;
         result[j] = (ch & 0x03) << 6;
         break;
      case 3:
         result[j++] |= ch;
         break;
      }
      i++;
   }

   k = j;
   /* mop things up if we ended on a boundary */
   if (ch == __base64_pad) {
      switch(i % 4) {
      case 0:
      case 1:
         free(result);
         return NULL;
      case 2:
         k++;
      case 3:
         result[k++] = 0;
      }
   }
   if(ret_length) {
         *ret_length = j;
   }

   result[k] = '\0';
   return result;
}

/*
	web_run main
*/
void err_key(int socket_id){
	static char hbuffer[BUFSIZE+1];//버퍼 선언  
	sprintf(hbuffer,"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<HTML><BODY><H1>DRM KEY ERROR</H1></BODY></HTML>\r\n");
	write(socket_id,hbuffer,strlen(hbuffer)); //버퍼의 내용을 fd에 써준다. 
	close(socket_id);//socketfd를 닫는다. 
}

/*
	web_run main
*/
int web_run(){

	/* License Key init */
	for (int kn=0;kn<100;kn++ ){
		memset(key_byffers[kn], 0, 1000);
	}

	int err_ret=0;
	
	int ff;//로그 파일을 재설정하기 위해서  
	ff=open("./logs/server.log", O_CREAT|O_TRUNC,0644);//로그파일을 열어준다. 
	close(ff);//로그파일을 닫아준다. 
	
	int i, port,listenfd, socketfd, hit;//int형으로 선언 
	
	size_t length;//
	static struct sockaddr_in cli_addr,serv_addr; //소켓 사용을 위한 구조체 
	
	char *path="."; // path에 경로 지정
    path = getcwd(NULL, BUFSIZ); // 현재 실행 경로 얻기.

	port =9000; //입력받은 포트값을 port에 저장 

	signal(SIGCLD, SIG_IGN);  // 자식프로세스중 하나라도 종료되면 부모에게 신호전달 
	signal(SIGHUP, SIG_IGN);  // 사용자 터미널의 단절 보고
	if((listenfd = socket(AF_INET, SOCK_STREAM,0)) <0){ //소켓 파일기술자 생 
		perror("error");//에러 
		exit(1);//나간다. 
	}

	int enable = 1;
	if (setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int)) < 0)
    error("setsockopt(SO_REUSEADDR) failed");

	memset((char*)&serv_addr,'\0',sizeof(serv_addr));//초기화 
	serv_addr.sin_family = AF_INET;//소켓 주소 구조체1 
	serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);//all ip?소켓 주소 구조체2 
	serv_addr.sin_port = htons(port);//넣어준 포트로 설정 소켓 주소 구조체3

	if(bind(listenfd, (struct sockaddr *)&serv_addr,sizeof(serv_addr)) <0){//소켓에 이름 지정하기 
		perror("error");//bind실패시 출력 
		exit(1); //나간다. 
	}
	
	if( listen(listenfd,500000) <0){//클라이언트 연결 기다리기 
		perror("error");//listen실패시 출력 
		exit(1);//나간다. 
	}

	char *buff;//문자형 변수선언 

	for(hit=0;;hit++){//while문과 동일 
		if (hit>MAX_PID){
			hit=0;
		}
		length = sizeof(cli_addr);//cli_addr사이즈를 length에 저장한다. 

		printf("\n\n[Socekt Start] =================== : %d  \n",hit); 
		if((socketfd = accept(listenfd, (struct sockaddr *)&cli_addr, &length)) < 0){//연결요청 수락 
			perror("error");//accept가 잘안되면 실행 
			exit(1);//나간다. 
		}
		
		buff=inet_ntoa(cli_addr.sin_addr);//아이피를 buff에 저장한다. 

		char file_name[BUFSIZE];//요청 이름
		int j, buflen, len;//int형변수 선언 
		int i, ret;//int형 변수 선언 
		char * fstr;//content type을 저장할 문자열 변수 
		static char buffer[BUFSIZE+1];//버퍼 선언   
		
		static char range_start[100]={0}; //range start array 선언   
		static char range_end[100]={0}; //range start array 선언   
		static char http_reffer[4096]={0}; //버퍼 선언   


		ret =read(socketfd,buffer,BUFSIZE); //fd에서 계속 읽어옴  
		printf("\n\n[info][start] Key Cnt: %d =================== \n\n",key_cnt); 
				printf("%s\n",buffer); 
		printf("[info][end] =================================\n\n");
				
		/*
			range , reffer 
		*/
		printf("[Range][Start] =================================\n\n");
		char *srange;
		if(strstr(buffer,"Range: bytes")){ //Http Header Range
			srange=strstr(buffer,"Range: bytes");
			strcpy(range_start,srange+13);
			strcpy(range_end,srange+13);
			int end_line=0;
			for(i=0;i<100;i++) { 
				if(range_end[i] == '-') { //공백을 확인 
					range_start[i] = 0;//공백일때 0 
					strcpy(range_end,srange+14+i);
					end_line=i;
				}
				if(range_end[i] == '\r') { //공백을 확인 
					if (end_line==1){
						//range_end[0]=0x30;
						range_end[0]=0;
					}else{
						range_end[i]=0;
					}
					break;
				}
			}
			printf("[Header Range] %s-%s<=================== \n\n",range_start,range_end);
		}
		printf("[Range][End] =================================\n\n");
		
		printf("[REFERER][Start] =================================\n\n");
		char *referer;
		if(strstr(buffer,"Referer: ")){ //Http Header Referer
			referer=strstr(buffer,"Referer: ");
			strcpy(http_reffer,referer);
			for(i=0;i<4096;i++) { 
				if(http_reffer[i] == '\r') { //공백을 확인 
					http_reffer[i]=0;
					break;
				}
			}	
		}
		printf("[REFERER][End] =================================\n\n");
		
		if(ret == 0 || ret == -1) {//읽기 실패하면 
			printf("[socketfd][ret][Err] =================================\n\n");
			break;
		}
		if(ret > 0 && ret < BUFSIZE)  //ret이 0보다 크고 BUFSIZE보다 작으면 
			buffer[ret]=0;   //buffer[ret]은 0이 된다. 
		else buffer[0]=0;//위를 만족하지 않는다면 buffer[0]=0이된다. 
			for(i=4;i<BUFSIZE;i++) { //GET /images/05_08-over.gif 이런식으로 만들어줌 
				if(buffer[i] == ' ') { //공백을 확인 
						buffer[i] = 0;//공백일때 0 
						break;//for문 탈출 
				}
			}
				
			buflen=strlen(buffer); // buflen에 buffer길이 저장
			
			/* MimeType */
			fstr = NULL;//null로 초기화 
			for(i=0;extensions[i].ext != 0;i++) { // 구조체 내 탐색
				len = strlen(extensions[i].ext); // 길이지정
				if( !strncmp(&buffer[buflen-len], extensions[i].ext, len)) { // 지정한 문자 갯수까지만 비교
					fstr =extensions[i].filetype; //gif형식이면 image/gif로 
					break;//for문을 나간다. 
				}
			}
			strcpy(file_name,&buffer[5]);//buffer[5] 즉 파일 이름을 filename에 복사해준다. 
			char *rfile_name = strtok(file_name, "?");    //첫번째 strtok 사용.

			
		printf("[param] %s\n",rfile_name); 
		printf("[REFERER] %s\n",http_reffer); 

		/* .rtsp License Key Check */
		if( strstr(rfile_name,".rtsp")  ){
			if (key_cnt>100){ key_cnt=0;}

			err_ret=0;
			for (int kn=0;kn<100 ;kn++ ){
				if (strlen(key_byffers[kn])==0){
					continue;
				}
				if(strstr(key_byffers[kn],rfile_name)){ 
					err_key(socketfd);
					log(buff,file_name,9);//로그작성    
					err_ret=1;
					break;

				}
				printf("[drm key] [%d] %s<===\n",kn,key_byffers[kn]); 

			}
			if (err_ret==0){
				strncpy(key_byffers[key_cnt], rfile_name, strlen(rfile_name));
				key_cnt++;
			}

		}
		
		/*
			Fork Child Create..
		*/
		if((pid[hit] = fork()) < 0) {//안열리면 
			printf("[err] fork Create Error\n"); 
			break;
		}else{//아니면 실행 
			/*
				Fork Child Start  
			*/
			if(pid[hit] == 0) {
				close(listenfd);//listenfd를 닫아준다. 
					/*
						http progressive download mp4 play start
					*/
					if(strstr(file_name,".mp4") && err_ret==0){ 
						char mp4_enc_url[BUFSIZE];
						char* mp464_url;
						int ret_len=0;
						memset(mp4_enc_url, 0, BUFSIZE);
						
						strncpy(mp4_enc_url, rfile_name, strlen(rfile_name)-4);

						printf("[mp4 url]%s<===\n",mp4_enc_url); 

						mp464_url=__base64_decode(mp4_enc_url,strlen(mp4_enc_url)+1,&ret_len);
						
						seed_cbc_durl(mp464_url,ret_len,http_reffer);
						if (strlen(mp464_url)<1){
							printf("[mp4 url][%s] Null Error <===\n",mp464_url); 
							err_key(socketfd);
							exit(1);
						}
							


						strcpy(mp464_url,mp464_url+7);
						printf("[mp4 url]%s<===\n",mp464_url); 

						if (strlen(mp464_url)>0){

							int   port=80;
							char  org_url[BUFSIZE]={0};
							char  host_name[BUFSIZE]={0};
							char  host_port[BUFSIZE]={0};
							char  mp4_file[BUFSIZE]={0};
							strcpy(org_url,mp464_url);

							int splitptr_cnt=0;
							char *splitptr = strtok(org_url, "/");  

							while (splitptr != NULL){
								if (splitptr_cnt==0){
									strcpy(host_name,splitptr);
									break;
								}
								splitptr_cnt++;
								splitptr = strtok(NULL, "/"); 
							}
							if (strstr(host_name,":")){
								int iii=0;
								for(iii=0;iii<100;iii++) { 
									if(host_name[iii] == ':') { 
										strcpy(host_port,host_name+iii+1);
										host_name[iii] = 0;
										break;
									}
								}
							}
							if (strlen(host_port)<1){
								strcpy(mp4_file,mp464_url+strlen(host_name));
							}else{
								port=atoi(host_port);
								strcpy(mp4_file,mp464_url+strlen(host_name)+strlen(host_port)+1);
							}

							struct hostent *host_entry;
							host_entry = gethostbyname(host_name);
							if (!host_entry){
								printf( "host to ip Error/n");
								exit( 1);
							}
							printf("[mp4      host]%s<===\n",host_name); 
							printf("[mp4 host   ip]%s<===\n",inet_ntoa( *(struct in_addr*)host_entry->h_addr_list[0]) ); 
							printf("[mp4 host port]%d<===\n",port); 
							printf("[mp4      file]%s<===\n",mp4_file); 

							

							struct sockaddr_in    server_addr;
							memset( &server_addr, 0, sizeof( server_addr));
							server_addr.sin_family = AF_INET;
							server_addr.sin_port = htons(port);
							server_addr.sin_addr.s_addr=  inet_addr( inet_ntoa( *(struct in_addr*)host_entry->h_addr_list[0]) );
							printf("[mp4 Connect] Connect to %s: ", inet_ntoa(server_addr.sin_addr));

							int mp4_socket;
							mp4_socket = socket( AF_INET, SOCK_STREAM, 0);
							if( -1 == mp4_socket){
							   printf( "mp4_socket create error\n");
							   exit(1);
							}

							if( -1 == connect( mp4_socket, (struct sockaddr*)&server_addr,  sizeof(server_addr) ) )
							{
							   printf( "mp4_server connect fail\n");
							   exit(1);
							}

							 
							
							sprintf(buffer,
								"GET %s HTTP/1.1\r\nHost: %s\r\nConnection: keep-alive\r\nAccept: */*\r\nUser-Agent: %s\r\nRange: bytes=%s-%s\r\n\r\n", 
							mp4_file,
							host_name,
							"Yoondisk_HD",
							range_start,
							range_end	
							);

							printf("\n[mp4 host header]\n%s===================\n",buffer);

							//mp4_server put	 
							write(mp4_socket,buffer,strlen(buffer));
							int rets=0;
							long clens=0;
							long rlens=0;
							int dlen=0;

							int ck_cnt=0;

							static char buffer_mp4[MP4_BUFSIZE];//버퍼 선언   
							static char buffer_mp4_enc_one[MP4_BUFSIZE];//버퍼 선언   
							static char buffer_mp4_enc_two[MP4_BUFSIZE*2];//버퍼 선언   
							int enc_len=0;
							char  head_str[BUFSIZE]={0};
							while(1){
								int rdata_=0;

								if (dlen==50){
									//printf("[mp4 recv][]read start]==========================\n"); 
								}
								ret =read(mp4_socket,buffer_mp4,MP4_BUFSIZE); //fd에서 계속 읽어옴  
								if (ret<1){break;}
								
								if (dlen==50){
									//printf("[mp4 recv][]read end][%d] [%d]===================\n",ret,rets); 
								}

								dlen++;
								
								
								if (rets==0){
									int head_eof=0;
									int eof_ck=0;
									while(1) { 
										head_str[head_eof]=buffer_mp4[head_eof];
										/*
											0D => \r
											0A => \n
											\r\n\r\n
										*/
										if(buffer_mp4[head_eof] == 0x0A || buffer_mp4[head_eof] == 0x0D) {eof_ck++;}else{eof_ck=0;}
										if (eof_ck==4){
											/*
											 HTTP HEAD == DATA SPLITE
											*/
											head_eof++;

											rdata_=head_eof;
											ret=ret-head_eof;

											/*
												Data Copy
												ret lens fix
											*/
											memcpy(buffer_mp4,buffer_mp4+rdata_,ret);
											
											/*
												Send HTTP Header
											*/
											write(socketfd,head_str,head_eof);

											printf("[mp4 header]origin[%d][%d][%s]===================\n",ret,rdata_,head_str); 
											
											int splitptr_cnt=0;
											char *splitptr = strtok(head_str, "\r\n");  

											while (splitptr != NULL){
												printf("[mp4 header][%s]===================\n",splitptr); 
												if (strstr(splitptr,"Content-Length: ")){
													/*
														Content-Length: XXXXXXXX
													*/
													strcpy(splitptr,splitptr+16);
													clens=atol(splitptr)+head_eof;
													break;
												}
												splitptr_cnt++;
												splitptr = strtok(NULL, "\r\n"); 
											}
											break;
										}
										head_eof++;
									}
								}
								

								

							
								if (dlen==50){
									//printf("[mp4 recv][]write start][%d] [%d]===================\n",ret,rets); 
								}
								
								
								memcpy(buffer_mp4_enc_two+enc_len,buffer_mp4,ret);
								enc_len=enc_len+ret;

								
								/*
									KISA SEED CTR BLOCK Decrypt Start
								*/
								if (enc_len>=4096 || clens<=4096 ){

									int d_szie=4096;
									if (clens<=4096){d_szie=clens;}

									memcpy(buffer_mp4,buffer_mp4_enc_two,d_szie);
									
									int Seed_Len = SEED_CTR_Decrypt( pbszUserKey_ctr, pbszCounter_ctr, (BYTE*)buffer_mp4, d_szie, (BYTE*)buffer_mp4_enc_one );
									
									fd_set readfds;
									struct timeval tv;
									FD_ZERO(&readfds);
									FD_SET(socketfd, &readfds);
									// 약 0.1초간 기다린다. 
									tv.tv_sec = 0.01;
									tv.tv_usec = 0;
									// 소켓 상태를 확인 한다. 
									int state = select(socketfd+1, &readfds,(fd_set *)0, (fd_set *)0, &tv);
									if (state==1){
										printf("[mp4 recv][]write state][exit]===================\n"); 
										break;
									}
									write(socketfd,buffer_mp4_enc_one,d_szie);
									//write(socketfd,buffer_mp4,d_szie);
									
									clens=clens-d_szie;
									rlens=rlens+d_szie;
									enc_len=enc_len-d_szie;
									memcpy(buffer_mp4_enc_two,buffer_mp4_enc_two+d_szie,enc_len);

									if (clens<=4096){
										d_szie=clens;
										memcpy(buffer_mp4,buffer_mp4_enc_two,d_szie);
										int Seed_Len = SEED_CTR_Decrypt( pbszUserKey_ctr, pbszCounter_ctr, (BYTE*)buffer_mp4, d_szie, (BYTE*)buffer_mp4_enc_one );
										write(socketfd,buffer_mp4_enc_one,d_szie);
										//write(socketfd,buffer_mp4,d_szie);
										break;
									}
								}
								/*
									KISA SEED CTR BLOCK Decrypt End
								*/

								
								if (dlen==50){
									//printf("[mp4 recv][]write end][%d] [%d]===================\n",ret,rets); 
								}
								rets++;
								
								if (dlen==50){
									dlen=0;
								}

							}
							close(mp4_socket);

						}
						
						close(socketfd);//socketfd를 닫는다. 
						printf("[mp4 end] ===================   \n"); 
						exit(1);//나간다. 
					}
					/*
						http progressive download mp4 play end
					*/



					/*
						rtsp live start
					*/
					if(strstr(file_name,".rtsp") && err_ret==0){ 
						sprintf(buffer,"HTTP/1.1 200 OK\r\nContent-Type: %s\r\nConnection: keep-alive\r\nAccept-Ranges: bytes\r\n\r\n", "video/mp4");//200으로 헤더를 설정 
						write(socketfd,buffer,strlen(buffer));//socekfd에 버퍼를 써준다.
						char rtsp_enc_url[BUFSIZE];
						char* rtsp64_url;
						int ret_len=0;
						memset(rtsp_enc_url, 0, BUFSIZE);
						
						strncpy(rtsp_enc_url, rfile_name, strlen(rfile_name)-5);

						rtsp64_url=__base64_decode(rtsp_enc_url,strlen(rtsp_enc_url)+1,&ret_len);
						
						seed_cbc_durl(rtsp64_url,ret_len,http_reffer);
						printf("[rtsp url] %s<===\n",rtsp64_url); 

						if (strlen(rtsp64_url)>0){
							rtsp_hls(rtsp64_url,socketfd);
						}
						
						close(socketfd);//socketfd를 닫는다. 
						printf("[rtsp end] ===================   \n",buffer); 
						exit(1);//나간다. 
					}
					/*
						rtsp live end
					*/
					
						
					sprintf(buffer,"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<HTML><BODY><H1>NOT FOUND</H1></BODY></HTML>\r\n");//200으로 헤더를 설정 
					write(socketfd,buffer,strlen(buffer)); //버퍼의 내용을 fd에 써준다. 
					log(buff,file_name,9);//로그작성    
					
					exit(1);//나간다. 
			/*
				Fork Child End  
			*/		
			} 
			else {
				close(socketfd);//socketfd를 닫는다. 
			}
		}
		
		printf("[Socket loop][%d]======================================\n",hit); 
	}
	printf("[Socket End]  ====================================== \n\n\n"); 
	return 0; // 0반환
}