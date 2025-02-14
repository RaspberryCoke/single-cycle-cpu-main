#include <am.h>
#include <nemu.h>
#include <klib.h>

#define RTC_ADDR_OFFSET(x) (RTC_ADDR + (x) * 4)
#define RTC_ADDR_US_LOW      RTC_ADDR_OFFSET(0)
#define RTC_ADDR_US_HIGH     RTC_ADDR_OFFSET(1)
#define REAL_RTC_ADDR_YEAR   RTC_ADDR_OFFSET(2)
#define REAL_RTC_ADDR_MONTH  RTC_ADDR_OFFSET(3)
#define REAL_RTC_ADDR_DAY    RTC_ADDR_OFFSET(4)
#define REAL_RTC_ADDR_HOUR   RTC_ADDR_OFFSET(5)
#define REAL_RTC_ADDR_MINUTE RTC_ADDR_OFFSET(6)
#define REAL_RTC_ADDR_SECOND RTC_ADDR_OFFSET(7)

static uint64_t boot_time = 0;
static inline uint64_t read_time() {
  //先访问的RTC_ADDR + 4，然后会先访问回调函数rtc_io_handler,触发里面的offset=4, 更新us时间
  //接着真正读取那块地址，然后再访问RTC_ADDR + 0
  return ((uint64_t)inl(RTC_ADDR_US_HIGH) << 32)| inl(RTC_ADDR_US_LOW);
}


void __am_timer_init() {
  boot_time = read_time();
}
//目前__am_timer_uptime就一个单纯读取时间寄存器的作用
void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  uptime->us = read_time() - boot_time;
}
void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  //先访问的RTC_ADDR + 8，然后会先访问回调函数rtc_io_handler,触发里面的offset=4, 更新us时间
  rtc->year   = inl(REAL_RTC_ADDR_YEAR);
  rtc->month  = inl(REAL_RTC_ADDR_MONTH);
  rtc->day    = inl(REAL_RTC_ADDR_DAY);
  rtc->hour   = inl(REAL_RTC_ADDR_HOUR);
  rtc->minute = inl(REAL_RTC_ADDR_MINUTE);
  rtc->second = inl(REAL_RTC_ADDR_SECOND);
}
