CC    = gcc
LDFLAGS    = -g -O2 -static 
LIB_PATH    = /root/ffmpeg_build/lib/libavformat.a /root/ffmpeg_build/lib/libavcodec.a /root/ffmpeg_build/lib/libavutil.a /root/ffmpeg_build/lib/libswresample.a
INCLUDE_PATH    = -I/root/fmpeg_build/include
SEARCH_LIB    = -L/root/ffmpeg_build/lib
LIBAVFLAGS    = -lavformat -lavcodec -lavutil -lswresample -lpthread 
SOURCEFILE    = src/rtsp_tran.c src/mini_web.c src/yoonagent.c
FLAGS    = -Wall -lm -lz
make:
	$(CC) $(LDFLAGS) $(INCLUDE_PATH) -o yoonagent $(LIB_PATH) $(SOURCEFILE) $(LIBAVFLAGS) $(FLAGS) $(SEARCH_LIB)
	upx yoonagent
clean:
	rm -rf *.o rm -rf *.m3u8 rm -rf *.ts rm -rf *.log rm -rf *.gz rm -rf yoonagent 

