`timescale 1ns/1ps
`default_nettype none

module tb_apb_master;
  // Clock and reset
  reg  pclk    = 1'b0;
  reg  presetn = 1'b0;

  // Master stimulus to DUT
  reg  [3:0] addrin = 4'h0;
  reg  [7:0] datain = 8'h00;
  reg        wr     = 1'b0;
  reg        newd   = 1'b0;

  // Slave return signals
  reg  [7:0] prdata = 8'h00;
  reg        pready = 1'b0;

  // DUT outputs
  wire       psel;
  wire       penable;
  wire       slverr;
  wire [3:0] paddr;
  wire [7:0] pwdata;
  wire       pwrite;
  wire [7:0] dataout;

  // DUT instance (original module name)
  apb_master dut (
    .pclk    (pclk),
    .presetn (presetn),
    .addrin  (addrin),
    .datain  (datain),
    .wr      (wr),
    .newd    (newd),
    .prdata  (prdata),
    .pready  (pready),
    .psel    (psel),
    .penable (penable),
    .slverr  (slverr),
    .paddr   (paddr),
    .pwdata  (pwdata),
    .pwrite  (pwrite),
    .dataout (dataout)
  );

  // 50 MHz clock
  always #10 pclk = ~pclk;

  // Simple APB write: single-cycle completion
  task automatic apb_write(input [3:0] addr, input [7:0] data);
    begin
      @(negedge pclk);
      // Drive request during SETUP
      addrin <= addr;
      datain <= data;
      wr     <= 1'b1;
      newd   <= 1'b1;
      pready <= 1'b0; // slave not ready yet

      @(posedge pclk); // enter SETUP -> ACCESS (DUT asserts PENABLE next)
      // Wait for ACCESS phase, then complete transfer
      wait (penable === 1'b1 && psel === 1'b1);
      pready <= 1'b1; // complete this cycle

      @(posedge pclk); // transfer completes here
      // Deassert request and get ready for next transfer
      newd   <= 1'b0;
      wr     <= 1'b0;
      pready <= 1'b0;

      // Optional checks
      $display("%0t WRITE  addr=0x%0h data=0x%0h paddr=0x%0h pwdata=0x%0h",
               $time, addr, data, paddr, pwdata);
    end
  endtask

  // Simple APB read: returns provided rdata in ACCESS
  task automatic apb_read(input [3:0] addr, input [7:0] rdata);
    reg [7:0] sample;
    begin
      @(negedge pclk);
      // Drive request during SETUP
      addrin <= addr;
      wr     <= 1'b0;
      newd   <= 1'b1;
      prdata <= rdata; // what the slave will return
      pready <= 1'b0;

      @(posedge pclk); // enter SETUP -> ACCESS
      // Wait for ACCESS and then present ready
      wait (penable === 1'b1 && psel === 1'b1);
      // Data is valid when {PSEL,PENABLE,~PWRITE} are all true
      pready <= 1'b1;
      @(negedge pclk);
      sample = dataout;

      @(posedge pclk); // complete
      newd   <= 1'b0;
      pready <= 1'b0;

      // Check
      if (sample !== rdata) begin
        $error("%0t READ MISMATCH addr=0x%0h got=0x%0h exp=0x%0h",
               $time, addr, sample, rdata);
      end else begin
        $display("%0t READ   addr=0x%0h data=0x%0h OK",
                 $time, addr, sample);
      end
    end
  endtask

  initial begin
    // Apply reset
    presetn = 1'b0;
    pready  = 1'b0;
    repeat (3) @(posedge pclk);
    presetn = 1'b1;

    // Run a write then a read
    apb_write(4'h4, 8'hFF);
    apb_read (4'h4, 8'hA5);

    // Back-to-back example (keep NEWD high into next SETUP)
    @(negedge pclk);
    addrin <= 4'h1; datain <= 8'h12; wr <= 1'b1; newd <= 1'b1; pready <= 1'b0;
    @(posedge pclk);
    wait (penable && psel); pready <= 1'b1;
    @(posedge pclk);
    // Immediately start next transfer by keeping NEWD=1 and changing addr/data
    addrin <= 4'h2; datain <= 8'h34; wr <= 1'b1; pready <= 1'b0;
    @(posedge pclk);
    wait (penable && psel); pready <= 1'b1;
    @(posedge pclk);
    newd <= 1'b0; wr <= 1'b0; pready <= 1'b0;

    #50;
    $finish;
  end

endmodule

`default_nettype wire
