module regfile(
	input            clk,
	input            rst,
	//debug 
	input [31:0] instr_debug,	
	//from decode
	input   [ 4:0]   rs1_id_i,
	input   [ 4:0]   rs2_id_i,
	
	output  [31:0]   rs1_rdata_o,
	output  [31:0]   rs2_rdata_o,

	//write 
	input            w_en,        //write enable
	input   [ 4:0]   rd_id_i,
	input   [31:0]   rd_write_data_i
);

reg [31:0] rf[31:0];

assign rs1_rdata_o = (rs1_id_i == 5'b0) ? 32'b0 : rf[rs1_id_i];
assign rs2_rdata_o = (rs2_id_i == 5'b0) ? 32'b0 : rf[rs2_id_i];

import "DPI-C" function void dpi_read_regfile(input logic [31 : 0] a []);
initial begin
	dpi_read_regfile(rf);
end

always @(posedge clk) begin
    if(rst) begin
        rf[0] <= 32'h0;
    end
    else if(w_en && rd_id_i != 0) begin
	rf[rd_id_i] <= rd_write_data_i;
	//! debug: 以下代码用来debug，涉及到的变量严禁使用！
	// if(opcode==7'b0110111)
	// 	$display("\t[refile.v]:load instr:: write data to regfile[%h]=%h.\n",rd_id_i,rd_write_data_i);
    end
end   

	//! debug: 以下代码用来debug，涉及到的变量严禁使用！
    // wire [6:0] opcode = instr_debug[6:0];
    // wire [2:0] funct3 = instr_debug[14:12];

    // wire load_byte               = (opcode == 7'b0000011) && (funct3 == 3'b000);  // lb
    // wire load_half_word          = (opcode == 7'b0000011) && (funct3 == 3'b001);  // lh
    // wire load_word               = (opcode == 7'b0000011) && (funct3 == 3'b010);  // lw
    // wire load_byte_unsigned      = (opcode == 7'b0000011) && (funct3 == 3'b100);  // lbu
    // wire load_half_word_unsigned = (opcode == 7'b0000011) && (funct3 == 3'b101);  // lhu
    // wire store_byte              = (opcode == 7'b0100011) && (funct3 == 3'b000);  // sb
    // wire store_half_word         = (opcode == 7'b0100011) && (funct3 == 3'b001);  // sh
    // wire store_word              = (opcode == 7'b0100011) && (funct3 == 3'b010);  // sw

	// wire load_instr=load_byte|load_half_word|load_word|load_byte_unsigned|load_half_word_unsigned;
	// wire store_instr=store_byte|store_half_word|store_word;
// always@(*)begin
// 	if(opcode==7'b0110111)
// 		begin $display("\t[refile.v]:store instr:: read data from regfile[%h]=%h.\n",rd_id_i,rd_write_data_i); end
// end
	//! debug
endmodule
