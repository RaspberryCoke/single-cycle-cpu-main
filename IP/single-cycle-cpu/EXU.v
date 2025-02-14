`include "define.v"
module EXU
#(WIDTH = 32)
(
	input wire                   clk, //for debug
	input wire 					 CTRL_i_valA_sel,
	input wire 					 CTRL_i_valB_sel,
	input wire 	[3:0]  			 CTRL_i_ALU_sel,
	input wire  [WIDTH - 1:0]  	 IDU_i_valA,
	input wire  [WIDTH - 1:0] 	 IDU_i_valB,
	input wire  [WIDTH - 1:0] 	 IDU_i_valC,
	input wire  [WIDTH - 1:0] 	 PCU_i_pc,
	output wire [WIDTH - 1:0]	 EXU_o_valE
);

wire [WIDTH - 1:0] valA= 	(CTRL_i_valA_sel == `valA_sel_valA) ?  IDU_i_valA : PCU_i_pc;   
wire [WIDTH - 1:0] valB= 	(CTRL_i_valB_sel == `valB_sel_valB) ?  IDU_i_valB : IDU_i_valC;



assign EXU_o_valE[WIDTH - 1:0]  =	(CTRL_i_ALU_sel == 	`FUNC_ADD 		)   ?  valA + valB							:
									(CTRL_i_ALU_sel == 	`FUNC_SUB 		)   ?  valA - valB							:
									(CTRL_i_ALU_sel ==  `FUNC_SLL 		)   ?  valA << valB[4:0] 					:
									(CTRL_i_ALU_sel ==  `FUNC_SLT  		)   ?  ($signed(valA)   < $signed(valB)) ? 32'd1 : 32'd0	:
									(CTRL_i_ALU_sel ==  `FUNC_SLTU		)   ?  ($unsigned(valA) < $unsigned(valB)) ? 32'd1 : 32'd0	:
									(CTRL_i_ALU_sel ==  `FUNC_XOR		)   ?  {valA[31:0]	^ valB[31:0]}						  	:
									(CTRL_i_ALU_sel ==  `FUNC_SRL		) 	?  {$unsigned(valA) >>  valB[4:0]}		:
									(CTRL_i_ALU_sel ==  `FUNC_SRA		)  	?  {$signed(valA)   >>> valB[4:0]}  	:
									(CTRL_i_ALU_sel == 	`FUNC_OR 		)  	?  valA | valB							:
									(CTRL_i_ALU_sel ==  `FUNC_AND 		)  	?  valA & valB							:
									(CTRL_i_ALU_sel ==  `FUNC_JALR  	)  	? ((valA + valB)&(~1)) 					:
									(CTRL_i_ALU_sel ==  `FUNC_SEL_VALC 	) 	?  valB  							: 32'd0; 


endmodule //EUX


