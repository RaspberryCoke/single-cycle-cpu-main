`include "define.v"
module PCU(
	input wire  clk,
	input wire  rst, 
	input wire  [1:0] CTRL_i_pc_sel, 
	input wire  [31:0] EXU_i_valE,
	input wire  [31:0] CSR_i_CSR_valP,
	output wire [31:0] PCU_o_pc,
	output wire [31:0] PCU_o_valP
);

reg [31:0] pc;

assign PCU_o_pc   = pc;
assign PCU_o_valP = pc + 32'd4;

always @(posedge clk) begin
	if(rst) begin
		pc <= 32'h80000000;
	end
	else if(CTRL_i_pc_sel == `pc_sel_valE)  begin
		pc <= EXU_i_valE;
	end
	else if(CTRL_i_pc_sel == `pc_sel_CSR_valP) begin
		pc <= CSR_i_CSR_valP;		
	end
	else if(CTRL_i_pc_sel == `pc_sel_valP) begin
		pc <= PCU_o_valP;
	end
end
endmodule 