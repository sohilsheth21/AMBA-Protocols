module top(
input clk,rstn,wr,newd,s_wait,
input [3:0] ain,
input [7:0] din,
output [7:0] dout
);

wire psel,penable,pready,pwrite;
wire[7:0]prdata,pwdata;
wire[3:0]paddr;

apb_master_wait m1 (
        .pclk(clk),
        .presetn(rstn),
        .addrin(ain),
        .datain(din),
        .wr(wr),
        .newd(newd),
        .prdata(prdata),
        .pready(pready),
        .psel(psel),
        .penable(penable),
        .paddr(paddr),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .dataout(dout)
    );

apb_slave_wait s1 (
        .pclk(clk),
        .presetn(rstn),
        .paddr(paddr),
        .psel(psel),
        .penable(penable),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .prdata(prdata),
        .pready(pready),
        .s_wait(s_wait)
    );
    
    
    
endmodule
