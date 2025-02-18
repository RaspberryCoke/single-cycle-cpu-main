//CPU模块, 不可修改，你的处理器需要在此实例化各个模块
module CPU(
	input wire clk,
	input wire rst,

	output wire [31:0] cur_pc_for_simulator
);

//select_pc
wire[31:0] pc;
wire[31:0] NextPC;
assign cur_pc_for_simulator=pc;
//fetch
wire[31:0] instr;
//*decode 译码阶段
wire WB_REG_WRITE_EN_OUT;//writeback to decode,是否需要写回reg
wire[4:0] WB_REG_ID_OUT;//writeback to decode,准备写回的reg的id
wire[31:0] WB_DATA_OUT;//writeback to decode,准备写回的reg的data
wire[31:0]DECODE_REG_VALUE_OUT1;
wire[31:0]DECODE_REG_VALUE_OUT2;
wire[31:0]DECODE_IMM_OUT;
wire MemtoReg;
//execute
wire[31:0] EXECUTE_OUT;
//memory
wire[31:0] MEMORY_OUT;

select_pc select_pc_module(
	.clk(clk),
	.rst(rst),
	.NextPC(NextPC),
	.pc(pc)
);

fetch fetch_module(
	.pc(pc),
	.instr(instr)
);

decode decode_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.pc(pc),

	.WRITEBACK_TO_DECODE_REG_WRITE_EN_IN(WB_REG_WRITE_EN_OUT),
	.WRITEBACK_TO_DECODE_REG_ID_IN(WB_REG_ID_OUT),
	.WRITEBACK_TO_DECODE_DATA_IN(WB_DATA_OUT),

	.REG_VALUE_OUT1(DECODE_REG_VALUE_OUT1),//from writeback
	.REG_VALUE_OUT2(DECODE_REG_VALUE_OUT2),//from writeback
	.IMM_OUT(DECODE_IMM_OUT)
);

execute execute_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.pc(pc),
	
	.REG_VALUE_IN1(DECODE_REG_VALUE_OUT1),
	.REG_VALUE_IN2(DECODE_REG_VALUE_OUT2),
	.DECODE_IMM_IN(DECODE_IMM_OUT),
	.EXECUTE_OUT(EXECUTE_OUT),
	.MemtoReg(MemtoReg),
	.NextPC(NextPC)
);

memory memory_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.pc(pc),

	.EXECUTE_IN(EXECUTE_OUT),
	.MemtoReg(MemtoReg),
	.REG_VALUE_OUT2(DECODE_REG_VALUE_OUT2),
	.MEMORY_OUT(MEMORY_OUT)
);

writeback writeback_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.pc(pc),

	.MEMORY_OUT(MEMORY_OUT),
	.WRITEBACK_TO_DECODE_REG_DATA(WB_DATA_OUT),//from writeback to decode
	.WRITEBACK_TO_DECODE_REG_ID(WB_REG_ID_OUT),
	.WRITEBACK_TO_DECODE_REG_EN(WB_REG_WRITE_EN_OUT)
);
endmodule