//memory模块，仅供参考，可以随意修改
module memory(input wire clk,
              input wire rst,
              input wire[31:0] instr);
    
    import "DPI-C" function void dpi_mem_write(input int addr, input int data, int len);
    import "DPI-C" function int  dpi_mem_read (input int addr  , input int len);
    
    
    
endmodule
    
