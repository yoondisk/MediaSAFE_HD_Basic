#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdio.h> //표준입출력라이브러리
#include <stdarg.h>
#include <stdlib.h> //표준입출력라이브러리
#include <unistd.h> //fork사용라이브러리
#include <errno.h> //오류코드 매크로 정의
#include <string.h> //문자열처리 라이브러리
#include <signal.h> //시그널처리 라이브러리
#include <pthread.h>
#include "mini_web.h"
#include "rtsp_tran.h"



void enum_windows(Display* display, Window window, int depth) {
  int i;

  XTextProperty text;
  XGetWMName(display, window, &text);
  char* name;
  XFetchName(display, window, &name);
  for (i = 0; i < depth; i++){
    printf("\t");
	printf("id=0x%x, XFetchName=\"%s\", XGetWMName=\"%s\"\n", window, name != NULL ? name : "(no name)", text.value);
  }
  Window root, parent;
  Window* children;
  int n;
  XQueryTree(display, window, &root, &parent, &children, &n);
  if (children != NULL) {
    for (i = 0; i < n; i++) {
      enum_windows(display, children[i], depth + 1);
    }
    XFree(children);
  }
}

int main (void) { 


	/*
	pthread_t p_thread[2];
	int thr_id;
	char p1[] = "thread_1";   // 1번 쓰레드 이름

	printf("[FFmpeg] Transcoding Start!!\n"); 

	thr_id = pthread_create(&p_thread[0], NULL, t_function, (void *)p1);
	*/

	
	//seed_test_ctr();
	
	printf("[SEED] x1 Start!!\n"); 
	Display* display = XOpenDisplay(NULL);
	if (display!=NULL){
		printf("[SEED] x2 Start!!\n"); 
		Window root = XDefaultRootWindow(display);
		printf("[SEED] x3 Start!!\n"); 
		enum_windows(display, root, 0);
	}


	while(1){
		printf("[Socekt] Main Server Start!!\n"); 
			web_run();
		printf("[Socekt] Main Server END!!\n"); 
		sleep(0.5);
	}


}
