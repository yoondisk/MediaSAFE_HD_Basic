#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h>
#include <time.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h> 
#include <libavformat/avio.h>
#include <libavdevice/avdevice.h>
#include <libavutil/fifo.h>



#define D_PB_BUF_SIZE 65535

uint8_t* pb_Buf;
int send_sock;


int vod_exit=0;
int write_status_flag=0;
clock_t start1, start2, end1, end2;

static int write_buffer(void *opaque, uint8_t *buf, int buf_size)
{
		fd_set readfds;
		struct timeval tv;
		FD_ZERO(&readfds);
        FD_SET(send_sock, &readfds);
        // 약 0.1초간 기다린다. 
        tv.tv_sec = 0.01;
        tv.tv_usec = 0;

        // 소켓 상태를 확인 한다. 
       int state = select(send_sock+1, &readfds,(fd_set *)0, (fd_set *)0, &tv);
	   write_status_flag++;
		if (write_status_flag==100){
			write_status_flag=0;
			printf("[send] socket: %d , buffsize: %d , state: %d \n",send_sock,buf_size,state); 
		}
	   if (state==1){
		   printf("[send] socket: %d , buffsize: %d , state: %d \n",send_sock,buf_size,state); 
		   //sleep(5);
		   vod_exit=1;
		   return buf_size;
	   }else{
			if (write(send_sock,buf,buf_size)<=0){
				printf("[send err] socket: %d , buffsize: %d \n",send_sock,buf_size); 	
			}
	   }


	
	
	return buf_size;
}

