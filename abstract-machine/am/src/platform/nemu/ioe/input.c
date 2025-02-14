#include <am.h>
#include <nemu.h>

#define KEYDOWN_MASK 0x8000 //键盘按下之后

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  volatile uint32_t k   = inl(KBD_ADDR);
  //如果是一个通码， 那么k的值为通码 & KEYDOWN_MASK
  //如果是一个断码， 那么k的值为断码的值
  kbd->keydown = (k &  KEYDOWN_MASK) ? true : false;
  kbd->keycode =  k & ~KEYDOWN_MASK;
}

