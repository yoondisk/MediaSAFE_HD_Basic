<?php
header('Content-Type: text/html; charset=UTF-8');
/*
 암화화 key,iv 선언.
*/
$g_bszUser_key = "88,E3,4F,8F,08,17,79,F1,E9,F3,94,37,0A,D4,05,89";
$g_bszIV = "26,8D,66,A7,35,A8,1A,81,6F,BA,D9,FA,36,16,25,01";

require_once ('seed/KISA_SEED_CBC.php');
require_once ('seed/SEED_FUNCTION.php');



$reff=$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];

if ($_GET[rtsp]==1) {
	//rtsp
	$org_rtsp_url=$reff."|rtsp://openosmp4.yoondisk.co.kr/1080";
	$encstring = encrypt($g_bszIV, $g_bszUser_key, $org_rtsp_url).".rtsp";
}else{
	//mp4 nodrm
	//$org_rtsp_url="http://testvod2.yoondisk.com/test1_1080.mp4";

	//mp4 drm
	$org_rtsp_url=$reff."|http://openosmp4.yoondisk.co.kr/test1_1080.mp4";
	
	$encstring = encrypt($g_bszIV, $g_bszUser_key, $org_rtsp_url).".mp4";
}


?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<meta name="viewport" content="width=639px, initial-scale=1.0">
<script src="https://code.jquery.com/jquery-2.2.1.min.js"></script>
<link rel="stylesheet" href="css/plyr.css?v=<?=time()?>" />

