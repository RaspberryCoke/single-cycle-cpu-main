#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  if (user_handler) {
    Event ev = {0};
    switch (c->mcause) {
      case EVENT_YIELD   : ev.event = EVENT_YIELD;   break;
      default: ev.event = EVENT_ERROR; break;
    }
#ifdef CALL_INFO
    printf("in [__am_irq_handle] before [schedule], c=%#p\n", c);
    printf("in [__am_irq_handle] before  [schedule], c->mepc=%#p\n", c->mepc);
    c = user_handler(ev, c);
    printf("in [__am_irq_handle] after  [schedule], c=%#p\n", c);
    printf("in [__am_irq_handle] after  [schedule], c->mepc=%#p\n", c->mepc);
    printf("\n");
    assert(c != NULL);
#else
    c = user_handler(ev, c);
    assert(c != NULL);
#endif
  }
  return c;
}

extern void __am_asm_trap(void);
bool cte_init(Context*(*handler)(Event, Context*)) {
  printf("right\n");
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));
  user_handler = handler;
  return true;
}




Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  Context *cnt = (Context*)kstack.end - 1;
  for(int i = 0; i < NR_REGS; ++i){
    cnt->gpr[i] = 0;
  }
  cnt->gpr[10] = (uintptr_t)arg; // 将 void* 转换为 uintptr_t
  cnt->mcause  = EVENT_YIELD;
  cnt->mstatus = 0x1800;
  cnt->mepc    = (uintptr_t)entry;
  cnt->pdir    = NULL;
  return cnt;
}

void yield() {
  #ifdef __riscv_e
    asm volatile("li a5, -1; ecall");
  #else
    //a7是系统调用号
    asm volatile("li a7, -1; ecall");
  #endif
}

bool ienabled() { return false; }
void iset(bool enable) {}

