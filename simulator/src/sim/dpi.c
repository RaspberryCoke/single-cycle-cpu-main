#include <common.h>
#include <cstdint>
#include <cstdio>
#include <defs.h>
#include <sys/types.h>
#include "verilated_dpi.h" // For VerilatedDpiOpenVar and other DPI related definitions




void difftest_skip_ref();

extern "C" void dpi_ebreak(int pc){
	SIMTRAP(pc, 0);
}

extern "C" int dpi_mem_read(int addr, int len){
	if(addr == 0) return 0;
	if(addr >=  CONFIG_RTC_MMIO && addr < CONFIG_RTC_MMIO + 4){
		int time = get_time();
		IFDEF(CONFIG_DIFFTEST, difftest_skip_ref());
		return time;
	}else if((u_int32_t)addr >= 0x80000000 && (u_int32_t)addr <= 0x8fffffff){
		unsigned int data = pmem_read(addr, len);
		return data;
	}else{
		printf("你的处理器将要访问的地址是[0x%x], 内存越界, 程序即将退出\n", addr);
		npc_close_simulation();
		exit(1);
	}
}
extern "C" void dpi_mem_write(int addr, int data, int len){
	if(addr == CONFIG_SERIAL_MMIO){
		char ch = data;
		printf("%c", ch);
		fflush(stdout);
		IFDEF(CONFIG_DIFFTEST, difftest_skip_ref());
	}else if((u_int32_t)addr >= 0x80000000 && (u_int32_t)addr <= 0x8fffffff){
		pmem_write(addr, len, data);
	}else{
		printf("你的处理器将要访问的地址是[0x%x], 内存越界, 程序即将退出\n", addr);
		npc_close_simulation();
		exit(1);
	}
}



extern uint32_t  *reg_ptr;
extern "C" void dpi_read_regfile(const svOpenArrayHandle r) {
  reg_ptr = (uint32_t *)(((VerilatedDpiOpenVar*)r)->datap());
}