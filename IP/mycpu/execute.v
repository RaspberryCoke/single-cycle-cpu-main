module execute(
    input wire clk,
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
    output wire[31:0] NextPC
);
//ALUAsrc ：宽度为1bit，选择ALU输入端A的来源。为0时选择rs1，为1时选择PC。
//ALUBsrc ：宽度为2bit，选择ALU输入端B的来源。为00时选择rs2，为01时选择imm
//(当是立即数移位指令时，只有低5位有效)，为10时选择常数4（用于跳转时计算返回地址PC+4）。
//ALUctr ：宽度为4bit，选择ALU执行的操作
//Branch ：宽度为3bit，说明分支和跳转的种类，用于生成最终的分支控制信号
//MemtoReg ：宽度为1bit，选择寄存器rd写回数据来源，为0时选择ALU输出，为1时选择数据存储器输出。
    wire[31:0] ALU_A;
    wire[31:0] ALU_B;

    assign ALU_A=ALUAsrc==1?pc:rs1;
    assign ALU_B=(ALUBsrc==2'b00)?rs2:
    (ALUBsrc==2'b01)?imm:
    (ALUBsrc==2'b10)?4:0;//error

    assign Result=(ALUctr==4'b)

endmodule

