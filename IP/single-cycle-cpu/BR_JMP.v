module BR_JMP
#(WIDTH =32)
(
	input wire					CTRL_i_br_un,
	input wire [WIDTH - 1:0]	IDU_i_valA,
	input wire [WIDTH - 1:0]	IDU_i_valB,
	output wire					BR_JMP_o_br_eq,
	output wire 				BR_JMP_o_br_lt
);

assign BR_JMP_o_br_eq = (CTRL_i_br_un) ? $unsigned(IDU_i_valA)  == $unsigned(IDU_i_valB) : $signed(IDU_i_valA) == $signed(IDU_i_valB);
assign BR_JMP_o_br_lt = (CTRL_i_br_un) ? $unsigned(IDU_i_valA)   < $unsigned(IDU_i_valB) : $signed(IDU_i_valA)  < $signed(IDU_i_valB);
endmodule
