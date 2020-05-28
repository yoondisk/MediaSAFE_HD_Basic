# Server_DLL

## 개발 목적
Vod Server 에서 요청받은 영상 파일을 File 암호화를 통해 Client의 Application으로 전달 하기 위한 DLL의 개발을 목적으로 한다.

## 개발 내용
VOD 영상 (mp4) 형태의 파일을 SEED 암호화를 통해 Client Application으로 암호화 한 뒤 전달함

## 참고자료
 - 개념 : https://winapp81.tistory.com/48
 - 암호화 : Client data push Seed 128 cbc data encrypt decrypt
 - 개발도구 : visaul studio vc++ 10
