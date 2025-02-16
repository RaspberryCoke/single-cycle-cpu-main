module execute(input wire clk,
               input wire rst,
               input wire[31:0] instr,
               input wire[31:0] pc,
               input wire[31:0] rs1,
               input wire[31:0] rs2,
               input wire[31:0] imm,
               input wire ALUAsrc,
               input wire[1:0] ALUBsrc,
               input wire[3:0] ALUctr,
               input wire[2:0] Branch,
               output wire Less,
               output wire Zero,
               output wire[31:0] Result,
               output wire[31:0] NextPC);
    //ALUAsrc ：宽度为1bit，选择ALU输入端A的来源。为0时选择rs1，为1时选择PC。
    //ALUBsrc ：宽度为2bit，选择ALU输入端B的来源。为00时选择rs2，为01时选择imm
    //(当是立即数移位指令时，只有低5位有效)，为10时选择常数4（用于跳转时计算返回地址PC+4）。
    //ALUctr ：宽度为4bit，选择ALU执行的操作
    //Branch ：宽度为3bit，说明分支和跳转的种类，用于生成最终的分支控制信号
    //MemtoReg ：宽度为1bit，选择寄存器rd写回数据来源，为0时选择ALU输出，为1时选择数据存储器输出。

    wire[4:0] op5=instr[6:2];
    wire[2:0] func3=instr[14:12];
    
    wire[31:0] ALU_A = ((ALUAsrc == 1)?pc:rs1);
    wire[31:0] ALU_B = 
    (ALUBsrc == 2'b00)?rs2:
    (ALUBsrc == 2'b01)?imm:
    (ALUBsrc == 2'b10)?4:0;//error
    
    assign Result = 
    (ALUctr == 4'b0000)?ALU_A+ALU_B://+
    (ALUctr == 4'b1000)?ALU_A-ALU_B://-
    (ALUctr == 4'b0111)?ALU_A & ALU_B://&
    (ALUctr == 4'b0110)?ALU_A | ALU_B:// |
    (ALUctr == 4'b0100)?ALU_A ^ ALU_B:// ^
    (ALUctr == 4'b0011)?ALU_B://拷贝立即数 lui
    (ALUctr == 4'b0001)?ALU_A << ALU_B[4:0]:// <<
    (ALUctr == 4'b0101)?ALU_A >> ALU_B[4:0]:// >>
    (ALUctr == 4'b1101)?( $signed($signed(ALU_A) >>> ALU_B[4:0]))://>>>    待测试
    (ALUctr == 4'b0010)?( $signed(($signed(ALU_A) < $signed(ALU_B)))?32'b1:32'b0)://slt    猜测
    (ALUctr == 4'b1010)?((ALU_A < ALU_B)?32'b1:32'b0)://sltu    猜测
    32'b0;

    assign Zero=(ALUctr == 4'b0010 && op5==5'b11000 && (func3==3'b000 || func3==3'b001) && (ALU_A==ALU_B))?1:0;
    assign Less=
    ((ALUctr == 4'b0010 && op5==5'b11000 && (func3==3'b100 || func3==3'b101) && ($signed(ALU_A)<$signed(ALU_B)))||
    (ALUctr == 4'b1010 && op5==5'b11000 && (func3==3'b110 || func3==3'b111) && (ALU_A<ALU_B)))?1:0;

    //计算PC
    wire PCAsrc=(Branch==3'b001||Branch==3'b010||(Branch==3'b100 && Zero==1)||(Branch==3'b101 && Zero==0)||(Branch==3'b110 && Less==1)||(Branch==3'b111&&Less==0))?1:0;
    wire PCBsrc=(Branch==3'b010)?1:0;
    wire[31:0]PCA=((PCAsrc==0)?32'h4:imm);
    wire[31:0]PCB=((PCBsrc==0)?pc:rs1);
    assign NextPC=PCA+PCB;


    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];

    wire load_byte               = (opcode == 7'b0000011) && (funct3 == 3'b000);  // lb
    wire load_half_word          = (opcode == 7'b0000011) && (funct3 == 3'b001);  // lh
    wire load_word               = (opcode == 7'b0000011) && (funct3 == 3'b010);  // lw
    wire load_byte_unsigned      = (opcode == 7'b0000011) && (funct3 == 3'b100);  // lbu
    wire load_half_word_unsigned = (opcode == 7'b0000011) && (funct3 == 3'b101);  // lhu
    wire store_byte              = (opcode == 7'b0100011) && (funct3 == 3'b000);  // sb
    wire store_half_word         = (opcode == 7'b0100011) && (funct3 == 3'b001);  // sh
    wire store_word              = (opcode == 7'b0100011) && (funct3 == 3'b010);  // sw

	wire load_instr=load_byte|load_half_word|load_word|load_byte_unsigned|load_half_word_unsigned;
	wire store_instr=store_byte|store_half_word|store_word;
// always@(*)begin
// 	if(op5==5'b01101)
// 		begin $display("\t[execute.v]:store instr::imm=%8h,ALU_A=%8h,ALU_B=%8h.\n\tinstr=%8h",imm,ALU_A,ALU_B,instr); end
// end
  
endmodule
    
