#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h> 
#include <libavformat/avio.h>
#include <libavdevice/avdevice.h>

void rtsp_hls(char * url){
	 
	 // ffmpeg lib init
	 av_register_all(); 
	 avcodec_register_all(); 
	 avformat_network_init(); 


	 // Initialize
	 int vidx = 0, aidx = 0; // Video, Audio Index
	 AVFormatContext* ctx = avformat_alloc_context(); 
	 AVDictionary *dicts = NULL;
	 AVFormatContext* oc = NULL; 


	 const char *rtsp_url=url;

	 avformat_alloc_output_context2(&oc, NULL, "hls", "playlist.m3u8"); // apple hls. If you just want to segment file use "segment"
	 int rc = av_dict_set(&dicts, "rtsp_transport", "tcp", 0); // default udp. Set tcp interleaved mode
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

	 // get context
	 if (avformat_find_stream_info(ctx, NULL) < 0)
	 {
		return EXIT_FAILURE; 
	 } 

	 //search video stream , audio stream
	 for (int i = 0 ; i < ctx->nb_streams ; i++){ 
		 if (ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){ vidx = i; printf(" AVMEDIA_TYPE_VIDEO = %d  \n", i);}
		 if (ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO){ aidx = i; printf(" AVMEDIA_TYPE_AUDIO = %d  \n", i);} 
		 if (ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO || ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO){
		 /* Open decoder */
			int ret = avcodec_open2(ctx->streams[i]->codec,
				avcodec_find_decoder(ctx->streams[i]->codec->codec_id), NULL);

			av_log(NULL, AV_LOG_ERROR, "open decoder for stream #%u\n", i);
			if (ret < 0) {
				av_log(NULL, AV_LOG_ERROR, "Failed to open decoder for stream #%u\n", i);
				return ret;
			}
		  }
	}
	av_dump_format(ctx, 0,  rtsp_url, 0);
	
		 //open output file 
		 if (oc == NULL){
			return EXIT_FAILURE;
		 }

		 AVStream* vstream = NULL; 
		 AVStream* astream = NULL;

		 vstream = avformat_new_stream(oc, ctx->streams[vidx]->codec->codec); 
		 astream = avformat_new_stream(oc, ctx->streams[aidx]->codec->codec);

		 avcodec_copy_context(vstream->codec, ctx->streams[vidx]->codec); 
		 vstream->sample_aspect_ratio = ctx->streams[vidx]->codec->sample_aspect_ratio; 

		 avcodec_copy_context(astream->codec, ctx->streams[aidx]->codec); 

		 int cnt = 0; 

		// av_read_play(ctx); //play RTSP 

		 int ii = (1 << 4); // omit endlist
		 int jj = (1 << 1); // delete segment. 
		 // libavformat/hlsenc.c 's description shows that no longer available files will be deleted but it doesnt works as described.

		 av_opt_set(oc->priv_data, "hls_segment_filename", "file%04d.ts", AV_OPT_SEARCH_CHILDREN);
		 av_opt_set_int(oc->priv_data, "hls_list_size", 5, AV_OPT_SEARCH_CHILDREN);
		 av_opt_set_int(oc->priv_data, "hls_time", 2, AV_OPT_SEARCH_CHILDREN);
		 av_opt_set_int(oc->priv_data, "hls_flags", ii|jj, AV_OPT_SEARCH_CHILDREN);
		 
		 av_opt_set_int(oc->priv_data, "hls_enc",1, 0);

		 
		 av_opt_set(oc->priv_data, "hls_base_url", "http://192.168.0.34:8080/", 0);
		 
		 av_opt_set(oc->priv_data, "hls_enc_key_url", "http://192.168.0.34:8080/key.htm", AV_OPT_SEARCH_CHILDREN);
		 av_opt_set(oc->priv_data, "hls_enc_key", "1234567890123456", 0);
		 av_opt_set(oc->priv_data, "hls_enc_iv", "1234567890123456", 0);

		avformat_write_header(oc, NULL); 
		
	
		int ret;
		int got_frame=0;
		enum AVMediaType type;
		AVFrame *frame = av_frame_alloc();
		static a_total_duration = 0;
        
		
		while (1){
			 
				AVPacket packet; 
				av_init_packet(&packet); 
				int nRecvPacket = av_read_frame(ctx, &packet);
				type = ctx->streams[packet.stream_index]->codec->codec_type;
			
				 
				AVRational time_base = oc->streams[packet.stream_index]->time_base;
				
				if (type == AVMEDIA_TYPE_VIDEO){
					 ret= avcodec_decode_video2(ctx->streams[packet.stream_index]->codec, frame,&got_frame, &packet);
				}else{
					 ret= avcodec_decode_audio4(ctx->streams[packet.stream_index]->codec, frame,&got_frame, &packet);
				}

				if (got_frame) {
					frame->pts = frame->pkt_pts;
					if (type != AVMEDIA_TYPE_VIDEO){
							packet.dts=packet.pts  = a_total_duration;
							a_total_duration += av_rescale_q(frame->nb_samples, oc->streams[packet.stream_index]->codec->time_base, oc->streams[packet.stream_index]->time_base);
					}else{
							//cnt++;
							//packet.dts=packet.pts  = a_total_duration;
							//packet.dts=packet.pts  = frame->pts;
							//packet.dts=packet.pts;
					}

					 // generally, dts is same as pts. it only differ when the stream has b-frame
					 ret = av_interleaved_write_frame(oc, &packet);  //av_write_frame(oc,&packet); 
					 /*
						file to memory
						https://ko.programqa.com/question/59938265/
					 */
					 av_packet_unref(&packet); 
				
					 if (cnt > 30000) {
						//break;
					 }
				}
			 
			}

		    av_frame_free(&frame);

		    av_read_pause(ctx); 
			av_write_trailer(oc); 
			avformat_free_context(oc); 
			av_dict_free(&dicts);

			return (EXIT_SUCCESS); 
		
	}
