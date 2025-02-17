module decode(input wire clk,
              input wire rst,
              input wire[31:0] instr,
              input wire[31:0] pc,

              input wire WRITEBACK_TO_DECODE_REG_WRITE_EN_IN,//from writeback
              input wire[4:0] WRITEBACK_TO_DECODE_REG_ID_IN,//from writeback
              input wire[31:0] WRITEBACK_TO_DECODE_DATA_IN,//from writeback

              output wire[31:0]REG_VALUE_OUT1,
              output wire[31:0]REG_VALUE_OUT2
              );

    
               wire[4:0] reg_id1=instr[19:15];
               wire[4:0] reg_id2=instr[24:20];







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
