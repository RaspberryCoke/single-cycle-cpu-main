//fetch模块，仅供参考，可以随意修改

`include "define.v"
module fetch(input wire [WIDTH - 1:0] pc,
             output wire [WIDTH - 1:0] instr,
             output wire[2:0] ExtOp,          //for debug
             output wire RegWr,
             output wire ALUAsrc,
             output wire ALUBsrc,
             output wire ALUctr,
             output wire Branch,
             output wire MemtoReg,
             output wire MemWr,
             output wire MemOp);
import "DPI-C" function int  dpi_mem_read 	(input int addr  , input int len);
import "DPI-C" function void dpi_ebreak		(input int pc);

assign instr = dpi_mem_read(pc, 4);

always @(*) begin
    if (instr == 32'h00100073) begin
        dpi_ebreak(pc);
    end
end

assign  op    = instr[6:0];
assign  rs1   = instr[19:15];
assign  rs2   = instr[24:20];
assign  rd    = instr[11:7];
assign  func3 = instr[14:12];
assign  func7 = instr[31:25];

assign immI = {{20{instr[31]}}, instr[31:20]};
assign immU = {instr[31:12], 12'b0};
assign immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};
assign immB = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
assign immJ = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

assign op5 = op[6:2];

assign ExtOp = 
(
(op5 == 5'b00100 && func3 == 3'b000)||
(op5 == 5'b00100 && func3 == 3'b010)||
(op5 == 5'b00100 && func3 == 3'b011)||
(op5 == 5'b00100 && func3 == 3'b100)||
(op5 == 5'b00100 && func3 == 3'b110)||
(op5 == 5'b00100 && func3 == 3'b111)||
(op5 == 5'b00100 && func3 == 3'b001 && func7[5] == 0)||
(op5 == 5'b00100 && func3 == 3'b101)||
(op5 == 5'b11001 && func3 == 3'b000)||
(op5 == 5'b00000)
)?`immi:
((op5 == 5'b01101)||(op5 == 5'b00101))?`immu:
(op5 == 5'b11011)?`immj:
(op5 == 5'b11000)?`immb:
(op5 == 5'b01000)?`imms:3'b111;//wrong ?

assign imm = (ExtOp == `imms)?immS:
(ExtOp == `immu)?immU:
(ExtOp == `imms)?immS:
(ExtOp == `immb)?immB:
(ExtOp == `immj)?immJ:32'b0;

assign RegWr = (op5 == 5'b11000 || op5 == 5'b01000)?0:1;//wrong ?

assign Branch = (op5 == 5'11011)?3'b001:
(op5 == 5'b11000)?3'b011:3'b000;

assign MemtoReg == (op5 == 5'b01101 || op5 == 5'b00101 || op5 == 5'b00100 || op6 == 5'b01100 || op5 == 5'b11011 ||  op5 == 5'b11001)?0:
(op5 == 5'b00000)?1:0;//wrong ?

assign MemWr=(op5==5'b01000)?1:0;

assign MemOP=((op5==5'b00000&&func3==3'b000)||(op5==5'b01000&&func3==3'b000))?3'b000:
((op5==5'b00000&&func3==3'b001)||(op5==5'b01000&&func3==3'b001))?3'b001:
((op5==5'b00000&&func3==3'b010)||(op5==5'b01000&&func3==3'b010))?3'b010:
(op5==5'b00000&&func3==3'b100)?3'b100:
(op5==5'b00000&&func3==3'b101)?3'b101:3'b111;//wrong ?

assign ALUAsrc=(op5==5'b00101 || op5==5'b11011 || (op5==5'b11001&&func3==3'b000))?1:0;//wrong ?

assign ALUBsrc=(op5==5'b11011 || op5==5'b11001)?2'b10:
(op5==5'b01100 || op5==5'b11000)?2'b00:2'b01;

assign ALUctr=(op5==5'b01101)?4'b0011:
((op5==5'b00100 && func3==3'b010)||(op5==5'b01100 && func3==3'b010 &&func7==0)||(op5==5'b11000 && (func3==3'b000 || func3==3'b001||func3==3'b100||func3==3'b101)))?4'b0010:
((op5==5'b00100&&func3==3'b011)||(op5==5'b01100&&func3==3'b011&&func7==0)||(op5==5'b11000&&func3==3'b110)||(op5==5'b11000&&func3==3'b111))?4'b1010:
((op5==5'b00100&&func3==3'b100)||(op5==5'b01100&&func3==3'b100&&func7==0))?4'b0100:
((op5==5'b00100&&func3==3'b110)||(op5==5'b01100&&func3==3'b110))?4'b0110:
((op5==5'b00100&&func3==3'b111)||(op5==5'b01100&&func3==3'b111&&func7==0))?4'b0111:
()

endmodule
