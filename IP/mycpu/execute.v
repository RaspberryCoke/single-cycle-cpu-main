module execute(
    input wire clk,
    input wire rst,
    input wire[31:0] instr,
    input wire[31:0] pc,
    input wire[31:0] busA,
    input wire[31:0] busB,
    input wire[31:0] imm,
    input wire ALUAsrc,
    input wire[1:0] ALUBsrc,
    input wire[3:0] ALUctr,
    input wire[2:0] Branch,
    output wire Less,
    output wire Zero,
    output wire[31:0] Result,
    output wire[31:0] NextPC
);

    wire PCAsrc;
    wire PCBsrc;

endmodule

