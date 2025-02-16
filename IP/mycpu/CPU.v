//CPU模块, 不可修改，你的处理器需要在此实例化各个模块
module CPU(
	input wire clk,
	input wire rst,

	output wire [31:0] cur_pc_for_simulator
	//output wire [31:0] regfile_for_simulator[31:0]
);
wire [31:0] regfile_for_simulator[31:0];//
//select_pc
wire[31:0] pc;
wire[31:0] NextPC;
assign cur_pc_for_simulator=pc;
//fetch
wire[31:0] instr;
wire[4:0] Ra;
wire[4:0] Rb;
wire[2:0] ExtOp;
wire ALUAsrc;
wire[1:0] ALUBsrc;
wire[3:0] ALUctr;
wire[2:0] Branch;
wire MemtoReg;
wire MemWr;
wire[2:0] MemOP;
wire[31:0]imm;//from fetch to execute
//decode
wire[4:0] wb_to_reg_num;//Rw
//wire[4:0] Rw;//from writeback to decode
wire wb_to_reg_en;//RegWr
// wire RegWr;//from writeback to decode
wire[31:0] wb_to_reg_data;//busW
//wire[31:0] busW;//from writeback to decode
wire[31:0]rs1;//decode output
wire[31:0]rs2;//decode output
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
	.ExtOp(ExtOp),
	.ALUAsrc(ALUAsrc),
	.ALUBsrc(ALUBsrc),
	.ALUctr(ALUctr),
	.Branch(Branch),
	.MemtoReg(MemtoReg),
	.MemWr(MemWr),
	.MemOP(MemOP),
	.imm(imm)
);

decode decode_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.Ra(Ra),
	.Rb(Rb),
	.Rw(wb_to_reg_num),//from writeback
	.RegWr(wb_to_reg_en),//from writeback
	.busW(wb_to_reg_data),//from writeback
	.rs1(rs1),
	.rs2(rs2),
	.regfile_for_simulator(regfile_for_simulator)
);

execute execute_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.pc(pc),
	.rs1(rs1),
	.rs2(rs2),
	.imm(imm),
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
	.instr(instr),
	.execute_out(Result),
	.MemtoReg(MemtoReg),
	.rs2(rs2),
	.memory_out(memory_out)
);



writeback writeback_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.memory_out(memory_out),
	.wb_to_reg_data(wb_to_reg_data),//from writeback to decode
	.wb_to_reg_num(wb_to_reg_num),
	.wb_to_reg_en(wb_to_reg_en)
);

endmodule