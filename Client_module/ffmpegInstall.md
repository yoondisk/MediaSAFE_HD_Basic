-소스파일 : 받아온곳 주소

ffmpeg 

```
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releaes/ffmpeg-shapshot.tar.bz2
```

Yasm (ffmpeg 빌드 시 사용, 어셈블리 컴파일러)

```
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
```

NASM (코덱 설치에 이용되는 어셈블러)
```
wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.xz
```
각종 코덱

libx264
```
wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
```

libfdk-acc
```
wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
```

libopus
```
wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
```

libvpx
```
​wget http://github.com/webmproject/libvpx/archive/v1.7.0/libvpx-1.7.0.tar.gz
```

libmp3lame
```
​wget -O lame-3.100.tar.gz https://downloads.sourceforge.net/project/lame/lame/3.100/lame3.100.tar.gz
```
​
​
-추가적인 설치 파일 라이브러리등 :

의존 관계가 있는 라이브러리들
```
  autoconf 
  
  automake 
  
  build-essential 
  
  cmake 
  
  git-core 
  
  libass-dev 
  
  libfreetype6-dev 
  
  libgnutls28-dev 
  
  libsdl2-dev 
  
  libtool 
  
  libva-dev 
  
  libvdpau-dev 
  
  libvorbis-dev 
  
  libxcb1-dev 
  
  libxcb-shm0-dev 
  
  libxcb-xfixes0-dev 
  
  pkg-config 
  
  texinfo 
  
  wget 
  
  yasm 
  
  zlib1g-dev
 ```
​
​
-컴파일 위치 : /root/ffmpeg_sources/ffmpeg
​
 
-컴파일 옵션 : 

​--disable-gpl --disable-version3 --enable-libtesseract --enable-fontconfig --enable-gnutls --enable-libass --enable-libbluray 
--enable-libbs2b --enable-libcaca --enable-libflite --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm
--enable-libilbc --enable-libmodplug --enable-libmp3lame --enable-libmysofa --enable-libopenh264 --enable-libopenjpeg --enable-libopus
--enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libtheora --enable-libtwolame --enable-libvorbis --enable-libvpx 
--enable-libwebp --enable-libzimg --enable-libzvbi  --enable-nvenc --enable-nvdec
​
​
-> gpl
-> version3



disable로 빌드 진행 중... 추후 수정 예정
