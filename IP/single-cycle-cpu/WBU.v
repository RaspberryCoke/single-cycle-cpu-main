`include "define.v"
module WBU
#(WIDTH = 32)
(
	input wire 			[1:0]		CTRL_i_wb_sel,
	input wire  [WIDTH - 1 : 0]     PCU_i_valP,
	input wire 	[WIDTH - 1 : 0] 	MEM_i_valM,
	input wire 	[WIDTH - 1 : 0]		EXU_i_valE,
	input wire  [WIDTH - 1 : 0]     CSR_i_valR,
	output wire [WIDTH - 1 : 0]     WBU_o_valW
);

assign WBU_o_valW[WIDTH - 1 : 0] = 	(CTRL_i_wb_sel== `wb_sel_valM) ? MEM_i_valM :
									(CTRL_i_wb_sel== `wb_sel_valE) ? EXU_i_valE :
									(CTRL_i_wb_sel== `wb_sel_valP) ? PCU_i_valP :
									(CTRL_i_wb_sel== `wb_sel_valR) ? CSR_i_valR : 32'd0;
endmodule