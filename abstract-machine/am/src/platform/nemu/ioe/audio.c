#include <am.h>
#include <nemu.h>
#include <klib.h>

#define AUDIO_FREQ_ADDR      (AUDIO_ADDR + 0x00)   //[ 3: 0] audio_base[0]
#define AUDIO_CHANNELS_ADDR  (AUDIO_ADDR + 0x04)   //[ 7: 4] audio_base[1]
#define AUDIO_SAMPLES_ADDR   (AUDIO_ADDR + 0x08)   //[11: 8] audio_base[2]
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)   //[15:12] audio_base[3]
#define AUDIO_INIT_ADDR      (AUDIO_ADDR + 0x10)   //[19:16] audio_base[4]
#define AUDIO_COUNT_ADDR     (AUDIO_ADDR + 0x14)   //[23:20] audio_base[5]
#define AUDIO_WIDX_ADDR      (AUDIO_ADDR + 0x18)   //[27:23] audio_base[6]

void __am_audio_init() {
  //初始化不知道要做什么呀
}
void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  cfg->present = true;
  cfg->bufsize = inl(AUDIO_SBUF_SIZE_ADDR); 
}

void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
  outl(AUDIO_CHANNELS_ADDR, ctrl->channels); //向NEMU写入数据
  outl(AUDIO_FREQ_ADDR    , ctrl->freq    );
  outl(AUDIO_SAMPLES_ADDR , ctrl->samples );
  __am_audio_init();
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  stat->count = inl(AUDIO_COUNT_ADDR);     //从NEMU读取数据
}
void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
  uint8_t * data = (uint8_t*)ctl->buf.start;

  int len = ctl->buf.end - ctl->buf.start;

  int count = inl(AUDIO_COUNT_ADDR);
  int widx  = inl(AUDIO_WIDX_ADDR); 
  int size  = inl(AUDIO_SBUF_SIZE_ADDR);
  for(int i = 0; i < len; ++i){
    outb(AUDIO_SBUF_ADDR  + widx, data[i]);  
    widx = (widx + 1 + size) % size;
    if(AUDIO_SBUF_ADDR + widx == 0xA1210000){
      widx = 0;
    }
  }
  outl(AUDIO_WIDX_ADDR ,  widx);
  outl(AUDIO_COUNT_ADDR,  count + len);
}
