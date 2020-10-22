<?php
  $down = $_SERVER['DOCUMENT_ROOT']."/MediaSafe.deb";
  $filesize = filesize($down);
  if(file_exists($down)){
    header("Content-Type: application/x-debian-package");
    header("Content-Disposition: attachment;filename=MediaSafe.deb");
    header("Content-Transfer-Encoding: binary");
    header("Content-Length: ".filesize($down));
    header("Cache-Control: cache,must-revalidate");
    header("Pragma:no-cache");
    header("Expires:0");
    if(is_file($down)){
        $fp = fopen($down,"r");
        while(!feof($fp)){
          $buf = fread($fp,8096);
          $read = strlen($buf);
          print($buf);
          flush();
        }
        fclose($fp);
    }
  } else{
    ?><script>alert("존재하지 않는 파일입니다.")</script><?php
  }
?>