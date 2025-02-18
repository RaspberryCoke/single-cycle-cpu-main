`include "define.v"
module decode(input wire clk,
              input wire rst,
              input wire[31:0] instr,
              input wire[31:0] pc,

              input wire WRITEBACK_TO_DECODE_REG_WRITE_EN_IN,//from writeback
              input wire[4:0] WRITEBACK_TO_DECODE_REG_ID_IN,//from writeback
              input wire[31:0] WRITEBACK_TO_DECODE_DATA_IN,//from writeback

              output wire[31:0]REG_VALUE_OUT1,
              output wire[31:0]REG_VALUE_OUT2,
              output wire[31:0]IMM_OUT
              );
    wire[4:0] reg_id1=instr[19:15];
    wire[4:0] reg_id2=instr[24:20];

//region 初始化变量
    //!注意：后期使用不到可以删除某些变量！
    wire[6:0]  op    = instr[6:0];
    wire[4:0]  rs1   = instr[19:15];
    wire[4:0]  rs2   = instr[24:20];
    wire[4:0]  rd    = instr[11:7];
    wire[2:0]  func3 = instr[14:12];
    wire[6:0]  func7 = instr[31:25];

    wire Zero;
    wire Less;
    wire LargerOrEqual;
    wire[2:0] Branch;
    wire[31:0] ALU_A;
    wire[31:0] ALU_B;
    
    
    wire lui    = (op == 7'b0110111);
    wire auipc  = (op == 7'b0010111);
    wire jal    = (op == 7'b1101111);
    wire jalr   = (op == 7'b1100111 && func3 == 3'b000);
    wire beq    = (op == 7'b1100011 && func3 == 3'b000);
    wire bne    = (op == 7'b1100011 && func3 == 3'b001);
    wire blt    = (op == 7'b1100011 && func3 == 3'b100);
    wire bge    = (op == 7'b1100011 && func3 == 3'b101);
    wire bltu   = (op == 7'b1100011 && func3 == 3'b110);
    wire bgeu   = (op == 7'b1100011 && func3 == 3'b111);
    wire lb     = (op == 7'b0000011 && func3 == 3'b000);
    wire lh     = (op == 7'b0000011 && func3 == 3'b001);
    wire lw     = (op == 7'b0000011 && func3 == 3'b010);
    wire lbu    = (op == 7'b0000011 && func3 == 3'b100);
    wire lhu    = (op == 7'b0000011 && func3 == 3'b101);
    wire sb     = (op == 7'b0100011 && func3 == 3'b000);
    wire sh     = (op == 7'b0100011 && func3 == 3'b001);
    wire sw     = (op == 7'b0100011 && func3 == 3'b010);
    wire addi   = (op == 7'b0010011 && func3 == 3'b000);
    wire slti   = (op == 7'b0010011 && func3 == 3'b010);
    wire sltiu  = (op == 7'b0010011 && func3 == 3'b011);
    wire xori   = (op == 7'b0010011 && func3 == 3'b100);
    wire ori    = (op == 7'b0010011 && func3 == 3'b110);
    wire andi   = (op == 7'b0010011 && func3 == 3'b111);
    wire slli   = (op == 7'b0010011 && func3 == 3'b001 && func7 == 7'b0000000);
    wire srli   = (op == 7'b0010011 && func3 == 3'b101 && func7 == 7'b0000000);
    wire srai   = (op == 7'b0010011 && func3 == 3'b101 && func7 == 7'b0100000);
    wire add    = (op == 7'b0110011 && func3 == 3'b000 && func7 == 7'b0000000);
    wire sub    = (op == 7'b0110011 && func3 == 3'b000 && func7 == 7'b0100000);
    wire sll    = (op == 7'b0110011 && func3 == 3'b001 && func7 == 7'b0000000);
    wire slt    = (op == 7'b0110011 && func3 == 3'b010 && func7 == 7'b0000000);
    wire sltu   = (op == 7'b0110011 && func3 == 3'b011 && func7 == 7'b0000000);
    wire xor_   = (op == 7'b0110011 && func3 == 3'b100 && func7 == 7'b0000000);
    wire srl    = (op == 7'b0110011 && func3 == 3'b101 && func7 == 7'b0000000);
    wire sra    = (op == 7'b0110011 && func3 == 3'b101 && func7 == 7'b0100000);
    wire or_    = (op == 7'b0110011 && func3 == 3'b110 && func7 == 7'b0000000);
    wire and_   = (op == 7'b0110011 && func3 == 3'b111 && func7 == 7'b0000000);
    wire fence  = (op == 7'b0001111 && func3 == 3'b000);
    wire ecall  = (op == 7'b1110011 && func3 == 3'b000 && func7 == 7'b0000000);
    wire ebreak = (op == 7'b1110011 && func3 == 3'b000 && func7 == 7'b0000001);
    //endregion
    
    //region 进行立即数的处理
    wire[31:0] ImmI = {{20{instr[31]}}, instr[31:20]};
    wire[31:0] ImmU = {instr[31:12], 12'b0};
    wire[31:0] ImmS = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire[31:0] ImmB = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    wire[31:0] ImmJ = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
    
    wire[2:0] Create_Imm_Operation = //num:37
    ((addi || slti || sltiu || xori || ori || andi || slli ||srli || srai||jalr||lb||lh||lw||lbu||lhu))?`IMMI:// 15条
    (lui || auipc)?`IMMU:
    (jal)?`IMMJ:
    (beq || bne || blt || bge || bltu || bgeu)?`IMMB:
    (sb||sh||sw)?`IMMS:
    (add || sub || sll || slt || sltu || xor_ || srl || sra || or_ || and_)?`IMM_NONE:
    `IMM_ERR; // wrong case or other instruction
    //TODO 将来添加指令考虑此处
    
    assign IMM_OUT = 
    (Create_Imm_Operation == `IMMI)?ImmI:
    (Create_Imm_Operation == `IMMU)?ImmU:
    (Create_Imm_Operation == `IMMS)?ImmS:
    (Create_Imm_Operation == `IMMB)?ImmB:
    (Create_Imm_Operation == `IMMJ)?ImmJ:32'b0;

    //endregion

    regfile rf(
    .clk(clk),
    .rst(rst),
    .instr_debug(instr),
    .pc_debug(pc),
    .rs1_id_i(reg_id1),
    .rs2_id_i(reg_id2),
    .rs1_rdata_o(REG_VALUE_OUT1),
    .rs2_rdata_o(REG_VALUE_OUT2),
    .w_en(WRITEBACK_TO_DECODE_REG_WRITE_EN_IN),
    .rd_id_i(WRITEBACK_TO_DECODE_REG_ID_IN),
    .rd_write_data_i(WRITEBACK_TO_DECODE_DATA_IN)
    );
    
endmodule
