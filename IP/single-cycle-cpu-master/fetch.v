module fetch(
       input   [31:0]  pc_i,
       output  [31:0]  inst_o
);

//
import "DPI-C" function int  dpi_mem_read (input int addr, input int len);
import "DPI-C" function void dpi_ebreak   (input int pc);

assign inst_o = dpi_mem_read(pc_i, 4);

always @(*)begin
    //break
    if(inst_o == 32'h00100073) begin
        dpi_ebreak(pc_i);
    end
end

endmodule
