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
	//mp4 drm
	$org_rtsp_url=$reff."|http://openosmp4.yoondisk.co.kr/test1_1080.mp4";
	$encstring = encrypt($g_bszIV, $g_bszUser_key, $org_rtsp_url).".mp4";
}

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
	body {font-size: 14px;}
</style>
<link href="css/video-js.css" rel="stylesheet">
<script src="https://code.jquery.com/jquery-2.2.1.min.js"></script>

<body style="padding:0px; height:100%;">
<video  id='YoonVideo'  class="video-js vjs-default-skin vjs-big-play-button vjs-big-play-centered" width="800" height="450" controls  preload="none" >
</video>

<textarea id="info" style="margin: 0px; height: 200px; width: 800px; overflow: scroll; background-color: #F6F7F8;" ></textarea>

<!-- JS code -->
<script src="js/video.js"></script>
<script src="js/util.js"></script>

<script>
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
		log_("Ready");
    });
</script>

