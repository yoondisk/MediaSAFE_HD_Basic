<?php

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
	//$org_rtsp_url="http://openos.yoondisk.co.kr/test1_1080.mp4";

	//mp4 drm
	$org_rtsp_url=$reff."|http://openosmp4.yoondisk.co.kr/test1_1080.mp4";
	
	$encstring = encrypt($g_bszIV, $g_bszUser_key, $org_rtsp_url).".mp4";
}

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<meta name="viewport" content="width=639px, initial-scale=1.0">
<link href="css/video-js.css?<?=time()?>" rel="stylesheet">

<script src="https://code.jquery.com/jquery-2.2.1.min.js"></script>
<script type="text/javascript" src="/js/socket.io.js?v=20180412"></script>

<body style="padding:0px; height:100%;">
<div class="media_screen" style="width: 639px;">
	<video  id='YoonVideo' oncontextmenu="return false;" class="video-js vjs-default-skin vjs-big-play-button vjs-big-play-centered" width="639" height="400" data-setup='{ "controls": true }' preload="none" >
	</video>
	<!-- 자막칸 : S-->
	<div style="height:8px;background:#000"> </div>
	<div class="video_subtitle_box" style="height: 48px; position: relative; overflow: hidden;display: none;">
		
	</div>
	<!-- 자막칸 : E-->
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

	<textarea id="info" style="margin: 0px; height: 200px; width: 100%; overflow: scroll; background-color: #F6F7F8;" ></textarea>

</div>


<!-- JS code -->
<script src="js/video.js?<?=time()?>"></script>
<script src="js/util.js?<?=time()?>"></script>

<script>

</script>


