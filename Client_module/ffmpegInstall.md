# ffmpeg Install 


### lib install 

``` 
sudo apt-get install -y libbs2b-dev 
sudo apt-get install -y libcaca-dev 
sudo apt-get install -y flite-dev 
sudo apt-get install -y libgme-dev 
sudo apt-get install -y libgsm-dev 
sudo apt-get install -y libgsm1-dev 
sudo apt-get install libopenjp2-7-dev 
sudo apt-get install libsnappy-dev 
sudo apt-get install libsoxr-dev 
sudo apt-get install -y libspeex-dev 
sudo apt-get install -y libtesseract-dev 
sudo apt-get install -y libtheora-dev
sudo apt-get install -y libtwolame-dev 
sudo apt-get install -y libwebp-dev 
sudo apt-get install libzvbi-dev 
sudo apt-get install -y wget 
sudo apt-get install -y cmake 
``` 

### lib install 

```
git clone git://github.com/dekkers/libilbc.git 

cd libilbc/ 

cmake CMakeLists.txt 

make 

make install 

cp /usr/local/lib/libilbc*.* /usr/lib/x86_64-linux-gnu/. -R -f 
``` 

### Open h264 

``` 
git clone https://github.com/cisco/openh264 

cd openh264

git checkout v1.5.0 -b v1.5.0 

make && make install 
```

### ffmpeg 
- 컴파일 위치 : /root/ffmpeg_sources/ffmpeg 

- 컴파일 옵션 : 

--disable-static --enable-shared --disable-gpl --disable-version3 --enable-libtesseract --enable-fontconfig --enable-gnutls --enable-libass --enable-libbs2b --enable-libcaca --enable-libflite --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libilbc --enable-libmodplug --enable-libmp3lame --enable-libopenh264 --enable-libopenjpeg --enable-libopus --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libtheora --enable-libtwolame --enable-libvorbis --enable-libvpx --enable-libwebp  --enable-libzvbi

``` 
mkdir -p ~ / ffmpeg_sources ~ / bin 

./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" \
--disable-static \
--enable-shared \ 
--disable-gpl \
--disable-version3 \ 
--enable-libtesseract \ 
--enable-fontconfig \
--enable-gnutls \
--enable-libass \ 
--enable-libbs2b \ 
--enable-libcaca \
--enable-libflite \ 
--enable-libfreetype \ 
--enable-libfribidi \
--enable-libgme \ 
--enable-libgsm \ 
--enable-libilbc \ 
--enable-libmodplug \ 
--enable-libmp3lame \ 
--enable-libopenh264 \ 
--enable-libopenjpeg \ 
--enable-libopus \ 
--enable-libsnappy \ 
--enable-libsoxr \ 
--enable-libspeex \ 
--enable-libtheora \ 
--enable-libtwolame \ 
--enable-libvorbis \
--enable-libvpx \ 
--enable-libwebp  \ 
--enable-libzvbi 


make 

make install 
```
