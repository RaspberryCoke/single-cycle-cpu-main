module IFU
#(WIDTH=32)
(
	input wire  [WIDTH - 1:0] PCU_i_pc,
	output wire [WIDTH - 1:0] IFU_o_instr
);
import "DPI-C" function int  dpi_mem_read 	(input int addr  , input int len);
import "DPI-C" function void dpi_ebreak		(input int pc);

assign IFU_o_instr = dpi_mem_read(PCU_i_pc, 4);

always @(*) begin
	if(IFU_o_instr == 32'h00100073) begin
		dpi_ebreak(PCU_i_pc);
	end
end
endmodule