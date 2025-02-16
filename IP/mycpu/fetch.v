//fetch模块，仅供参考，可以随意修改

`include "define.v"
module fetch #(WIDTH = 32)
              (input wire [WIDTH - 1:0] pc,
               output wire [WIDTH - 1:0] instr,
               output wire[4:0] Ra,
               output wire[4:0] Rb,
               //output wire RegWr,
               output wire ALUAsrc,
               output wire[1:0] ALUBsrc,
               output wire[3:0] ALUctr,
               output wire[2:0] Branch,
               output wire MemtoReg,
               output wire MemWr,
               output wire[2:0] MemOP,
               output wire Zero,
               output wire Less,
               output wire ImmValid,
               output wire[31:0]Imm);
    import "DPI-C" function int  dpi_mem_read 	(input int addr  , input int len);
    import "DPI-C" function void dpi_ebreak		(input int pc);
    
    assign instr = dpi_mem_read(pc, 4);
    
    always @(*) begin
        if (instr == 32'h00100073) begin
            dpi_ebreak(pc);
        end
    end

    wire[6:0]  op    = instr[6:0];
    wire[4:0]  rs1   = instr[19:15];
    wire[4:0]  rs2   = instr[24:20];
    wire[4:0]  rd    = instr[11:7];
    wire[2:0]  func3 = instr[14:12];
    wire[6:0]  func7 = instr[31:25];

    wire[31:0] ImmI = {{20{instr[31]}}, instr[31:20]};
    wire[31:0] ImmU = {instr[31:12], 12'b0};
    wire[31:0] ImmS = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire[31:0] ImmB = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    wire[31:0] ImmJ = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
    
    assign Ra=rs1;
    assign Rb=rs2;

    wire[4:0] op5;
    assign op5 = op[6:2];
    
    wire[2:0] ExtOp = 
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
    )?`IMMI://9条指令
    ((op5 == 5'b01101)||(op5 == 5'b00101))?`IMMU://一共就两条指令
    (op5 == 5'b11011)?`IMMJ:
    (op5 == 5'b11000)?`IMMB:
    (op5 == 5'b01000)?`IMMS:`IMM_ERR;//wrong ?
    
    
    assign Imm = 
    (ExtOp == `IMMI)?ImmI:
    (ExtOp == `IMMU)?ImmU:
    (ExtOp == `IMMS)?ImmS:
    (ExtOp == `IMMB)?ImmB:
    (ExtOp == `IMMJ)?ImmJ:32'b0;

    assign ImmValid=(ExtOp == `IMM_ERR);
    
    //assign RegWr = (op5 == 5'b11000 || op5 == 5'b01000)?0:1;//wrong ?
    
    assign Branch = 
    (op5 == 5'b11011)?3'b001:
    (op5 == 5'b11001 && func3==3'b000)?3'b010:
    (op5 == 5'b11000 && func3==3'b000)?3'b100:
    (op5 == 5'b11000 && func3==3'b001)?3'b101:
    (op5 == 5'b11000 && (func3==3'b100||func3==3'b110))?3'b110:
    (op5 == 5'b11000 && (func3==3'b101||func3==3'b111))?3'b111:3'b000;
    
    assign MemtoReg = (op5 == 5'b01101 || op5 == 5'b00101 || op5 == 5'b00100 || op5 == 5'b01100 || op5 == 5'b11011 ||  op5 == 5'b11001)?0:
    (op5 == 5'b00000)?1:0;//wrong ?
    
    assign MemWr = (op5 == 5'b01000)?1:0;
    //宽度为3bit，控制数据存储器读写格式，为010时为4字节读写，
    //为001时为2字节读写带符号扩展，为000时为1字节读写带符号扩展，
    //为101时为2字节读写无符号扩展，为100时为1字节读写无符号扩展。
    assign MemOP = ((op5 == 5'b00000&&func3 == 3'b000)||(op5 == 5'b01000&&func3 == 3'b000))?3'b000:
    ((op5 == 5'b00000&&func3 == 3'b001)||(op5 == 5'b01000&&func3 == 3'b001))?3'b001:
    ((op5 == 5'b00000&&func3 == 3'b010)||(op5 == 5'b01000&&func3 == 3'b010))?3'b010:
    (op5 == 5'b00000&&func3 == 3'b100)?3'b100:
    (op5 == 5'b00000&&func3 == 3'b101)?3'b101:3'b111;//wrong ?
    
    assign ALUAsrc = (op5 == 5'b00101 || op5 == 5'b11011 || (op5 == 5'b11001&&func3 == 3'b000))?1:0;//wrong ?
    
    assign ALUBsrc = 
    (op5 == 5'b11011 || op5 == 5'b11001)?2'b10:
    (op5 == 5'b01100 || op5 == 5'b11000)?2'b00:2'b01;
    
    assign ALUctr = 
    (op5 == 5'b01101)?4'b0011:
    ((op5 == 5'b00100 && func3 == 3'b010)||(op5 == 5'b01100 && func3 == 3'b010 &&func7[5] == 0)||(op5 == 5'b11000 && (func3 == 3'b000 || func3 == 3'b001||func3 == 3'b100||func3 == 3'b101)))?4'b0010:
    ((op5 == 5'b00100&&func3 == 3'b011)||(op5 == 5'b01100&&func3 == 3'b011&&func7[5] == 0)||(op5 == 5'b11000&&func3 == 3'b110)||(op5 == 5'b11000&&func3 == 3'b111))?4'b1010:
    ((op5 == 5'b00100&&func3 == 3'b100)||(op5 == 5'b01100&&func3 == 3'b100&&func7[5] == 0))?4'b0100:
    ((op5 == 5'b00100&&func3 == 3'b110)||(op5 == 5'b01100&&func3 == 3'b110))?4'b0110:
    ((op5 == 5'b00100&&func3 == 3'b111)||(op5 == 5'b01100&&func3 == 3'b111&&func7[5] == 0))?4'b0111:
    ((op5 == 5'b00100&&func3 == 3'b001&&func7[5] == 0)||(op5 == 5'b01100&&func3 == 3'b001&&func7[5] == 0))?4'b0001:
    ((op5 == 5'b00100&&func3 == 3'b101&&func7[5] == 0)||(op5 == 5'b01100&&func3 == 3'b101&&func7[5] == 0))?4'b0101:
    ((op5 == 5'b00100&&func3 == 3'b101&&func7[5] == 1)||(op5 == 5'b01100&&func3 == 3'b101&&func7[5] == 1))?4'b1101:
    (op5 == 5'b01100&&func3 == 3'b000&&func7[5] == 1)?4'b1000:4'b0000;

    assign Zero=(ALUctr == 4'b0010 && op5==5'b11000 && (func3==3'b000 || func3==3'b001))?1:0;
    assign Less=
    ((ALUctr == 4'b0010 && op5==5'b11000 && (func3==3'b100 || func3==3'b101) )||
    (ALUctr == 4'b1010 && op5==5'b11000 && (func3==3'b110 || func3==3'b111) ))?1:0;
    
endmodule