void rtsp_hls(char * url,int websocket){
	 start1 = clock();

	 send_sock=websocket;
	 vod_exit=0;
		 
	 // ffmpeg lib init
	 av_register_all(); 
	 avcodec_register_all(); 
	 avformat_network_init(); 


	 // Initialize
	 int in_video_index, in_audio_index,  out_video_index, out_audio_index;  // Video, Audio Index
	 int ret;
	 AVFormatContext* ctx = avformat_alloc_context(); 
	 AVDictionary *dicts = NULL;
	 AVFormatContext* oc = NULL; 


	 const char *rtsp_url=url;

	 avformat_alloc_output_context2(&oc, NULL, "mp4", NULL); // mp4

	 pb_Buf = (uint8_t*)av_malloc(sizeof(uint8_t)*(D_PB_BUF_SIZE));
	 oc->pb = avio_alloc_context(pb_Buf, D_PB_BUF_SIZE,1,0,NULL,write_buffer,NULL);

	oc->pb->write_flag = 1;
    oc->pb->seekable = 1;
    oc->flags=AVFMT_FLAG_CUSTOM_IO;
    oc->flags |= AVFMT_FLAG_FLUSH_PACKETS;
    oc->flags |= AVFMT_NOFILE;
    oc->flags |= AVFMT_FLAG_AUTO_BSF;
    oc->flags |= AVFMT_FLAG_NOBUFFER;

	 int rc = av_dict_set(&dicts, "rtsp_transport", "tcp", 0); // default udp. Set tcp interleaved mode
	 av_dict_set(&dicts, "buffer_size", "655360", 0); 

	 if (rc < 0){
		return EXIT_FAILURE;
	 }
	 /* 
	 rc = av_dict_set(&dicts, "stimeout", "1 * 1000 * 1000", 0); // timeout option
	 if (rc < 0){
			return -1;
	 }
	 */

	 //open rtsp 
	 if (avformat_open_input(&ctx, rtsp_url ,NULL, &dicts) != 0){ 
		 return EXIT_FAILURE; 
	 } 
	 av_dict_free(&dicts);

	 ctx->flags |= AVFMT_FLAG_NOBUFFER;
	 av_format_inject_global_side_data(ctx);
	 // get context
	 if (avformat_find_stream_info(ctx, NULL) < 0)
	 {
		return EXIT_FAILURE; 
	 } 

	 //search video stream , audio stream
	 for (int i = 0; i < ctx->nb_streams; i++)
    {
        if (((ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) && (ctx->streams[i]->codecpar->codec_id == AV_CODEC_ID_H264))
                || ((ctx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO)
                    && ((ctx->streams[i]->codecpar->codec_id == AV_CODEC_ID_AAC) || (ctx->streams[i]->codecpar->codec_id == AV_CODEC_ID_AAC_LATM))))
        {
            AVStream* in_stream = ctx->streams[i];
            AVStream* out_stream = avformat_new_stream(oc, NULL);
            if (!out_stream)
            {
                avformat_close_input(&ctx);
                avformat_free_context(oc);
                oc = NULL;
              
                return ;
            }
            if (in_stream->codecpar->codec_type == AVMEDIA_TYPE_AUDIO)
            {
                in_audio_index = in_stream->index;
                out_audio_index = out_stream->index;
            }
            if (in_stream->codecpar->codec_type == AVMEDIA_TYPE_VIDEO)
            {
                in_video_index = in_stream->index;
                out_video_index = out_stream->index;
            }
            AVCodec* in_codec = avcodec_find_encoder(in_stream->codecpar->codec_id);
            AVCodecContext *codec_ctx = avcodec_alloc_context3(in_codec);
            codec_ctx->framerate = (AVRational){0,1};
            ret = avcodec_parameters_to_context(codec_ctx, in_stream->codecpar);
            if (ret < 0)
            {
                avformat_close_input(&ctx);
                avformat_free_context(oc);
                oc = NULL;
                return ;
            }

            codec_ctx->codec_tag = 0;
            if (oc->oformat->flags & AVFMT_GLOBALHEADER)
                codec_ctx->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;

            ret = avcodec_parameters_from_context(out_stream->codecpar, codec_ctx);
            if (ret < 0)
            {
                avformat_close_input(&ctx);
                avformat_free_context(oc);
                oc = NULL;
               
                return ;
            }
            out_stream->time_base = in_stream->time_base;
            avcodec_free_context(&codec_ctx);
        }
    }

	
		 //open output file 
		 if (oc == NULL){
			return EXIT_FAILURE;
		 }
	 

		AVDictionary *opts = NULL;
		av_dict_set(&opts, "movflags",  "frag_keyframe+empty_moov+omit_tfhd_offset+faststart+dash+frag_custom", 0);
		av_dict_set(&opts, "frag_duration", "0", 0);
		av_dict_set(&opts, "min_frag_duration", "0", 0);
		
		av_dump_format(oc, 0, "", 1);
		avformat_write_header(oc, &opts); 
		oc->oformat->flags |= AVFMT_TS_NONSTRICT;

		av_dict_free(&opts);

		int read_error_num = 0;
		int write_error_num = 0;
		int FirstKeyFrame = 0;

		AVPacket pkt; 

		end1 = clock();
		float res1 = (float)(end1 - start1)/CLOCKS_PER_SEC;


		printf("[send] while Start %.3f \n",res1); 
		while (1){
			 
				int out_index = -1;
				av_init_packet(&pkt); 
				pkt.data = NULL;
				pkt.size = 0;
				int nRecvPacket = av_read_frame(ctx, &pkt);

				if (pkt.stream_index == in_video_index)
					out_index = out_video_index;
				if (pkt.stream_index == in_audio_index)
					out_index = out_audio_index;
				if (out_index == -1)
				{
					av_packet_unref(&pkt);
					continue;
				}
				if (FirstKeyFrame==0 && (pkt.stream_index == in_video_index))
				{
					if (pkt.flags & AV_PKT_FLAG_KEY)
						FirstKeyFrame = 1;
					else
					{
						av_packet_unref(&pkt);
						continue;
					}
				}
				AVStream* in_stream = ctx->streams[pkt.stream_index];
				pkt.stream_index = out_index;
				AVStream* out_stream = oc->streams[out_index];
				pkt.flags |= AV_PKT_FLAG_KEY;
				pkt.pos = -1;

				ret = av_interleaved_write_frame(oc, &pkt);
				av_packet_unref(&pkt);
				if (vod_exit==1) {
						break;
				}
			}

		    av_write_trailer(oc); 
			avformat_free_context(oc); 
			av_free(pb_Buf);
		
	}
