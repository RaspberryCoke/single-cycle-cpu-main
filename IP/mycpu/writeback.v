module writeback(
    input wire clk,
    input wire rst,
    input wire[31:0] instr,
    input wire[31:0] Data,
    output wire[31:0] write_data,
    output wire[4:0] write_reg,
    output wire write_en
);
    wire[4:0] op5;
    assign op5 = instr[6:2];
    assign write_en = (op5 == 5'b11000 || op5 == 5'b01000)?0:1;//wrong ? RegWr
    assign write_reg=instr[11:7];
    assign write_data=Data;
endmodule