<script>
	var min_bar_height=41;
	var rtsp_url='<?=$encstring?>';

	var timestamp = new Date().getTime();
	
	var player = videojs('YoonVideo');
	player.src([
		 { type: "video/mp4", src: 'http://192.168.0.34:9000/'+rtsp_url+'?'+timestamp },
	]);	
	
	player.on('waiting', function() {
		log_("Waiting");
	});

	player.on('pause', function() {
		log_("Pause");
	});

	player.on("play", function() {
		log_("Play");
	});

	player.on('playing', function() {
		log_("Playing");
	});

	player.on("ready",function(){
		$('.vjs-poster').html('<img src="/images/img_view.jpg" width="100%" height="100%">');
		$('.vjs-poster').hide();
		$('.vjs-poster').removeClass('vjs-hidden');
		$('.vjs-control-bar').attr('style','opacity: 1!important;');

		if (rtsp_url.indexOf('.rtsp')>0){
			min_bar_height=33;
			$('.vjs-current-time').attr('style','display: block !important');
			$('.vjs-prev-control').hide();
			$('.vjs-next-control').hide();
			$('.vjs-book-control').hide();
			$('.vjs-speed-control').hide();
			$('.vjs-dp-control').css("right","30px");
			$('.vjs-tech').css("height","calc(100% - "+min_bar_height+"px)");
			
			videojs.players['YoonVideo'].controlBar.remainingTimeDisplay.hide();
			videojs.players['YoonVideo'].controlBar.progressControl.hide();

		}else{
			$('.vjs-current-time').attr('style','display: block !important');
			$('.vjs-time-divider').attr('style','display: block !important');
			$('.vjs-duration').attr('style','display: block !important');
			
			videojs.players['YoonVideo'].controlBar.remainingTimeDisplay.hide();
			videojs.players['YoonVideo'].controlBar.progressControl.show();
			
		}
		log_("Ready");
    });

	player.on('fullscreenchange', function() {
		if (player.isFullscreen_){
			$('.vjs-control-bar').attr('style','');
			$('.vjs-tech').css("height","100%");
			$('.pvid_box').css("top","-30px");
			$('.bookmark_box').css("top","-68px");
			$('.speed_box').css("top","-105px");
		}else{
			$('.vjs-control-bar').attr('style','opacity: 1!important;');
			$('.vjs-tech').css("height","calc(100% - "+min_bar_height+"px)");
			$('.pvid_box').css("top","0px");
			$('.bookmark_box').css("top","0px");
			$('.speed_box').css("top","0px");
		}
		  console.log(player.isFullscreen_);
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
	
	$('.vjs-control-bar').find(".ulBookmarkBox .aBookMark").each(function(index) {
		var objThis = this;
		var intThisIndex = index;
		var intBookmarkValue = getCookie_str(strBookmarkName + intThisIndex);
		if (intBookmarkValue.length > 0) {
			setMediaBookMarkStyle($('.vjs-control-bar'), null, strBookmarkName, objThis, intThisIndex, intBookmarkValue);
		}
		else {
			$(objThis).click(function() {
				intBookmarkValue = player.currentTime();
				setCookie_str(strBookmarkName + intThisIndex, intBookmarkValue, 365);
				setMediaBookMarkStyle($('.vjs-control-bar'), null, strBookmarkName, objThis, intThisIndex, intBookmarkValue);
			});
		}
	});
	/* 북마크 */

	/* 영상보기/오디오듣기 */
	$('.od_bt').click(function(){
		
			if ($(this).attr('title')=='오디오듣기'){
				$(this).attr('title','영상 보기');
				$(this).find('img').attr('alt','영상 보기');
				$(this).find('img').attr('src','/images/od_01.png');
				$('.vjs-poster').show();
			}else{
				$(this).attr('title','오디오듣기');
				$(this).find('img').attr('alt','오디오듣기');
				$(this).find('img').attr('src','/images/od_1.png');
				$('.vjs-poster').hide();
			}
		    
	})       
	/* 영상보기/오디오듣기 */

	/* 축소/확대 */
	$('.aBtnZoom').click(function(){
		if ($(this).attr('title')=='축소'){
			$(this).attr('title','확대');
			$(this).find('img').attr('alt','확대');
			$(this).find('img').attr('src','/images/btn_video_zoomin.png');
			$('#YoonVideo').css('width','426px');
			$('#YoonVideo').css('height','281px');
			$('.media_screen').css('width','426px');
			$('.media_screen').css('height','281px');
			
		}else{
			$(this).attr('title','축소');
			$(this).find('img').attr('alt','축소');
			$(this).find('img').attr('src','/images/btn_video_zoomout.png');
			$('#YoonVideo').css('width','639px');
			$('#YoonVideo').css('height','400px');
			$('.media_screen').css('width','639px');
			$('.media_screen').css('height','400px');
		}

	})
	/* 축소/확대 */



	/* 전체화면 */
	$('.aBtnZoomFull').click(function(){
		player.requestFullscreen();
	})
	/* 전체화면 */
	
	/*
	   자막보기
	*/
	var nline=0;
	var smi_ok=0;
	var socket;

	function smi_mode(){
			if($(".video_subtitle_box").css("display") != "none"){
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
			function smi_on(){
				 smi_ok=1;nline=0;
				  $('.video_subtitle_box').html("");
				  $('.video_subtitle_box').show();
				  socket = io("ws://smi.webcast.go.kr/NATV"); //1
				  socket.on('receive message', function(msg){ //3
					var tt = setTimeout(function(){showCaption(msg)},100);
					function showCaption(aaa){
						if (nline<4){nline++;}
						var rtop=((nline-1)*16);
						$('.video_subtitle_box').append('<div class="video_subtitle_area" rel="" style="width:100%;position: absolute;top:'+rtop+'px" id="smi0">'+aaa+'</div>');
						if (nline==4){
							$(".video_subtitle_area").each(function() {
								var nscroll_top=parseInt($(this).css('top'))-16;
								if (nscroll_top<-16){
									$(this).remove();
								}else{
									$(this).stop().animate({top: nscroll_top+"px"},200);
								}
							});
						}
						try{
							smi_send(aaa);
						}catch (e){

						}

						if(smiTimer!=null){
							clearTimeout(smiTimer);
						}
						smiTimer=setTimeout(function(){
							sminull();
						},10000);
					}
				  });
				  socket.on('change name', function(name){ //4
					$('#name').val(name);
				  });
			}
			function smi_off(){
				  smi_ok=0;
				  socket.disconnect();
				   $('.video_subtitle_box').hide();
			}
			function sminull(){
				$('.video_subtitle_box').html("");
				nline=0;
			}

</script>