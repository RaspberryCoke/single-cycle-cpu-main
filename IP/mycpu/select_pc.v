//select模块，仅供参考，可以随意修改
module select_pc(
    input clk,
    input rst,
    input wire[31:0] NextPC,
    output reg[31:0] pc
);


always @(posedge clk) begin
    if(rst) begin
        pc <= 32'h80000000;
    end else begin 
        pc<=NextPC;
    end

end
endmodule