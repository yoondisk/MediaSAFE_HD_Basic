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
	{0,0} };//NULL

int cgi(char *buf){ //cgi 
	char *result; //char형식의 변수 선언 
	char token[]="=&";// char 형식의  변수 선언 
	int i; //int형 변수 선언 
	int n1,n2;//int형변수 n1,n2선언 
	int sum=0;//int형 변수 sum선언 
	result=strtok(buf,token); // =이전의 문자열 자르기
	result=strtok(NULL,token); // =,&사이의 NNN 잘라서 저장
	n1=atoi(result); //result를 정수형으로 n1에 저장 
	strtok(NULL,token); // &,=사이의 to 자르기
	result=strtok(NULL,token);// &,=사이의 MMM 잘라서 저장
	n2=atoi(result);//result를 정수형으로 n2에 저장 

	i=-(n1-n2)+1;// 더하는 원소 갯수 판별
	int half=i/2;//i를 반절로 
	if(i&1){//변경 후 %2대신 &1사용해서 홀수 인지 짝수인지 
		//if(i%2==1){//변경전 
		sum=(n1+n2)*half;//cgi계산 
		sum+=n1+half;//cgi 계산 
	}
	else
		sum=(n1+n2)*half;//cgi 계산 
	return sum;//계산 결과를 리턴 
}

void log(char *s1, char *s2, int size)//로그 매개변수 
{
	int fpp;//로그에 쓰기 위해서 선언 
	char logbuffer[200];//로그 버 퍼 
	sprintf(logbuffer,"%s %s %d\n",s1, s2,size); //s0=send/req, s1= ip ,s2= path/filename , size=크기,num=숫자    
	if((fpp= open("./server.log",O_WRONLY | O_APPEND,0644)) >= 0) {// 파일을 연다. 
		write(fpp,logbuffer,strlen(logbuffer)); //버퍼의 내용을 로그에 작성한다. 
		close(fpp);//type을 close해준다. 
	}
}

