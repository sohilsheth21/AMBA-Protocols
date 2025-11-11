module top_tb();

reg clk = 0;
reg rst;
reg newd;
reg [7:0] din;
wire [7:0] dout;

top dut (
    .clk(clk),
    .areset(rst),
    .newd(newd),
    .din(din),
    .dout(dout)
);

always #10 clk = ~clk;

initial begin
    // Initialize
    rst  = 1'b0;
    newd = 1'b0;
    din  = 8'b0;

    repeat (10) @(posedge clk);
    rst = 1'b1;

    // Send multiple data bursts (simulate 10 transactions)
    for (int i = 0; i < 10; i++) begin
        @(posedge clk);
        newd = 1;
        din  = $urandom_range(0, 15);

        
        repeat (4) @(posedge clk);  // previously 4-beat packet
        newd = 0;

        // delay between packets
        repeat (2) @(posedge clk);
    end

    $finish;
end

endmodule
