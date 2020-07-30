#include <stdio.h> //표준입출력라이브러리
#include <stdlib.h> //표준입출력라이브러리
#include <unistd.h> //fork사용라이브러리
#include <errno.h> //오류코드 매크로 정의
#include <string.h> //문자열처리 라이브러리
#include <signal.h> //시그널처리 라이브러리
#include <pthread.h>
#include "mini_web.h"
#include "rtsp_tran.h"




// 쓰레드 함수
void *t_function(void *data){
  printf("[FFmpeg] Transcoding Start Real Start !!\n"); 
  rtsp_hls("rtsp://miosoft.co.kr:1935/live/natv?tcp");
}


int main (void) { 
	pthread_t p_thread[2];
	int thr_id;
	char p1[] = "thread_1";   // 1번 쓰레드 이름

	printf("[FFmpeg] Transcoding Start!!\n"); 

	thr_id = pthread_create(&p_thread[0], NULL, t_function, (void *)p1);
	
	printf("[WEB] Server Start!!\n"); 
	web_run();
	printf("[WEB] Server END!!\n"); 
	
}
