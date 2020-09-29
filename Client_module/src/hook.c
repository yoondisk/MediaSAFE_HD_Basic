#define _GNU_SOURCE
#include <gdk-pixbuf/gdk-pixbuf.h>
#include <stdio.h>
#include <dlfcn.h>

/*
gcc -shared -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/lib/x86_64-linux-gnu/glib-2.0/include/ -fPIC -ldl -o hook.so hook.c

*/
// 진자 printf가 존재하는 메모리 주소를 저장하고 있다.
guchar * (*gdk_pixbuf_get_pixels_real)(const GdkPixbuf *) = NULL;

// 라이브러리가 로드될 때 실행된다.
void __attribute__((constructor)) init_hooking()
{
    // 진짜 printf가 존재하는 메모리 주소를 가져온다.
    gdk_pixbuf_get_pixels_real = dlsym(RTLD_NEXT, "gdk_pixbuf_get_pixels");
    fprintf (stderr, "===real printf is at %p\n", gdk_pixbuf_get_pixels);
}

guchar *gdk_pixbuf_get_pixels (const GdkPixbuf *pixbuf){
	fprintf (stderr, "=================== gdk_pixbuf_get_pixels_real ==========================\r\n");
	printf("=================== gdk_pixbuf_get_pixels_real ==========================\r\n");
 
 return NULL;
 return gdk_pixbuf_get_pixels_real(pixbuf);



}
/*
void *memcpy(void *dest, const void *src, size_t count) {
        char* dst8 = (char*)dest;
        char* src8 = (char*)src;
 
        while (count--) {
            *dst8++ = *src8++;
        }
 printf("H4ck : memcpy[%x][%s]\r\n",dest,src);
        return dest;
}
*/