module writeback(
    input wire clk,
    input wire rst,
    input wire[31:0] instr,
    input wire[31:0] memory_out,
    output wire[31:0] wb_to_reg_data,
    output wire[4:0] wb_to_reg_num,
    output wire wb_to_reg_en
);
    wire[4:0] op5= instr[6:2];
    assign wb_to_reg_en = (op5 == 5'b11000 || op5 == 5'b01000)?0:1;//[store,banch]->0,else->1 
    assign wb_to_reg_num=instr[11:7];
    assign wb_to_reg_data=memory_out;
endmodule