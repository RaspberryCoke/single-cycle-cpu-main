module decode(input wire clk,
              input wire rst,
              input wire[31:0] instr,
              input wire[4:0] Ra,
              input wire[4:0] Rb,
              input wire[4:0] Rw,
              input wire RegWr,
              input wire[31:0] busW,
              output wire[31:0]busA,
              output wire[31:0]busB);
    
    regfile rf(
    .clk(clk),
    .rst(rst),
    .rs1_id_i(Ra),
    .rs2_id_i(Rb),
    .rs1_rdata_o(busA),
    .rs2_rdata_o(busB),
    .w_en(RegWr),
    .rd_id_i(Rw),
    .rd_write_data_i(busW)
    );
    
endmodule
