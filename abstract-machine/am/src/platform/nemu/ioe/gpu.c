#include <am.h>
#include <nemu.h>
#include <klib.h>

#define VGACTL_ADDR_OFFSET(x) (VGACTL_ADDR + (x) * 2)
#define HEIGHT_ADDR VGACTL_ADDR_OFFSET(0)
#define WIDTH_ADDR  VGACTL_ADDR_OFFSET(1)
#define SYNC_ADDR   VGACTL_ADDR_OFFSET(2)

void __am_gpu_init() {
  
}
//get gpu config from NEMU
void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  volatile int32_t h   = inw(HEIGHT_ADDR);
  volatile int32_t w   = inw(WIDTH_ADDR);
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = w, .height = h,
    .vmemsz = w * h
  };
}

//write data to NEMU's FB_ADDR

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  int x = ctl->x, y = ctl->y, w = ctl->w, h = ctl->h; 
  uint32_t *pixels = (uint32_t *)ctl->pixels; 
  uint32_t *fb =     (uint32_t *)FB_ADDR; 
  //code blow will be not executed, if w == 0 or h == 0
  //assume w=400, h=300
  //fb[x, y] == pixel[i, j] 但是都要转换成一维的
  for (int i = 0; i < h; i++){  
    for(int j = 0; j < w; j++){ 
      fb[x + j + (y + i) * 400] = pixels[j + i * w];
    }
  }
 
  // ctl->sync is a boolean value (0-false or 1-true)
  outl(SYNC_ADDR, ctl->sync);
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
