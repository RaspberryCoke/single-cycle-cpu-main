module decode(input wire clk,
              input wire rst,
              input wire[31:0] instr,
              input wire[31:0] pc,

              input wire WBtoDEC_REG_WRITE_EN_IN,//from writeback
              input wire[4:0] WBtoDEC_REG_ID_IN,//from writeback
              input wire[31:0] WBtoDEC_DATA_IN,//from writeback

              output wire[31:0]REG_VALUE_OUT1,
              output wire[31:0]REG_VALUE_OUT2
              );

    
               wire[4:0] reg_id1=instr[19:15];
               wire[4:0] reg_id2=instr[24:20];

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
               output wire[31:0]Imm)
               output wire[31:0]rs1,
              output wire[31:0]rs2



    regfile rf(
    .clk(clk),
    .rst(rst),
    .instr_debug(instr),
    .pc_debug(pc)
    .rs1_id_i(reg_id1),
    .rs2_id_i(reg_id2),
    .rs1_rdata_o(REG_VALUE_OUT1),
    .rs2_rdata_o(REG_VALUE_OUT2),
    .w_en(WBtoDEC_REG_WRITE_EN_IN,
    .rd_id_i(WBtoDEC_REG_ID_IN),
    .rd_write_data_i(WBtoDEC_DATA_IN),
    );
    
endmodule
