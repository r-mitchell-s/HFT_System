
module eth_header_gen(
    input i_clk, i_rst,
    output o_rst
    );
    
    // rst_gen for crossing reset domains 
    logc [2:0] l_rst;
    
    // the input reset is triple-registered
    always @(posedge i_clk) begin
        l_rst[0] <= i_rst;
        l_rst[2:1] <= l_rst[1:0];
    end
    
    // actually assert reset signal when internal reset signal is all 0s
    assign o_rst = (l_rst == 0) ? 1 : 0;
    
endmodule