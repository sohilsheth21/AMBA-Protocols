`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2025 03:27:36 PM
// Design Name: 
// Module Name: apb_slave_error
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module apb_slave_error
(
    input  pclk,
    input  presetn,
    input [31:0] paddr,
    input psel,
    input penable,
    input [7:0] pwdata,
    input pwrite,
    
    output reg [7:0] prdata,
    output reg pready,
    output     pslverr
);

  localparam [1:0] idle = 0, write = 1, read = 2;
  reg [7:0] mem[0:15];
  
  reg [1:0] state, nstate;
  
  wire  addr_err , addv_err, data_err, setup_apb_err;

  ///// reset decoder
  always@(posedge pclk, negedge presetn)
    begin
      if(presetn == 1'b0)
          state <= idle;
      else
          state <= nstate;
    end
    
  always@(*)
    begin
    case(state)
     idle:
     begin
        prdata    = 8'h00;
        pready    = 1'b0;
        
            if(psel == 1'b1 && pwrite == 1'b1)  
                nstate = write;
            else if (psel == 1'b1 && pwrite == 1'b0)
                nstate = read;
            else
                nstate = idle;            
      end   
           
     
     write:
     begin
        if(psel == 1'b1 && penable == 1'b1)
        begin 
                 if(!addr_err && !addv_err && !data_err )
                    begin
                    pready = 1'b1;
                    mem[paddr]  = pwdata;
                    nstate      = idle;
                    end
                else
                     begin
                     nstate = idle;
                     pready = 1'b1;
                     end     
                 
     
        end
    end
     
    read:
     begin
        if(psel == 1'b1 && penable == 1'b1 )
        begin
            if(!addr_err && !addv_err && !data_err )
                 begin
                 pready = 1'b1;
                 prdata = mem[paddr];
                 nstate      = idle;
                 end
            else
                begin
                pready = 1'b1;
                prdata = 8'h00;
                nstate      = idle;
                end
        end
    end
     
    default : 
    begin
        nstate = idle; 
        prdata    = 8'h00;
        pready    = 1'b0;
     end
    endcase
    end

assign addr_err = ((nstate == write || read) && (paddr > 15)) ? 1'b1 : 1'b0;
assign addv_err = (nstate == write || read) ? (paddr>=0?1'b0:1'b1) : 1'b0;
assign data_err = (nstate == write || read) ?(pwdata>=0?1'b0:1'b1): 1'b0;

assign pslverr  = (psel == 1'b1 && penable == 1'b1) ? ( addv_err || addr_err || data_err) : 1'b0;

endmodule
