module writeback(
    input wire clk,
    input wire rst,
    input wire[31:0] instr,
    input wire[31:0] pc,
    input wire[31:0] MEMORY_OUT,
    output wire[31:0] WRITEBACK_TO_DECODE_REG_DATA,
    output wire[4:0] WRITEBACK_TO_DECODE_REG_ID,
    output wire WRITEBACK_TO_DECODE_REG_EN
);
    wire[6:0] op= instr[6:0];
    
    assign WRITEBACK_TO_DECODE_REG_EN = (op == 7'b1100011 || op == 7'b0100011)?0:1;//[store,banch]->0,else->1 
    assign WRITEBACK_TO_DECODE_REG_ID=instr[11:7];
    assign WRITEBACK_TO_DECODE_REG_DATA=MEMORY_OUT;
endmodule