`include"define.v"
module execute(input wire clk,
               input wire rst,
               input wire[31:0] instr,
               input wire[31:0] pc,
               input wire[31:0] REG_VALUE_IN1,
               input wire[31:0] REG_VALUE_IN2,
               output wire[31:0] EXECUTE_OUT,
               output wire[31:0] NextPC);
    
    
    //region 说明
    
    //ALUAsrc ：宽度为1bit，选择ALU输入端A的来源。为0时选择rs1，为1时选择PC。
    //ALUBsrc ：宽度为2bit，选择ALU输入端B的来源。为00时选择rs2，为01时选择imm
    //(当是立即数移位指令时，只有低5位有效)，为10时选择常数4（用于跳转时计算返回地址PC+4）。
    //ALU_Operation ：宽度为4bit，选择ALU执行的操作
    //Branch ：宽度为3bit，说明分支和跳转的种类，用于生成最终的分支控制信号
    //MemtoReg ：宽度为1bit，选择寄存器rd写回数据来源，为0时选择ALU输出，为1时选择数据存储器输出。

    //endregion
    
    //region 初始化变量
    //!注意：后期使用不到可以删除某些变量！
    wire[6:0]  op    = instr[6:0];
    wire[4:0]  rs1   = instr[19:15];
    wire[4:0]  rs2   = instr[24:20];
    wire[4:0]  rd    = instr[11:7];
    wire[2:0]  func3 = instr[14:12];
    wire[6:0]  func7 = instr[31:25];
    wire[4:0] op5    = op[6:2];
    wire[31:0] Imm;
    wire ImmValid;
    wire ALUAsrc;
    wire[1:0] ALUBsrc;
    wire[3:0] ALU_Operation;
    wire Zero;
    wire Less;
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
    `IMM_ERR; // wrong case
    
    //!错误处理
    always@(*)begin
        if (Create_Imm_Operation == `IMM_ERR)begin
            $display("[execute.v]:Create_Imm_Operation == `IMM_ERR ERROR!");
            $display("[execute.v]:stop!");
            $stop;
        end
    end
    
    assign Imm = 
    (Create_Imm_Operation == `IMMI)?ImmI:
    (Create_Imm_Operation == `IMMU)?ImmU:
    (Create_Imm_Operation == `IMMS)?ImmS:
    (Create_Imm_Operation == `IMMB)?ImmB:
    (Create_Imm_Operation == `IMMJ)?ImmJ:32'b0;
    
    assign ImmValid = (Create_Imm_Operation == `IMM_ERR)?0:1;
    //endregion
    
    
    //region ALU的两个操作数A,B赋值
    assign ALU_A = ((auipc || jal || jalr)?pc:REG_VALUE_IN1);
    assign ALU_B = //37
    (add || sub|| sll||slt||sltu||xor_||srl||sra||or_||and_ || beq || bne || blt || bge || bltu || bgeu)?REG_VALUE_IN2:
    (lui || auipc|| addi|| slti|| sltiu|| xori||ori||andi||slli||srli||srai||lb||lh||lw||lbu||lhu||sb||sh||sw)?Imm:
    (jal || jalr)?4:
    0;//error or other instructions.
    //endregion
    
    
    //region 选择ALU执行的具体操作
    assign ALU_Operation = //37
    (lui)?`COPY:
    (slt || slti ||beq || bne || blt || bge)?`SET_LESS_SIGNED:
    (sltiu||sltu||bltu||bgeu)?`SET_LESS_UNSIGNED:
    (xori||xor_)?`XOR:
    (ori||or_)?`OR:
    (andi||and_)?`AND:
    (slli||sll)?`LEFT_SHIFT:
    (srli||srl)?`RIGHT_SHIFT_UNSIGNED:
    (srai||sra)?`RIGHT_SHIFT_SIGNED:
    (sub)?`SUB:
    (auipc||addi||add||jal||jalr||lb||lh||lw||lbu||lhu||sb||sh||sw)?`ADD:
    `UNDEFINEED_EXECUTE_OPERATION;//undefined operation
    //endregion
    
    
    //region 计算结果
    assign EXECUTE_OUT = 
    (ALU_Operation == `ADD)?ALU_A+ALU_B://+
    (ALU_Operation == `SUB)?ALU_A-ALU_B://-
    (ALU_Operation == `AND)?ALU_A & ALU_B://&
    (ALU_Operation == `OR)?ALU_A | ALU_B:// |
    (ALU_Operation == `XOR)?ALU_A ^ ALU_B:// ^
    (ALU_Operation == `COPY)?ALU_B://拷贝立即数 lui
    (ALU_Operation == `LEFT_SHIFT)?ALU_A << ALU_B[4:0]:// <<
    (ALU_Operation == `RIGHT_SHIFT_UNSIGNED)?ALU_A >> ALU_B[4:0]:// >>
    (ALU_Operation == `RIGHT_SHIFT_SIGNED)?($signed($signed(ALU_A) >>> ALU_B[4:0]))://>>>算术右移
    (ALU_Operation == `SET_LESS_SIGNED)?($signed(($signed(ALU_A) < $signed(ALU_B)))?32'b1:32'b0)://slt
    (ALU_Operation == `SET_LESS_UNSIGNED)?((ALU_A < ALU_B)?32'b1:32'b0)://sltu
    32'b0;
    //endregion
    
    //region 是否跳转、计算NextPC  
    // TODO :Less
    assign Zero = ((beq || bne) && (ALU_A == ALU_B))?1:0;
    assign Less = 
    (((blt||bge) && ($signed(ALU_A)<$signed(ALU_B)))||
    ((bltu||bgeu) && (ALU_A<ALU_B)))?1:0;
    
    wire PCAsrc = 
    (Branch == `ALWAYS_JUMP_PC_ADD_IMM||Branch == `ALWAYS_JUMP_REG_ADD_IMM||
    (Branch == `TEST_EQUAL_JUMP && Zero == 1)||(Branch == `TEST_NOT_EQUAL_JUMP && Zero == 0)||
    (Branch == `TEST_LESS_THAN_JUMP && Less == 1)||(Branch == `TEST_LARGER_OR_EQUAL_JUMP&&Less == 0))?1:0;
    wire PCBsrc   = (Branch == `ALWAYS_JUMP_REG_ADD_IMM)?1:0;
    wire[31:0]PCA = ((PCAsrc == 0)?32'h4:Imm);
    wire[31:0]PCB = ((PCBsrc == 0)?pc:REG_VALUE_IN1);
    assign NextPC = PCA+PCB;
    //endregion
    
endmodule
    
