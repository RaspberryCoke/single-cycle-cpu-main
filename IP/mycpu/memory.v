//memory模块，仅供参考，可以随意修改
module memory(input wire clk,
              input wire rst,
              input wire[31:0] instr,
              input wire[31:0] execute_out,
              input wire MemtoReg,
              input wire[31:0] DataIn,
              output wire[31:0] DataOut);
    //MemtoReg ：宽度为1bit，选择寄存器rd写回数据来源，为0时选择ALU输出，
    //为1时选择数据存储器输出。
    import "DPI-C" function void dpi_mem_write(input int addr, input int data, int len);
    import "DPI-C" function int  dpi_mem_read (input int addr  , input int len);
    
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
    
    wire read_en = load_byte|load_half_word|load_word|load_byte_unsigned|load_half_word_unsigned;
    
    reg[31:0] mem_data_o;
    
    wire[31:0] load_byte_data        = {{24{mem_data_o[7]}}, mem_data_o[7:0]};
    wire[31:0] load_half_word_data   = {{16{mem_data_o[15]}}, mem_data_o[15:0]};
    wire[31:0] load_word_data        = mem_data_o;
    wire[31:0] load_byte_data_u      = {{24'b0},  mem_data_o[7:0]};
    wire[31:0] load_half_word_data_u = {{16'b0},  mem_data_o[15:0]};
    
    wire[31:0] read_data_out =  //读取操作的输出
    (load_byte)              ? load_byte_data        :
    (load_half_word)         ? load_half_word_data   :
    (load_word)              ? load_word_data        :
    (load_byte_unsigned)     ? load_byte_data_u      :
    (load_half_word_unsigned)? load_half_word_data_u : mem_data_o;
    
    assign DataOut=(MemtoReg==1)?read_data_out:addr;//注意这里：addr为ALU输出
    
    always @(*) begin
        if (read_en) begin
            mem_data_o = dpi_mem_read(addr, 4);
        end
        else begin
            mem_data_o = 32'b0;
        end
    end
    
    wire [31:0] data=DataIn;
    always @(posedge clk) begin
        if (store_byte) begin
            dpi_mem_write(addr, data, 1);
        end
        else if (store_half_word) begin
            dpi_mem_write(addr, data, 2);
        end
            else if (store_word) begin
            dpi_mem_write(addr, data, 4);
        end
    end
            
endmodule
            
