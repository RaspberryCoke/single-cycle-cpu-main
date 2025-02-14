#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>
#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

void*
memset(void *s, int c,size_t n){
  	unsigned char *dst = s;
	size_t k;
	if (!n) return s;
	dst[0] = c;
	dst[n-1] = c;
	if (n <= 2) return s;
	dst[1] = c;
	dst[2] = c;
	dst[n-2] = c;
	dst[n-3] = c;
	if (n <= 6) return s;
	dst[3] = c;
	dst[n-4] = c;
	if (n <= 8) return s;
	k = -(uintptr_t)dst & 3;
	dst += k;
	n -= k;
	n &= -4;
	for (; n; n--, dst++) *dst = c;
	return s;
}

void*
memcpy(void *dst, const void *src, size_t n){
	unsigned char *d = dst;
	const unsigned char *s = src;
	for (; n; n--) *d++ = *s++;
	return dst;
}


void*
memmove(void *dst, const void *src, size_t n){
	char *d = dst;
	const char *s = src;
	if (d==s) return d;
	if ((uintptr_t)s-(uintptr_t)d-n <= -2*n) return memcpy(d, s, n);
	if (d<s) {
    for (; n; n--) *d++ = *s++;
	} else {
		while (n) n--, d[n] = s[n];
	}
	return dst;
}

int    
memcmp(const void *s1,  const void *s2,  size_t n){
	const unsigned char *l=s1, *r=s2;
	for (; n && *l == *r; n--, l++, r++);
	return n ? *l-*r : 0;
}

size_t 
strlen(const char *s){
	const char *a = s;
	for (; *s; s++);
	return s-a;
}

char*
strcat(char *dst, const char *src){
	strcpy(dst + strlen(dst), src);
	return dst;
}

char*
strcpy(char *dst, const char *src){
	for (; (*dst=*src); src++, dst++);
	return dst;
}

char*
strncpy(char *dst, const char *src, size_t n){  
	for (; n && (*dst=*src); n--, src++, dst++);
	memset(dst, 0, n);
	return dst;
}

int
strcmp(const char *s1,  const char *s2){
	for (; *s1==*s2 && *s1; s1++, s2++);
	return *(unsigned char *)s1 - *(unsigned char *)s2;
}

int
strncmp(const char *s1,  const char *s2,  size_t n){
	const unsigned char *l=(void *)s1, *r=(void *)s2;
	if (!n--) return 0;
	for (; *l && *r && n && *l == *r ; l++, r++, n--);
	return *l - *r;
}
#endif