//CPU模块, 不可修改，你的处理器需要在此实例化各个模块
module CPU(
	input wire clk,
	input wire rst,

	output wire [31:0] cur_pc_for_simulator,
	output wire [31:0] regfile_for_simulator[31:0]
);
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
wire[4:0] Rw;//from writeback to decode
wire RegWr;//from writeback to decode
wire[31:0] busW;//from writeback to decode
wire[31:0]rs1;//decode output
wire[31:0]rs2;//decode output
//execute
wire Less;
wire Zero;
wire[31:0] Result;
wire[31:0] NextPC;//from execute to select_pc
//memory
wire[31:0] DataOut;

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
	.Rw(Rw),//from writeback
	.RegWr(RegWr),//from writeback
	.busW(busW),//from writeback
	.rs1(rs1),
	.rs2(rs2)
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
	.addr(Result),
	.MemtoReg(MemtoReg),
	.DataIn(rs2),
	.DataOut(DataOut)
);

writeback writeback_module(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.Data(DataOut),
	.write_data(busW),//from writeback to decode
	.write_reg(Rw),
	.write_en(RegWr)
);

endmodule