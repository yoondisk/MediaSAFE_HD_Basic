# Client Module

<img src="https://user-images.githubusercontent.com/65989480/83115534-73ec5d00-a105-11ea-9c3d-0a434e52cb73.png"> 

* Visual Studio Code Linux C++ 사용
* 클라이언트에서 요청한 영상 URL을 복호화하여 VOD SERVER로 영상 호출, 전달 받은 암호화된 영상 정보를 복호화
* RTSP 호출시 FFMPEG 이용하여 HLS로 트랜스코딩 

<br>

## 참고자료
* Ffmpeg library 연결 방법(libavformat, libavcodec)<br>
  http://blog.daum.net/junek69/78<br>
  https://linuxmarine.tistory.com/22<br>
  https://gist.github.com/gautiermichelin/55e5d67c217bd216b9680a668bb47871<br>
  https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu<br>
  https://www.it-swarm.dev/ko/libraries/%EC%9A%B0%EB%B6%84%ED%88%AC%EC%97%90-ffmpeg%EC%9D%98-%EC%B5%9C%EC%8B%A0-%EA%B0%9C%EB%B0%9C-%EB%9D%BC%EC%9D%B4%EB%B8%8C%EB%9F%AC%EB%A6%AC%EB%A5%BC-%EC%96%B4%EB%96%BB%EA%B2%8C-%EC%84%A4%EC%B9%98%ED%95%A9%EB%8B%88%EA%B9%8C/961615929/ 
