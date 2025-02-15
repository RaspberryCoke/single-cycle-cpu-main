module decode(input wire clk,
              input wire rst,
              input wire[31:0] instr,
              input wire[4:0] Ra,
              input wire[4:0] Rb,
              input wire[4:0] Rw,//from writeback
              input wire RegWr,//from writeback
              input wire[31:0] busW,//from writeback
              output wire[31:0]rs1,
              output wire[31:0]rs2,
              output wire [31:0] regfile_for_simulator[31:0]
              );
    
    regfile rf(
    .clk(clk),
    .rst(rst),
    .rs1_id_i(Ra),
    .rs2_id_i(Rb),
    .rs1_rdata_o(rs1),
    .rs2_rdata_o(rs2),
    .w_en(RegWr),
    .rd_id_i(Rw),
    .rd_write_data_i(busW),
    .regfile_for_simulator(regfile_for_simulator)
    );
    
endmodule
