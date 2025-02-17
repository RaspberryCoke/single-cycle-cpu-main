module writeback(
    input wire clk,
    input wire rst,
    input wire[31:0] instr,
    input wire[31:0] pc,
    input wire[31:0] MEMORY_IN,
    output wire[31:0] WRITEBACK_TO_DECODE_REG_DATA,
    output wire[4:0] WRITEBACK_TO_DECODE_REG_ID,
    output wire WRITEBACK_TO_DECODE_REG_EN
);
    wire[4:0] op5= instr[6:2];
    assign WRITEBACK_TO_DECODE_REG_EN = (op5 == 5'b11000 || op5 == 5'b01000)?0:1;//[store,banch]->0,else->1 
    assign WRITEBACK_TO_DECODE_REG_ID=instr[11:7];
    assign WRITEBACK_TO_DECODE_REG_DATA=MEMORY_IN;
endmodule