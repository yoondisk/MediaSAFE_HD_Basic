<?php
if ($_GET[rtsp]==1) {
	include "live_player.php";
}else{
	include "vod_player.php";
}
?>