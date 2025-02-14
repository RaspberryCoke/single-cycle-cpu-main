#include <common.h>
#include <defs.h>
#include <debug.h>
#include <cpu.h>
#include <sys/types.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <npc.h>
#include <sim_state.h>
#include <common.h>
#include <defs.h>

extern CPU_state  cpu;
extern SIMState  sim_state;
uint64_t          g_nr_guest_inst = 0;
static uint64_t   g_timer = 0; // unit: us
static bool       g_print_step = false;
#define MAX_INST_TO_PRINT 100


static TOP_NAME dut;  			    //CPU
static VerilatedVcdC *m_trace;  //仿真波形
static word_t     sim_time  = 0;//时间
static word_t     clk_count = 0;
extern uint32_t * reg_ptr;

void npc_get_clk_count(){
  printf("处理器运行了%u个clk\n", clk_count);
}


void npc_open_simulation(){
  Verilated::traceEverOn(true);
  m_trace= new VerilatedVcdC;
  dut.trace(m_trace, 5);
  m_trace->open("waveform.vcd");
  Log("NPC open simulation");
}
void npc_close_simulation(){
  IFDEF(CONFIG_NPC_OPEN_SIM, 	m_trace->close());
  IFDEF(CONFIG_NPC_OPEN_SIM, Log("NPC close simulation"));
}



void update_cpu_state(){
  cpu.pc = dut.cur_pc_for_simulator;
  memcpy(&cpu.gpr[0], reg_ptr, 4 * 32);
}
void npc_single_cycle() {
  dut.clk = 0;  dut.eval();   
  IFDEF(CONFIG_NPC_OPEN_SIM,   m_trace->dump(sim_time++));
  dut.clk = 1;  dut.eval(); 
  IFDEF(CONFIG_NPC_OPEN_SIM,   m_trace->dump(sim_time++));
  clk_count++;
}
void npc_reset(int n) {
  dut.rst = 1;
  while (n -- > 0) npc_single_cycle();
  dut.rst = 0;
}

void npc_init() {
  IFDEF(CONFIG_NPC_OPEN_SIM, npc_open_simulation());  
  npc_reset(1);
  update_cpu_state();
  if(cpu.pc != 0x80000000){
    npc_close_simulation();
    Assert(cpu.pc== 0x80000000, "[你的处理器]在复位/初始化之后, pc值应该为0x80000000");
  }
}

//si 1执行一条指令就确定是一次commit, 而不是多次clk
void execute(uint64_t n){
  for (   ;n > 0; n --) {
    if (sim_state.state != SIM_RUNNING) {
      if(sim_state.state == SIM_END) printf("下一个[clk]要执行的指令是ebreak, 在单周期处理器中，我们直接退出程序\n");
      break; 
    }
    npc_single_cycle();                         
    word_t cur_pc = cpu.pc;
    update_cpu_state();
    IFDEF(CONFIG_ITRACE, instr_trace(cur_pc));
    IFDEF(CONFIG_DIFFTEST, difftest_step(cur_pc, cur_pc + 4));  
  }
}


void statistic() {
  npc_close_simulation();
  #define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) {
    Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  }else{
    Log("Finish running in less than 1 us and can not calculate the simulation frequency");
  }
}




void cpu_exec(uint64_t n) {
  g_print_step = (n < MAX_INST_TO_PRINT); 
  switch (sim_state.state) {
    case SIM_END: 
    case SIM_ABORT:
      printf("Program execution has ended. To restart the program, exit simulator and run again.\n");
      return;
    default: sim_state.state = SIM_RUNNING;
  }
  uint64_t timer_start = get_time();
  execute(n); 

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (sim_state.state) {
    case SIM_RUNNING: sim_state.state = SIM_STOP; break;
    case SIM_END: 
    case SIM_ABORT:
      Log("sim: %s at pc = " FMT_WORD,
          (sim_state.state == SIM_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
          (sim_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
          ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          sim_state.halt_pc);
          npc_get_clk_count();
    case SIM_QUIT: 
        statistic();
  }
}



//我想的就是复位的时候