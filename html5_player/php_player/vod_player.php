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

<script src="https://code.jquery.com/jquery-2.2.1.min.js"></script>

<body style="padding:0px; height:100%;">
<div class="media_screen" style="width: 639px;">
	<video  id='YoonVideo' oncontextmenu="return false;" class="video-js vjs-default-skin vjs-big-play-button vjs-big-play-centered" width="639" height="400" data-setup='{ "controls": true }' preload="none" >
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
	<!-- VOD 자막 레이어 : S-->
    <div class="ls_area"  style='width:100%;display:none'>
      <!-- 1.그림자 : S-->
      <!--<div class="ls_shadow">
      </div>-->
      <!-- 1.그림자 : E-->
      <!-- 2.자막 컨텐츠 : S-->
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
      
      <!-- 2.자막 컨텐츠 : E-->
    </div>
    <!-- VOD 자막 레이어 : E-->
	</span>

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


	/* VOD 자막 관련 업데이트 */
	var flag_d=0;
	var smi_timex;
	player.on('timeupdate', function() {
					
				if (smi_ok==1){

					 var obj_=new Array(10);
					 obj_[1]=player.currentTime();

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
			/* 자막읽어오고 자막창 열기 */
			smi_mode();
			get_json(0,0,0,0,0);
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
				 $.getJSON('test1_1080.json?no='+a+'&mc='+b+'&ct1='+c+'&ct2='+d+'&ct3='+e+'&v=20200524', function(data) {
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
					  player.currentTime(st);
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
				  player.currentTime(st);
				}
			}
</script>