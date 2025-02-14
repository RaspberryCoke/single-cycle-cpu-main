#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)
static unsigned long int next = 1;

int rand(void) {
  // RAND_MAX assumed to be 32767
  next = next * 1103515245 + 12345;
  return (unsigned int)(next/65536) % 32768;
}

void srand(unsigned int seed) {
  next = seed;
}

int abs(int x) {
  return (x < 0 ? -x : x);
}

int atoi(const char* nptr) {
  int x = 0;
  while (*nptr == ' ') { nptr ++; }
  while (*nptr >= '0' && *nptr <= '9') {
    x = x * 10 + *nptr - '0';
    nptr ++;
  }
  return x;
}
// On native, malloc() will be called during initializaion of C runtime.
// Therefore do not call panic() here, else it will yield a dead recursion:
//   panic() -> putchar() -> (glibc) -> malloc() -> panic()
static void *addr = NULL; //addr初始化的值需要在编译时就知道
void *malloc(size_t size) {
  //如果这两个宏ISA_NATIVE和NATIVE_USE_KLIB都被定义了，那么条件为假
  #if !(defined(__ISA_NATIVE__) && defined(__NATIVE_USE_KLIB__))
    if(size == 0)       return NULL;
    if(addr == NULL)    addr = heap.start;
    addr = (void *)((uint8_t*)addr + size); 
    return addr;
  #else
    panic("not implement");
    return NULL;
  #endif
}

void free(void *ptr) {
  //do nothing
}

#endif
