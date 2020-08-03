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
#define BUFSIZE 1012 // 버프사이즈 정의
#define LOG   44 //로그 정의
#define HOME /index.html //home 정의

char  key_byffers[100][1000]; //key buffers
int key_cnt=0;


// BASE64
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

int web_run()//메인함수 
{

	for (int kn=0;kn<100;kn++ ){
		memset(key_byffers[kn], 0, 1000);
	}

	int web_server_end=0;
	int err_ret=0;
	int ff;//로그 파일을 재설정하기 위해서  
	ff=open("./logs/server.log", O_CREAT|O_TRUNC,0644);//로그파일을 열어준다. 
	//printf("start\n");
	close(ff);//로그파일을 닫아준다. 
	int i, port,listenfd, socketfd, hit;//int형으로 선언 
	pid_t pid;//포크를 사용하기 위해 선언 
	size_t length;//
	static struct sockaddr_in cli_addr,serv_addr; //소켓 사용을 위한 구조체 
	
	char *path="."; // path에 경로 지정

    path = getcwd(NULL, BUFSIZ);

   
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
	for(hit=1;;hit++){//while문과 동일 
		length = sizeof(cli_addr);//cli_addr사이즈를 length에 저장한다. 
		
		printf("[web start] =================== : %d  \n",hit); 
		

		if((socketfd = accept(listenfd, (struct sockaddr *)&cli_addr, &length)) < 0){//연결요청 수락 
			perror("error");//accept가 잘안되면 실행 
			exit(1);//나간다. 
		}
		buff=inet_ntoa(cli_addr.sin_addr);//아이피를 buff에 저장한다. 
		

		//
		char file_name[BUFSIZE];//파일 이름
		// int size;//파일 크기를 구하기 위한 변수 선언 
		int j, file_fd, buflen, len;//int형변수 선언 
		int range_ok=1;
		int i, ret;//int형 변수 선언 
		char * fstr;//content type을 저장할 문자열 변수 
		static char buffer[BUFSIZE+1];//버퍼 선언   
		static char xbuffer[100];//버퍼 선언   
		ret =read(socketfd,buffer,BUFSIZE); //fd에서 계속 읽어옴  
		printf("[info] %d =================== \n",key_cnt); 
				printf("%s\n",buffer); 
		printf("[info] =================== \n");
		char *srange;
				
		/*
			range 
		*/
		if(strstr(buffer,"Range: bytes")){ //받은 파일 이름에 &end 있다면? 
			srange=strstr(buffer,"Range: bytes");
			strcpy(xbuffer,srange+13);
			for(i=0;i<100;i++) { //GET /images/05_08-over.gif 이런식으로 만들어줌 
				if(xbuffer[i] == '-') { //공백을 확인 
					xbuffer[i] = 0;//공백일때 0 
					break;//for문 탈출 
				}
			}
					
		}
		
		range_ok=0;
				
		if(ret == 0 || ret == -1) {//읽기 실패하면 
			exit(1);//나간다. 
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

			
		printf("[file] %s\n",rfile_name); 

		if(strstr(rfile_name,".rtsp")){ //받은 파일 이름에 &end 있다면? 
			if (key_cnt>100){ key_cnt=0;}

			
			err_ret=0;
			for (int kn=0;kn<100 ;kn++ ){
				if (strlen(key_byffers[kn])==0){
					continue;
				}
				if(strstr(key_byffers[kn],rfile_name)){ 
					sprintf(buffer,"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<HTML><BODY><H1>DRM KEY ERROR</H1></BODY></HTML>\r\n");//200으로 헤더를 설정 
					write(socketfd,buffer,strlen(buffer)); //버퍼의 내용을 fd에 써준다. 
					log(buff,file_name,9);//로그작성    
					close(socketfd);//socketfd를 닫는다. 
					err_ret=1;
					break;

				}
				printf("[rtsp key] [%d] %s<===\n",kn,key_byffers[kn]); 

			}
			if (err_ret==0){
				strncpy(key_byffers[key_cnt], rfile_name, strlen(rfile_name));
				key_cnt++;
			}

		}
		
		if((pid = fork()) < 0) {//안열리면 
			exit(1);//나간다. 
		}else{//아니면 실행 
			if(pid == 0) {////////////////////fork시작 
				close(listenfd);//listenfd를 닫아준다. 
				/*부모에게 값 보냄.*/
			
					if(strstr(file_name,".rtsp") && err_ret==0){ //받은 파일 이름에 &end 있다면? 
						
						
						sprintf(buffer,"HTTP/1.1 200 OK\r\nContent-Type: %s\r\nConnection: keep-alive\r\nAccept-Ranges: bytes\r\n\r\n", "video/mp4");//200으로 헤더를 설정 
						write(socketfd,buffer,strlen(buffer));//socekfd에 버퍼를 써준다.
						char rtsp_enc_url[BUFSIZE];
						char* rtsp64_url;
						int ret_len=0;
						memset(rtsp_enc_url, 0, BUFSIZE);
						
						strncpy(rtsp_enc_url, rfile_name, strlen(rfile_name)-5);

						rtsp64_url=__base64_decode(rtsp_enc_url,strlen(rtsp_enc_url)+1,&ret_len);
						
						seed_cbc_durl(rtsp64_url,ret_len);
						printf("[rtsp url] %s<===\n",rtsp64_url); 

						if (strlen(rtsp64_url)>0){
							rtsp_hls(rtsp64_url,socketfd);
						}
						
						close(socketfd);//socketfd를 닫는다. 
						printf("[rtsp end] ===================   \n",buffer); 
						break;
					}
					
					
					sprintf(buffer,"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<HTML><BODY><H1>NOT FOUND</H1></BODY></HTML>\r\n");//200으로 헤더를 설정 
					write(socketfd,buffer,strlen(buffer)); //버퍼의 내용을 fd에 써준다. 
					log(buff,file_name,9);//로그작성    
					
					exit(1);//나간다. 
			
			} 
			else {
				close(socketfd);//socketfd를 닫는다. 
			}
		}
		
		printf("[end loop]  ====================================== %d - end flag: %d \n",hit,web_server_end); 
	}
	printf("[end last]  ====================================== \n"); 
	return 0; // 0반환
}