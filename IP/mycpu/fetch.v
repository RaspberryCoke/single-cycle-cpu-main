`include "define.v"
module fetch #(WIDTH = 32)
              (input wire [WIDTH - 1:0] pc,
               output wire [WIDTH - 1:0] instr)
;
    import "DPI-C" function int  dpi_mem_read 	(input int addr  , input int len);
    import "DPI-C" function void dpi_ebreak		(input int pc);
    
    assign instr = dpi_mem_read(pc, 4);
    
    always @(*) begin
        if (instr == 32'h00100073) begin
            dpi_ebreak(pc);
        end
    end

endmodule
