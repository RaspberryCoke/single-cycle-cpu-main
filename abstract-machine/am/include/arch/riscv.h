#ifndef ARCH_H__
#define ARCH_H__

#ifdef __riscv_e
#define NR_REGS 16
#else
#define NR_REGS 32
#endif
#include <stdint.h>
struct Context {
  uintptr_t gpr[NR_REGS]; //32*4=128
  uintptr_t mcause; //4
  uintptr_t mstatus;//4
  uintptr_t mepc;   //4
  void *pdir;       //4
};

#ifdef __riscv_e
#define GPR1 gpr[15] // a5
#else
#define GPR1 gpr[17] // a7
#endif

#define GPR2 gpr[0]
#define GPR3 gpr[0]
#define GPR4 gpr[0]
#define GPRx gpr[0]

#endif
