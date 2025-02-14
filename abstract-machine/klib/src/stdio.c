#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

static int int_to_reversed_str(char *buf, int64_t num, int base);
static void reverse_str(char *str);

#define BUF_SIZE 1024
int printf(const char *fmt, ...) {
  char out[BUF_SIZE] = {};
  va_list ap;
  va_start(ap, fmt);
  int num = vsprintf(out, fmt, ap);
  va_end(ap);

  for(int i = 0; i < num; ++i){
    putch(out[i]);
  }
  return num;
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int num = vsprintf(out, fmt, ap);
  va_end(ap);
  return num;
}


int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

bool is_digit(char ch){
  return ch >= '0' && ch <= '9';
}
enum{
  ZEROPAD = 1,
  SIGN    = 2,
  PLUS    = 4,
  SPACE   = 8,
  LEFT    = 16,
  SPECIAL = 32,
};
void init_format(int *flags, int *width, int *base){
  *flags = 0;
  *width = 0;
  *base = 10;
}



int vsprintf(char *out, const char *fmt, va_list ap) {

    int out_len = 0;
    int flags = 0;
    int width = 0;
    int base  = 10; 
    while(*fmt != '\0'){
      init_format(&flags, &width, &base);
      if(*fmt != '%'){  
        out[out_len++] = *fmt; 
        fmt++;
        continue;
      }
      fmt++;
      int have_no_flag = 0;
      while(*fmt != '\0'){
        switch (*fmt) {
          case '-': flags |= LEFT;    break;  //左对齐
          case '+': flags |= PLUS;    break;  //始终显示符号，对于正数显示正号，对于负数显示负号
          case ' ': flags |= SPACE;   break;  //只在正数前面加上空格，负数前面仍然是负号
          case '#': flags |= SPECIAL; break;  //特殊格式化。在不同格式中，这个标志的行为有所不同
          case '0': flags |= ZEROPAD; break;  //0填充
          default : have_no_flag = 1;      break;
        }
        if(have_no_flag) break;
        fmt++;
      }
      if(is_digit(*fmt)){
        for(   ; *fmt != '\0' && is_digit(*fmt); fmt++){
              width = width * 10 + (*fmt - '0'); 
        }  
      }else if(*fmt == '*'){
        //暂时不处理
      }
      char str[BUF_SIZE] = {};
      switch (*fmt){
        case 's': strcpy(str, va_arg(ap, char *)); break;
        case 'c': char c = (char)va_arg(ap, int);
                  str[0] = c; str[1] = '\0'; break;
        case 'd': base = 10; break;
        case 'u': base = 10; break;
        case 'p': base = 16; break;
        case 'o': base =  8; break;
        case 'x': base = 16; break;
        default:  putstr("in[vsprintf]遇到了不支持的数据格式,请检查你的代码, 正确使用printf/vsprintf\n"); return -1;
      }
      //对于%s和%c已经处理过str，所以就不需要再处理了
      if(*fmt != 's' && *fmt != 'c'){
        int64_t num;
        if(*fmt == 'd')       num = (int64_t)            va_arg(ap,          int);
        else if(*fmt == 'p')  num = (int64_t)(uintptr_t) va_arg(ap,        void*);
        else                  num = (int64_t)            va_arg(ap, unsigned int);


        int str_len = int_to_reversed_str(str, num, base);
        //对于%d的正数，有一个plus
        if (*fmt == 'd' && num >= 0) {
            if(flags & PLUS ){
              str[str_len++] = '+'; str[str_len] = '\0';
            }else if(flags & SPACE){
              str[str_len++] = ' '; str[str_len] = '\0';
            }
        }
        else if((flags & SPECIAL)){
          if(*fmt == 'x' || *fmt == 'p'){
            str[str_len++] = 'x'; str[str_len++] = '0'; str[str_len] = '\0';
          }else if(*fmt == 'o'){
            str[str_len++] = '0'; str[str_len] = '\0';
          }  
        }
        reverse_str(str);
      }
      int str_len = strlen(str);
      //54321x0
      //0     6
      //SPECIAL LEFT       
      //%-#10x--->c->gpr[i]
      if(flags & LEFT) {
        strcpy(out + out_len, str);
        out_len += str_len;
        if (str_len < width) {
          for(int i = 0; i < width - str_len; ++i){
            out[out_len + i] = ' ';
          }
          out_len += (width - str_len);
        }
      } else {
        //5 10
        if (str_len < width) {
          if(flags & ZEROPAD){
            for(int i = 0; i < width - str_len; ++i){
              out[out_len + i] = ' ';
            }
          }else{
            for(int i = 0; i < width - str_len; ++i){
              out[out_len + i] = ' ';
            }
          }
          out_len += (width - str_len);
        }
        for(int i = 0; i < str_len; ++i){
          out[out_len + i] = str[i];
        }
        out_len += str_len;
      }
      fmt++; //处理完d，u之后，就需要
    }
    out[out_len] = '\0';
    return out_len;
}
static void reverse_str(char *str){
  for(int i = 0, j = strlen(str) - 1; i < j; i++, j--){
    int tmp = str[i];
    str[i]  = str[j];
    str[j]  = tmp;
  }
}

char int_to_char(int num){
  assert(num < 16);
  char value = '?';
  switch (num){
    case 10: value = 'A'; break;
    case 11: value = 'B'; break;
    case 12: value = 'C'; break;
    case 13: value = 'D'; break;
    case 14: value = 'E'; break;
    case 15: value = 'F'; break;
    default: value = num + '0';   break;
  }
  return value;
}

static int int_to_reversed_str(char *buf, int64_t num, int base){
  int negative = 0;
  int len = 0;
  if     (num  < 0){ num = -num; negative = 1;}
  else if(num == 0){ buf[len++] = '0';}  

  while(num != 0){    
    buf[len++] = int_to_char(num % base);
    num /= base;
  }
  if(negative) buf[len++] = '-';
  buf[len] = '\0';
  return len;
}
#endif
//-左对齐
//将输出的内容左对齐，剩余的空白部分填充在右侧

/*
 * printf的标识
 * 默认是从左向右收入
 * witdh, 表示至少会有width那么长度，如果str < width, 那么会用空格补足            
 *                               如果str > width, 那么会输出str这么长的内容


 * 如果左对齐  [-]，  左对齐，如果不够width，那么后面补空格
 * 如果填充标志[0]，  那么不是LEFT， 那么就把空格替换成0
 * 如果       [+],  对于正数会加一个+
 * 如果   [space],  对于正数会加一个[space]， +的优先级大于[space]
 * 如果       [#],  那么会加一个0x类似的 
 * 
 * 对于%d,  无[#]          , 有[-][0], [+][space] 
 * 对于%c,  无[#][+][space], 有[-][0], 
 * 对于%u,  无[#][+][space], 有[-][0]
 * 对于%x,  无   [+][space], 有[-][0], [#]
 * 对于%o,  无   [+][space], 有[-][0], [#]
*/ 