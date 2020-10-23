# MediaSAFE_HD_Basic
개방형OS(Operating System-운영체제) PC에 설치 후 서비스 이용이 가능한 Digital Rights Management (디지털 저작권 관리, 이하 DRM) 플레이어 플랫폼.

## 설계
- 개방형OS에 사용된 커널 버전(데미안 10.X) 분석
- 개방형OS에 이용 가능한 SEED 128,256bit 암호화 및 복호화 기법 분석
- 개방형OS에서 사용 가능한 영상 스트리밍 기법 분석
- 개방형OS에서 동영상 콘텐츠 저작권 관리툴 적용(웹 기반)

## 시스템 구성도 및 사용 도구
<div width="100%" style="text-align:center;">
  <img src="https://user-images.githubusercontent.com/65989325/90458676-0109e580-e13a-11ea-8145-5eb37c2e6891.png">  
</ div >

*&#35;VOD Server&#35;*<br>Windows IIS Server<br><br>
*&#35;User Os&#35;*<br>Linux debian 4.19.0-5 <br><br>
*&#35;Web Browser#35;*<br>Chromium based browser <br><br>

## OpenOS 각 데미안 커널 버전
- **Tmax** / 데비안 - 4.19 0-6amd64
- **Hamonica** / 데비안 -  4.15 0-54-gener
- **Gooroom** / 데비안 - 4.19 0-8-amd


## OpenOS별 지원 브라우저 및 버전
- **Tmax** - Chrome-81.0.4 / Whale-2.7.98
- **Hamonica** - Chrome-81.0.4 / Whale-2.6.88 / FireFox-70.0.1
- **Gooroom** - Chrome-81.0.4


## OpenOS 설치안내
- [TmaxOS - 설치 가이드](https://user-images.githubusercontent.com/65989186/83239666-3c4be680-a1d3-11ea-89f8-62a266a6faba.png)
- [HamosicaOS - 설치 가이드](https://user-images.githubusercontent.com/65989186/83501930-d1b0e880-a4fb-11ea-9976-90e9fa51c616.png)
<br><br>

## 목표
 ◦ 개방형OS(Operating System-운영체제) PC에 설치 후 서비스 이용이 가능한 Digital Rights Management (디지털 저작권 관리, 이하 DRM) 플레이어 플랫폼.<br>
 ◦ 개방형OS PC에 설치형 DRM 플레이어를 개발<br>
 ◦ 개방형OS DRM 플레이어 세부 기능<br>
- HTTP, RTSP 전송 프로토콜 지원 기능
- 생방송 영상 중계 URL 암호화 기능
- 배속기능 및 임의 위치 재생 기능
- 콘텐츠 서버와 네트워크 패킹 암호화 통신 기능
- 해상도 변경 기능 및 볼륨 조절 기능

## 효과
 ◦개방형OS를 이용하는 PC및 클라우드 환경에서, <br>
  생방송, 영상 콘텐츠 서비스시에 콘텐츠의 안전한 보호와 불법적 유출을 방지.  

## <a href="https://github.com/yoondisk/MediaSAFE_HD_Basic/blob/master/LICENSE.md">LICENSE</a>
MediaSAFE_HD_Basic is <a href="https://github.com/yoondisk/MediaSAFE_HD_Basic/blob/master/LICENSE.md">licensed</a> under the GPL, Version 2.0.

## 참여방법
<a href="https://github.com/yoondisk/MediaSAFE_HD_Basic/blob/master/CONTRIBUTING.md">CONTRIBUTING.md</a>
.
