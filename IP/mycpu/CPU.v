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
wire[4:0] Ra;
wire[4:0] Rb;

wire ALUAsrc;
wire[1:0] ALUBsrc;
wire[3:0] ALUctr;
wire[2:0] Branch;
wire MemtoReg;
wire MemWr;
wire[2:0] MemOP;
wire[31:0]Imm;//from fetch to execute

//*decode 译码阶段
wire WB_REG_WRITE_EN_OUT;//writeback to decode,是否需要写回reg
wire[4:0] WB_REG_ID_OUT;//writeback to decode,准备写回的reg的id
wire[31:0] WB_DATA_OUT;//writeback to decode,准备写回的reg的data

wire[31:0]DEC_REG_VALUE_OUT1;//decode to execute
wire[31:0]DEC_REG_VALUE_OUT2;//decode to execute

//execute
wire Less;
wire Zero;
wire[31:0] Result;
wire[31:0] NextPC;//from execute to select_pc
//memory
wire[31:0] memory_out;//DataOut







select_pc select_pc_module(
	.clk(clk),
	.rst(rst),
	.NextPC(NextPC),
	.pc(pc)
);

fetch fetch_module(
	.pc(pc),
	.instr(instr),
	.Ra(Ra),
	.Rb(Rb),

	.ALUAsrc(ALUAsrc),
	.ALUBsrc(ALUBsrc),
	.ALUctr(ALUctr),
	.Branch(Branch),
	.MemtoReg(MemtoReg),
	.MemWr(MemWr),
	.MemOP(MemOP),
	.Zero(Zero),
	.Less(Less),
	.Imm(Imm)
);

// module decode(input wire clk,
//               input wire rst,
//               input wire[31:0] instr,
//               input wire[31:0] pc,

//               input wire WBtoDEC_REG_WRITE_EN_IN,//from writeback
//               input wire[4:0] WBtoDEC_REG_ID_IN,//from writeback
//               input wire[31:0] WBtoDEC_DATA_IN,//from writeback

//               output wire[31:0]REG_VALUE_OUT1,
//               output wire[31:0]REG_VALUE_OUT2
//               );

decode decode_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.pc(pc),

	.WBtoDEC_REG_WRITE_EN_IN(WB_REG_WRITE_EN_OUT),
	.WBtoDEC_REG_ID_IN(WB_REG_ID_OUT),
	.WBtoDEC_DATA_IN(WB_DATA_OUT),

	.REG_VALUE_OUT1(DEC_REG_VALUE_OUT1),//from writeback
	.REG_VALUE_OUT2(DEC_REG_VALUE_OUT2)//from writeback
);

execute execute_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.pc(pc),
	.rs1(rs1),
	.rs2(rs2),
	.Imm(Imm),
	.ALUAsrc(ALUAsrc),
	.ALUBsrc(ALUBsrc),
	.ALUctr(ALUctr),
	.Branch(Branch),
	.Less(Less),
	.Zero(Zero),
	.Result(Result),
	.NextPC(NextPC)
);




memory memory_module(
	.clk(clk),
	.rst(rst),
	.instr_debug(instr),
	.pc_debug(pc),
	.execute_out(Result),
	.MemtoReg(MemtoReg),
	.rs2(rs2),
	.memory_out(memory_out)
);



writeback writeback_module(
	.clk(clk),
	.rst(rst),
	.instr_debug(instr),
	.pc_debug(pc),
	.memory_out(memory_out),
	.wb_to_reg_data(wb_to_reg_data),//from writeback to decode
	.wb_to_reg_id(wb_to_reg_id),
	.wb_to_reg_en(wb_to_reg_en)
);

endmodule