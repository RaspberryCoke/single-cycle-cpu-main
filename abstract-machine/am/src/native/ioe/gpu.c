#include <am.h>
#include <SDL2/SDL.h>
#include <fenv.h>

//#define MODE_800x600
#ifdef MODE_800x600
# define W    800
# define H    600
#else
# define W    400
# define H    300
#endif

#define FPS   60

#define RMASK 0x00ff0000
#define GMASK 0x0000ff00
#define BMASK 0x000000ff
#define AMASK 0x00000000

static SDL_Window *window = NULL;
static SDL_Surface *surface = NULL;

static Uint32 texture_sync(Uint32 interval, void *param) {
  SDL_BlitScaled(surface, NULL, SDL_GetWindowSurface(window), NULL);
  SDL_UpdateWindowSurface(window);
  return interval;
}


void __am_gpu_init() {
  SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER);

  //原型函数:SDL_CreateWindow(const char *title,int x, int y, int w,int h, Uint32 flags);
  //title表示窗口的标题， x表示窗口左上角的坐标, y表示窗口右上角的坐标
  //w表示宽， h表示高， flags是一些标志
  window = SDL_CreateWindow("Native Application", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
#ifdef MODE_800x600
      W, H,
#else
      W * 2, H * 2,
#endif
      SDL_WINDOW_OPENGL); 
  //SDL_SWSURFACE表示存储在[系统内存]中, W和H表示宽度和高度，32表示每个bit使用的位数
  //RMASK, GMASK, BMASK, AMASK这些参数定义了红色、绿色、蓝色和透明度通道在32位整数中的位置和大小
  surface = SDL_CreateRGBSurface(SDL_SWSURFACE, W, H, 32, RMASK, GMASK, BMASK, AMASK);

  //添加一个定时器， 每1000/FPS秒调用一次texture_sync函数，然后传递给该函数的参数为NULL
  SDL_AddTimer(1000 / FPS, texture_sync, NULL);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  //has_accel表示是否支持硬件加速
  //vmemsz 表示虚拟内存大小，初始化为0
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = W, .height = H,
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  int x = ctl->x, y = ctl->y, w = ctl->w, h = ctl->h;
  if (w == 0 || h == 0) return;
  feclearexcept(-1);
  SDL_Surface *s = SDL_CreateRGBSurfaceFrom(ctl->pixels, w, h, 32, w * sizeof(uint32_t),
      RMASK, GMASK, BMASK, AMASK);
  SDL_Rect rect = { .x = x, .y = y };
  SDL_BlitSurface(s, NULL, surface, &rect);
  SDL_FreeSurface(s);
}

void __am_gpu_status(AM_GPU_STATUS_T *stat) {
  stat->ready = true;
}
