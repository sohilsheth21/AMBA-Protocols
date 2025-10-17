`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 06:28:35 PM
// Design Name: 
// Module Name: apb_master
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


module apb_master(
    input pclk,
    input presetn,
    input [3:0] addrin,
    input [7:0] datain,
    input wr,
    input newd,
    input [7:0] prdata,
    input pready,
    
    output reg psel,
    output reg penable,
    output reg slverr,
    output reg [3:0] paddr,
    output reg [7:0] pwdata,
    output reg pwrite,
    output  [7:0] dataout
    );
    
    localparam[1:0]idle=0, setup=1, access=2;
    reg[1:0]state,next_state;
    
    always @(posedge pclk or negedge presetn) 
    begin
    if(!presetn)
    state<=idle;
    else
    state<=next_state;
    end
    
    always @(*)
    begin
        case(state)
        idle: next_state = newd?setup:idle;
        setup: next_state = access;
        access: next_state = newd?(pready?setup:access):idle;
        default: next_state = idle;
        endcase
    end
    
    //address
    always @(posedge pclk or negedge presetn)
    begin
        if(!presetn) 
        psel<=1'b0;
        else if(next_state==idle)
        psel<=1'b0;
        else if(next_state==access||next_state==setup)
        psel<=1'b1;
        else
        psel<=1'b0;
    end
    
    always @(posedge pclk or negedge presetn)
    begin
        if(!presetn)
        begin
            penable<=1'b0;
            paddr<=4'h0;
            pwdata<=8'h00;
            pwrite<=1'b0;
        end
        else if(next_state==idle)
        begin
            penable<=1'b0;
            paddr<=4'h0;
            pwdata<=8'h00;
            pwrite<=1'b0;
        end
        else if(next_state==setup)
        begin
            penable<=1'b0;
            paddr<=addrin;
            pwrite<=wr;
            if(wr) 
            pwdata<=datain;
        end
        else if(next_state==access)
        begin
            penable<=1'b1;
          
        end
    end
    
   assign dataout = (psel == 1'b1 &&  penable == 1'b1 && wr == 1'b0) ? prdata : 8'h00;

        
endmodule
