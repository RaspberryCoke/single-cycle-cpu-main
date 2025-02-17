module memory(input wire clk,
              input wire rst,
              input wire[31:0] instr,
              input wire[31:0] pc,
              input wire[31:0] EXECUTE_IN,
              input wire[31:0] REG_VALUE_OUT2,
              output wire[31:0] MEMORY_OUT);
    //MemtoReg ：宽度为1bit，选择寄存器rd写回数据来源，为0时选择ALU输出，
    //为1时选择数据存储器输出。
    import "DPI-C" function void dpi_mem_write(input int addr, input int data, int len);
    import "DPI-C" function int  dpi_mem_read (input int addr  , input int len);
    
    wire [6:0] op    = instr[6:0];
    wire [2:0] func3 = instr[14:12];
    
    wire lb  = (op == 7'b0000011 && func3 == 3'b000);
    wire lh  = (op == 7'b0000011 && func3 == 3'b001);
    wire lw  = (op == 7'b0000011 && func3 == 3'b010);
    wire lbu = (op == 7'b0000011 && func3 == 3'b100);
    wire lhu = (op == 7'b0000011 && func3 == 3'b101);
    wire sb  = (op == 7'b0100011 && func3 == 3'b000);
    wire sh  = (op == 7'b0100011 && func3 == 3'b001);
    wire sw  = (op == 7'b0100011 && func3 == 3'b010);
    
    wire read_en  = lb|lh|lw|lbu|lhu;
    wire write_en = sw|sh|sb;
    
    reg[31:0] mem_data_o;
    
    wire[31:0] load_byte_data        = {{24{mem_data_o[7]}}, mem_data_o[7:0]};
    wire[31:0] load_half_word_data   = {{16{mem_data_o[15]}}, mem_data_o[15:0]};
    wire[31:0] load_word_data        = mem_data_o;
    wire[31:0] load_byte_data_u      = {{24'b0},  mem_data_o[7:0]};
    wire[31:0] load_half_word_data_u = {{16'b0},  mem_data_o[15:0]};
    
    wire[31:0] read_data_out = //读取操作的输出
    (lb)? load_byte_data        :
    (lh)? load_half_word_data   :
    (lw)? load_word_data        :
    (lbu)? load_byte_data_u     :
    (lhu)? load_half_word_data_u: 32'b0;
    
    wire MemtoReg = //
    //* ALU to REG
    (op == 7'b0110111 ||//lui
    op == 7'b0010111 ||//auipc
    op == 7'b0010011 ||//[addi,slti,sltiu,xori,ori,andi,slli,srli,srai]
    op == 7'b0110011 ||//[add,sub,sll,slt,sltu,xor,srl,sra,or,and]
    op == 7'b1101111 ||//jal
    op == 7'b1100111)?0://jalr
    //* MEM to REG
    (op == 7'b0000011)?1://[lb,lh,lw,lbu,lhu] MEM to REG,Load
    (op == 7'b0100011)?1://*注意：[sb,sh,sw]在这里取指0或者1都可以，因为不写回REG。
    //TODO 将来扩展指令应注意。
    //* other instructions
    0;

    
    assign MEMORY_OUT = (MemtoReg == 1)?read_data_out:EXECUTE_IN;//
    
    wire[31:0]addr = EXECUTE_IN;
    always @(*) begin
        if (read_en) begin
            mem_data_o = dpi_mem_read(addr, 4);
            //$display("\t[memory.v]: read data from memory,addr is %8h,data is %8h.",addr,mem_data_o);
        end
        else begin
            mem_data_o = 32'b0;
        end
    end
    
    wire [31:0] data = REG_VALUE_OUT2;
    always @(posedge clk) begin
        if (sb) begin
            dpi_mem_write(addr, data, 1);
            //$display("\t[memory.v]: write data to memory,addr is %8h,data is %8h.",addr,data);
        end
        else if (sh) begin
            dpi_mem_write(addr, data, 2);
            //$display("\t[memory.v]: write data to memory,addr is %8h,data is %8h.",addr,data);
        end
        else if (sw) begin
            dpi_mem_write(addr, data, 4);
            //$display("\t[memory.v]: write data to memory,addr is %8h,data is %8h.",addr,data);
        end
    end
            
endmodule
            
