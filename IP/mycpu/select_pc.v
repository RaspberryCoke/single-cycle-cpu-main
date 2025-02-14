//select模块，仅供参考，可以随意修改
module select_pc(
    output wire[31:0] pc
);


always @(posedge clk) begin
    if(rst) begin
        pc <= 32'h80000000;
    end
end
endmodule