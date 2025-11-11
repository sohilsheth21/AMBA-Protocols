module top(input clk, 
input areset, 
input newd, 
input [7:0] din,
output [7:0] dout);

wire last, valid, ready;
wire [7:0] data; 

    
    axi_s_m master (
    .m_aclk(clk),
    .m_resetn(areset),
    .newd(newd),
    .m_tready(ready),
    .din(din),
    .m_tvalid(valid),
    .m_tdata(data),
    .m_tlast(last)
);

axi_s_s slave (
    .s_aclk(clk),
    .s_resetn(areset),
    .s_tready(ready),
    .s_tvalid(valid),
    .s_tdata(data),
    .s_tlast(last),
    .dout(dout)
);

endmodule