<style>
/*동영상 자막*/
.ls_area{left:0; bottom:0; z-index:99; width:100%;position: relative;}
.ls_shadow{height:11px; background:url(../img/video/btn_subtitle_shadow.png?1) 0 100% repeat-x;}
.ls_c{background:#fff;}
.ls_c .ls_c_head{height:43px; position:relative;}
.ls_c .ls_c_head h3{padding-top:6px; font-size:13pt; border-top:1px solid #253c61;}
.ls_c .ls_c_search{position:absolute; right:16px; top:6px; font-size:0;}
.ls_c .ls_c_inp{vertical-align:top; height:26px; width:180px; border:1px solid #cacaca; font-size:12px;}
.ls_c .ls_c_body{padding-bottom: 10px;}
.ls_c .ls_c_textarea{border:1px solid #253c61; height:60px; overflow-y:scroll; padding:10px 12px;line-height: 1.0em;}
.ls_c .ls_subtittable {margin-bottom:9px; font-size:14px; table-layout:fixed; color:#666666;}
.ls_c .ls_subtittable .smicolor { color:#2c86c2;}
.ft_keyword{background:#55f05a; color:#000;}
.list_subtitle {display:block; background:#fff; border:1px solid #cacaca; overflow:hidden; height:38px; padding:4px;}
.list_subtitle.active{background:#ebebeb;}
.list_subtitle li{float:left;}
.list_subtitle .li_head{width:30px; height:35px; text-align:center; overflow:hidden; background:gray;margin-top:2px;}
.list_subtitle .li_head img{height:100%;}
.list_subtitle .li_name{width:100px; text-align:left;}
.list_subtitle .li_name h3{display:block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-size:14px; padding-left:5px; padding-top:5px;}
.list_subtitle .li_name p{display:block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-weight:normal; padding-left:5px; }
</style>

</head>
  <body> 
        <div id="Player_container" style="width: 639px;height: 400px;position:absolute;">
		  <div style='width:100%;height:0px;background:#000' id='player_install'></div>
          <video id="player" preload="none" autostart="false" width="639px"   >
		  	    <source src="" type="video/mp4">
          </video>		  
		  <div class="click_view_btn" style="width:100%;">
		<div class="left">
			<a href="javascript:void(0)" title="오디오듣기" class="od_bt od_1" id="aBtnAudioHearing"><img src="/images/od_1.png" alt="오디오듣기"></a>
		</div>
		<div class="right">
			<a href="javascript:smi_mode();" class="aBtnSubtitle" ><img id='smi_btn' src="/images/btn_video_subtitle.png" alt="자막보기"></a>
			<a href="javascript:void(0)" class="videoBig aBtnZoom" title="축소"><img src="/images/btn_video_zoomout.png" alt="축소"></a>
			<a href="javascript:void(0)" class="aBtnZoomFull" title="전체화면" style="display: inline;"><img src="/images/btn_video_full.png" alt="전체화면"></a>
		</div>
	</div>

	<span>
	<div style='padding:5px; width: 260px;position: absolute;z-index: 10000;left: 15px;top: 15px;font-size: 22px;color: #fde100;background-color:#000;opacity: 0.6;'>TC2(FPS):
	<span id='fps'>00.000</span>
	</div>
	<!-- VOD 자막 레이어 : S-->
    <div class="ls_area"  style='width:100%;display:none'>
      <!-- 자막 컨텐츠 : S-->
      <div class="ls_c">
        <div class="ls_c_head">
          <h3>자막서비스</h3>
          <div class="ls_c_search">
            
          </div>
        </div>
        <div class="ls_c_body">
          <div class="ls_c_textarea" tabindex="0" onfocusin="finx()" onfocusout="foutx()">
          </div>
        </div>
      </div>
      
      <!-- 자막 컨텐츠 : E-->
    </div>
    <!-- VOD 자막 레이어 : E-->
	</span>

	<textarea id="info" style="margin: 0px; height: 200px; width: 100%; overflow: scroll; background-color: #F6F7F8;" ></textarea>
  </div>
  
	<script src="js/plyr.js?v=<?=time()?>" ></script>
	<script src="js/util.js?v=<?=time()?>" ></script>

	<script>
	var controls =[
		'play-large', // The large play button in the center
		'rewind', // Rewind by the seek time (default 10 seconds)
		'play', // Play/pause playback
		'fast-forward', // Fast forward by the seek time (default 10 seconds)
		'progress', // The progress bar and scrubber for playback and buffering
		'current-time', // The current time of playback
		'duration', // The full duration of the media
		'vdp', // Settings Video Dp
		'vspeed', // Settings Video Rate
		'bookmark', // Setting Video Bookmark
		'volume', // Volume control
		'mute', // Toggle mute

	];
	
	var install_app_url="deb_down.php";
	
	var install_in="<table id='ppmsg' width=100% height=100%><tr><td style='text-align:center;vertical-align:middle'><font color='#ffffff'><b>설치된 플레이어를 연결하고 있습니다.<br></font>";
		install_in=install_in+"<br><font color=red> 잠시만 기다리세요.</font></td></tr></table>";

	var install=		"<table id='ppmsg' width=100% height=100%><tr><td style='text-align:center;vertical-align:middle'><font color='#ffffff'><b>플레이어가 설치되지 않았습니다. <br> 설치파일을 다운로드후 설치하세요.</font>";
		install=install+"<br><a href='"+install_app_url+"'><font color=red>MediaSafe.deb 다운로드</font></a></td></tr></table>";

	var install_update=		"<table id='ppmsg' width=100% height=100%><tr><td style='text-align:center;vertical-align:middle'><font color='#ffffff'><b>플레이어가 <font color='#ff0000'>업데이트</font> 되었습니다.<br> 실행파일을 다운로드후 설치하세요.</font>";
	install_update=install_update+"<br><a href='"+install_app_url+"'><font color=red>MediaSafe.deb 다운로드</font></a></td></tr></table>";

	var init_drm=0;
	var drm_ip='127.0.0.1:9000';
	var vod_type='video/mp4';

	var min_bar_height=41;
	var rtsp_url='<?=$encstring?>';

	var timestamp = new Date().getTime();

	var tc3=0;

	// TC4 : Seek End Time
	var seek_end_time=0;

	/*재생시간 비교*/
	var p_start = 0;
	var p_end = 0;
	var p_tot = 0;
	/*재생시간 비교*/
	
	var player;

	$( document ).ready(function() {
		var video = document.getElementById('player');
		var sources = video.getElementsByTagName('source');
		timestamp = new Date().getTime();
		sources[0].src ='http://'+drm_ip+'/'+rtsp_url+'?'+timestamp;
		if (navigator.userAgent.indexOf("Firefox") != -1 ) {
			video.load();
		}

		player = new Plyr('#player', { controls });
		if (rtsp_url.indexOf('.rtsp')>0){
					min_bar_height=8;
					$('#Player_container').attr('style','width: 639px;height: 392px;position:absolute;');
					$('.plyr__progress').attr('style','display: none !important');
					$('.plyr__control_rewind').attr('style','display: none !important');
					$('.plyr__control_play').attr('style','left:0px');
					$('.plyr__time--current').attr('style','left:38px');
					$('.plyr__control_vdp').attr('style','right:20px');
					$('.plyr__control--overlaid').removeAttr('style');
					
					
					$('.plyr__control_fast-forward').attr('style','display: none !important');
					$('.plyr__time--duration').attr('style','display: none !important');
					$('.plyr__control_vspeed').attr('style','display: none !important');
					$('.plyr__control_bookmark').attr('style','display: none !important');
					

					
		}
		player.on('ready', function(event){
				log_("Ready");
				 $(".plyr").prepend('<div class="progress__buffer"></div>');
				 $(".plyr").prepend('<div class="aposter"><img src="/images/img_view.jpg" width="100%" height="100%" ></div>');
 				 $('.plyr__controls').attr('style','opacity: 1!important;transform: translateY(0%)!important;');

				if (rtsp_url.indexOf('.rtsp')>0){
					$('.aposter').css("height","calc(100% - 33px)");

				}else{
					/* 자막읽어오고 자막창 열기 */
					smi_mode();
					get_json(0,0,0,0,0);
					
				}
	
		});
		player.on('waiting', function() {
				$('.progress__buffer').show();
				log_("Waiting");
		});

		player.on('pause', function() {
				log_("Pause");
		});

		/* TC4 Seek 시작.*/
		player.on('seeking', function() {
			log_("SeekStart");
		});

		/* TC4 Seek 종료.*/
		player.on('seeked', function() {
			log_("SeekEnd");
			seek_end_time=new Date().getTime(); /* SeekEnd 시간 기록.*/
			flag_d=-1; /* 자막 Sync 초기화 */
		});
		/* TC4 Seek 종료.*/

		player.on('fullscreenchange', function() {
				if (player.fullscreen){
					$('#player').removeAttr('style');
				}
		});
		player.on("play", function() {

			log_("Play");
			if (init_drm==0){
					init_drm=1;
					setTimeout(drm_ck, 1000);
			}
			//동영상 재생버튼 누른 시간
			p_start = new Date().getTime();
		});

		/* fps 산출 */
			var fps_init=0;
			var guessCount = 0;
			var lastSeenTime = -1;
			var durationCumul = 0;

			function guessFrameRate()  {
					var currentVideoTime = 1000 * player.currentTime;		
					/* seek 했을경우 초기화*/
					if (lastSeenTime!=-1 && player.currentTime>0 && ( (lastSeenTime-currentVideoTime)/1000>1 || (currentVideoTime-lastSeenTime)/1000>1)){
						guessCount=0;  lastSeenTime=-1;  durationCumul=0;
					}
					/* seek 했을경우 초기화*/
					var dt = currentVideoTime - lastSeenTime;
					lastSeenTime = currentVideoTime;
					if (dt == 0) return;
					if (guessCount++ == 0) return;
					durationCumul += dt;

					$('#fps').html( Math.ceil( durationCumul/guessCount*1000 ) / 1000 );			
			}
		/* fps 산출 */


		player.on('playing', function() {
			log_("Playing");
			$('.progress__buffer').hide();
			$('.plyr__control--overlaid').attr('style','display:none !important');
			//동영상 실제 시작시간
			p_end = new Date().getTime();
			p_tot = (p_end - p_start)/1000;
			if (tc3==0){
				tc3=1;
				log_("TC3:" + p_tot);
			}
			//동영상 실제 시작시간
		
			/* fps 산출 측정 */
				if (fps_init==0){
					fps_init=1;

					// 인코딩된 원본 동영상 fps
					var encoding_fps=29.97;
					
					// 1초에 원본동영상 fps 만큼 루프시작.
					var guessingInterval = setInterval(guessFrameRate, 1000 / encoding_fps);
				}
			/* fps 산출 측정 */
		});
		/*
		
		*/
		$('.plyr__controls').mouseleave(function() { 
			$('.speed_box').hide();$('.pvid_box').hide();$('.bookmark_box').hide();
		});

		$('.plyr__volume').hover(function(){
			$('.plyr-volcss').attr('style','display:block !important');
			if (!player.muted){
				var vvalue=$('.plyr-volcss').attr('aria-valuenow');
				$('.plyr-volcss').attr('style','display:block !important;--value:'+vvalue+'%');
			}

		}, function() {
			$('.plyr-volcss').attr('style','display:none !important');
		});

	/* 화질변경 */
	$('.pvid').click(function(){
	  $('.pvid_box').show();
	});

	$(".pvid_box").mouseleave(function() {
		$('.pvid_box').hide();
	});
	$(".pvid_box li").click(function(){
		var DpValue = $(this).find('a').text();
		$('.pvid a').html(DpValue);
		$('.pvid_box').hide();
	})
	/* 화질변경 */

	/* 배속변경 */
	$('.speed').click(function(){
	  $('.speed_box').show();
	});

	$(".speed_box").mouseleave(function() {
		$('.speed_box').hide();
	});
	$(".speed_box li").click(function(){
		var SpeedValue = $(this).find('a').text();
		$('.speed a').html(SpeedValue+"x");
		player.playbackRate(parseFloat(SpeedValue));
		$('.speed_box').hide();
	})
	/* 배속변경 */

	/* 북마크 */
	var strBookmarkName="YoonMedia1";
	$('.open_bookmark').click(function(){
	  $('.bookmark_box').show();
	});

	$(".bookmark_box").mouseleave(function() {
		$('.bookmark_box').hide();
	});
	
	$('.plyr__controls').find(".ulBookmarkBox .aBookMark").each(function(index) {
		var objThis = this;
		var intThisIndex = index;
		var intBookmarkValue = getCookie_str(strBookmarkName + intThisIndex);
		if (intBookmarkValue.length > 0) {
			setMediaBookMarkStyle($('.plyr__controls'), null, strBookmarkName, objThis, intThisIndex, intBookmarkValue);
		}
		else {
			$(objThis).click(function() {
				intBookmarkValue = player.currentTime;
				setCookie_str(strBookmarkName + intThisIndex, intBookmarkValue, 365);
				setMediaBookMarkStyle($('.plyr__controls'), null, strBookmarkName, objThis, intThisIndex, intBookmarkValue);
			});
		}
	});
	/* 북마크 */


			/* VOD 자막 관련 업데이트 */
	var flag_d=0;
	var smi_timex;
	player.on('timeupdate', function() {
				if (smi_ok==1){

					 var obj_=new Array(10);
					 obj_[1]=player.currentTime;

					$(".ls_subtittable").each(function() {
						var st=parseInt($(this).attr('start'))-1;
						var et=parseInt($(this).attr('end'))-1;
						var tt=parseInt($(this).attr('topx'))-70+20;
						var smid=$(this).attr('id');
						
						if (parseInt(st)<=parseInt(obj_[1]) && parseInt(et)>=parseInt(obj_[1])  ){
							if (flag_d!=parseInt(st)){
								$('.ls_subtittable').css('color','#666666');
								if (smi_timex!=null){
									clearTimeout(smi_timex);
									smi_timex=null;
								}
								
								try{smi_send($(this).html());}catch (e){}
								/*TC4 Start*/
								if (seek_end_time>0){
									var smi_res_time = (new Date().getTime() - seek_end_time)/1000;
									seek_end_time=0;
									log_("TC4:" + smi_res_time);
								}
								/*TC4 End*/
								
								/*자막 Sync 색깔 표시*/
								$(this).css('color','#2c86c2');
								smid=parseInt(smid.substring(2))+1;
								var sx_end=parseInt(parseInt($('#sm'+smid).attr('start'))-et);
								var sx_end_d=parseInt(et-st)+1;
								if (scroll_delta==0){
									$('.ls_c_textarea').animate({scrollTop:tt}, 400);
								}

								if (sx_end>1){
									smi_timex=setTimeout(function(){
										try{smi_send("");}catch (e){}
										$('.ls_subtittable').css('color','#666666');
									},sx_end_d*1000);
								}
								
								flag_d=parseInt(st);
							}
							return false;
						}
						if (parseInt(st)>=parseInt(obj_[1])+10){
							return false;
						}
					});
				 }
	});

	  // player install check
		function drm_ck(){

			$.getJSON('http://'+drm_ip+'/.info_mp4?callback=?',function(data) {
				if (init_drm==4){
					// Player Install Ok
					$('#player_install').css('height','0px');
					$('#player_install').css('width','0px');
					$('.plyr').css("display","block");
					
					timestamp = new Date().getTime();
					player.source = {
					  type: 'video',
					  title: 'Example title',
					  sources: [{
						  src: 'http://'+drm_ip+'/'+rtsp_url+'?'+timestamp,
						  type: 'video/mp4'
					  }
					]
				   };

					player.play();
				}
				if (init_drm!=3){
					init_drm=2;
				}
			},'text')
			.done(function(data) {
				if (init_drm!=3){
					setTimeout(drm_ck, 2000);
				}
			})
			.fail(function(data) {
				if (init_drm==1 || init_drm==4){
					init_drm=4;
					var vheight=$('#container').height();
					$('#player_install').css('height','100%');
					$('#player_install').css('width','100%');
					$('#player_install').html(install);
					$('.plyr').css("display","none");
					try{ document.getElementsByTagName("video")[0].src=''; }catch (e){  }
					setTimeout(drm_ck, 2000);
				}else{
					player.pause();
					player.src('');
				}
			})
			.always(function(data) {
			});
		}
	// player install check

	});
	
	
	/* 영상보기/오디오듣기 */
	$('.od_bt').click(function(){
		
			if ($(this).attr('title')=='오디오듣기'){
				$(this).attr('title','영상 보기');
				$(this).find('img').attr('alt','영상 보기');
				$(this).find('img').attr('src','/images/od_01.png');
				$('.aposter').show();
			}else{
				$(this).attr('title','오디오듣기');
				$(this).find('img').attr('alt','오디오듣기');
				$(this).find('img').attr('src','/images/od_1.png');
				$('.aposter').hide();
			}
		    
	})       
	/* 영상보기/오디오듣기 */

	/* 축소/확대 */
	$('.aBtnZoom').click(function(){
		if ($(this).attr('title')=='축소'){
			$(this).attr('title','확대');
			$(this).find('img').attr('alt','확대');
			$(this).find('img').attr('src','/images/btn_video_zoomin.png');
			$('#player').css('width','426px');
			$('#Player_container').css('width','426px');
			$('#Player_container').css('height',281-min_bar_height+'px');
			
		}else{
			$(this).attr('title','축소');
			$(this).find('img').attr('alt','축소');
			$(this).find('img').attr('src','/images/btn_video_zoomout.png');
			$('#player').css('width','639px');
			$('#Player_container').css('width','639px');
			$('#Player_container').css('height',400-min_bar_height+'px');
		}

	})
	/* 축소/확대 */



	/* 전체화면 */
	$('.aBtnZoomFull').click(function(){
		player.fullscreen.enter();
	})
	/* 전체화면 */
	
	/*
	   자막보기
	*/
	var nline=0;
	var smi_ok=0;

	function smi_mode(){
			if($(".ls_area").css("display") != "none"){
				smi_off();
				$('#smi_btn').attr('src',"/images/btn_video_subtitle.png");
				$('#smi_btn').attr('alt',"자막보기");
			}else{
				smi_on(); 
				$('#smi_btn').attr('src',"/images/btn_video_subtitle_close.png");
				$('#smi_btn').attr('alt',"자막닫기");
			}
	}

	var smiTimer=null;
	var test_smi=0;

	var nline=0;
	var smi_ok=0;
	var smi_load=0;
	var scroll_delta=0;
	var smi_line=0;
	var smi_init=1;

	var vod_qt = 0;

			function get_json(a,b,c,d,e){
			   if (smi_load==1 || smi_init==0){
				 return;
			   }
			   smi_load=1;
				 $('.ls_c_textarea').html('');
				 $.getJSON('json_1080.php?v=20200524', function(data) {
					var html = '';
					$.each(data, function(entryIndex, entry) {
					smi_line++;
					  html += '<div id="sm'+smi_line+'" class="ls_subtittable" start=' + entry.start +' end=' + entry.end +' topx=0>';
					  html +=  entry.cc ;
					  html += '</div>';
					});
					
				  $('.ls_c_textarea').html(html);

				  $(".ls_subtittable").each(function() {
					  $(this).attr("topx",$(this).position().top);
				  });
				  
				  $('.ls_subtittable').css( 'cursor', 'pointer' );
				  
				  $('.ls_subtittable').click(function(){
					var st=parseInt($(this).attr('start'))-1;
					  player.currentTime=st;
				  });
				  smi_ok=1;
			   });
			}

			function smi_on(){
			   smi_ok=1;
			   try{ smi_opt(1); }catch (e){}
			   
			   var switch_no;
			   var xx_no = "492952";
			   var xx_s_no = "0";
			   
			   if(xx_s_no != "0"){
				 switch_no = xx_s_no;
			   }else{
				 switch_no = xx_no;
			   } 
			   
			   get_json(switch_no,'10','21','380','08');

				$('.ls_area').show();
				$('#smi_btn').attr('src',"/images/btn_video_subtitle_close.png");
				$('#smi_btn').attr('alt',"자막닫기");
				$('.aBtnSubtitle').attr('title',"자막닫기");
			}

			function smi_off(){
				smi_ok=0;
				try{ smi_opt(0); }catch (e){}
				 $('.ls_area').hide();
				 $('#smi_btn').attr('src',"/images/btn_video_subtitle.png");
				 $('#smi_btn').attr('alt',"자막보기");
				 $('.aBtnSubtitle').attr('title',"자막보기");
				 $('#smi_result').hide();
				 $("#btn_smi_result_onoff").attr("src","/images/btn_smi_result_on.png");
			}

			function sminull(){
				$('.video_subtitle_box').html("");
				nline=0;
			}
			function finx(){
			  scroll_delta=1;
			}

			function foutx(){
			  flag_d=scroll_delta=0;
			}

			$(".ls_c_textarea").mouseover(function() {
			  scroll_delta=1;
			}).mouseout(function(){
			  flag_d=scroll_delta=0;
			}); 

			function smi_go(c_mc,c_ct1,c_ct2,c_ct3,c_cno,c_start){
				var st=parseInt(c_start);
				if (old_pmc!=0 && old_pmc!=c_cno){
				  smi_load=0;
				  get_json(c_cno,c_mc,c_ct1,c_ct2,c_ct3);
				  
				  if(c_ct2 >= '001' || c_ct2 == '001') {
					requestVod(c_mc,c_ct1,c_ct2,c_ct3,c_cno,1,0,0,0,0);
				  }else{
					requestVod2(c_mc,c_ct1,c_ct2,c_ct3,c_cno,1,0,0,0,0);
				  }
				  start_pos=st;
				  old_pmc=c_cno;
				  
				}else{
				  player.currentTime=st;
				}
			}


	</script>
  </body>
</html>