int web_run()//메인함수 
{
		

	int ff;//로그 파일을 재설정하기 위해서  
	ff=open("./server.log", O_CREAT|O_TRUNC,0644);//로그파일을 열어준다. 
	//printf("start\n");
	close(ff);//로그파일을 닫아준다. 
	int i, port,listenfd, socketfd, hit;//int형으로 선언 
	pid_t pid;//포크를 사용하기 위해 선언 
	size_t length;//
	static struct sockaddr_in cli_addr,serv_addr; //소켓 사용을 위한 구조체 
	
	char *path="."; // path에 경로 지정

    path = getcwd(NULL, BUFSIZ);

   
	port =8080; //입력받은 포트값을 port에 저장 


	signal(SIGCLD, SIG_IGN);  // 자식프로세스중 하나라도 종료되면 부모에게 신호전달 
	signal(SIGHUP, SIG_IGN);  // 사용자 터미널의 단절 보고
	if((listenfd = socket(AF_INET, SOCK_STREAM,0)) <0){ //소켓 파일기술자 생 
		perror("error");//에러 
		exit(1);//나간다. 
	}
	memset((char*)&serv_addr,'\0',sizeof(serv_addr));//초기화 
	serv_addr.sin_family = AF_INET;//소켓 주소 구조체1 
	serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);//all ip?소켓 주소 구조체2 
	serv_addr.sin_port = htons(port);//넣어준 포트로 설정 소켓 주소 구조체3
	if(bind(listenfd, (struct sockaddr *)&serv_addr,sizeof(serv_addr)) <0){//소켓에 이름 지정하기 
		perror("error");//bind실패시 출력 
		exit(1); //나간다. 
	}
	if( listen(listenfd,100) <0){//클라이언트 연결 기다리기 
		perror("error");//listen실패시 출력 
		exit(1);//나간다. 
	}
	char *buff;//문자형 변수선언 
	for(hit=1;;hit++){//while문과 동일 
		length = sizeof(cli_addr);//cli_addr사이즈를 length에 저장한다. 
		if((socketfd = accept(listenfd, (struct sockaddr *)&cli_addr, &length)) < 0){//연결요청 수락 
			perror("error");//accept가 잘안되면 실행 
			exit(1);//나간다. 
		}
		buff=inet_ntoa(cli_addr.sin_addr);//아이피를 buff에 저장한다. 
		if((pid = fork()) < 0) {//안열리면 
			exit(1);//나간다. 
		}
		else{//아니면 실행 
			if(pid == 0) {////////////////////fork시작 
				close(listenfd);//listenfd를 닫아준다. 
				char file_name[50];//파일 이름
				// int size;//파일 크기를 구하기 위한 변수 선언 
				int j, file_fd, buflen, len;//int형변수 선언 
				int i, ret;//int형 변수 선언 
				char * fstr;//content type을 저장할 문자열 변수 
				static char buffer[BUFSIZE+1];//버퍼 선언   
				ret =read(socketfd,buffer,BUFSIZE); //fd에서 계속 읽어옴  
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
				if( !strncmp(&buffer[0],"GET /\0",6))//GET /\0일때  
					strcpy(buffer,"GET /index.html");   //index.html출력하도록 request변경 
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

				
				sprintf(path,"%s/%s",path,rfile_name);//path에 path/filename을 해준다. 

				printf("%s\n",path); 

				file_fd = open(path,O_RDONLY); //get을 떼어네고 파일을 열어봄 없는 파일일때 
				fstat(file_fd,&s);//폴더인지 아닌지 확인하기 위해서 사용 
				if(file_fd==-1){//파일이 아니라면? 
					if(strstr(file_name,"&to")){ //받은 파일 이름에 &to가 있다면? 
						int n=cgi(&buffer[5]);//파일내용을 cgi에 넣고 cgi의 리턴값을 n으로 받는다. 
						sprintf(buffer,"HTTP/1.1 200 OK\nContent-Type: text/html\r\n\r\n<HTML><BODY><H1>%d</H1></BODY></HTML>\r\n",n); /* Header + a blank line */
						// write(socketfd,buffer,strlen(buffer));//socketfd에 버퍼내용을 써줌. 
						// sprintf(buffer, "",n);//cgi내용 출력 
						write(socketfd,buffer,strlen(buffer));//socketfd에 버퍼를 써준다.
					//	printf("%s\n",file_name); 
						log(buff,file_name,strlen(buffer)-80); //ip,파일, 몇번 째                     
					}
					else{
						sprintf(buffer,"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<HTML><BODY><H1>NOT FOUND</H1></BODY></HTML>\r\n");//200으로 헤더를 설정 
						//write(socketfd,buffer,strlen(buffer));       //fd에 버퍼의 내용을 써준다.  
						//sprintf(buffer, "");   //버퍼에 화면에 입력할 내용을 저장 
						write(socketfd,buffer,strlen(buffer)); //버퍼의 내용을 fd에 써준다. 
						log(buff,file_name,9);//로그작성    
					}
					exit(1);//나간다. 
				}
				else if(S_ISDIR(s.st_mode)){//파일일때 
					sprintf(buffer,"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<HTML><BODY><H1>NOT FOUND</H1></BODY></HTML>\r\n");//200으로 헤더를 설정 
					//write(socketfd,buffer,strlen(buffer));       //fd에 버퍼의 내용을 써준다.  
					//sprintf(buffer, "");   //버퍼에 화면에 입력할 내용을 저장 
					write(socketfd,buffer,strlen(buffer)); //버퍼의 내용을 fd에 써준다. 
					log(buff,file_name,9);//로그작성 
					exit(1);    //나감 
				}
				sprintf(buffer,"HTTP/1.1 200 OK\r\nContent-Type: %s\r\n\r\n", fstr);//200으로 헤더를 설정 
				log(buff,file_name,s.st_size); //로그작성 
				write(socketfd,buffer,strlen(buffer));//socekfd에 버퍼를 써준다. 
				while ((ret = read(file_fd, buffer, BUFSIZE)) > 0 ) {//파일을 읽는다. 
					write(socketfd,buffer,ret);//읽은 내용을 써준다. 
				}
				exit(1);//나간다. 
			} 
			else {
				close(socketfd);//socketfd를 닫는다. 
			}
		}
	}
	return 0; // 0반환
}