`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2025 02:44:44 PM
// Design Name: 
// Module Name: apb_slave_wait
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


module apb_slave_wait
(
    input  pclk,
    input  presetn,
    input [3:0] paddr,
    input psel,
    input penable,
    input [7:0] pwdata,
    input pwrite,
    input s_wait,
    
    output reg [7:0] prdata,
    output reg pready
    
);

localparam[1:0] idle=0,write=1,read=2;
reg[7:0]mem[0:15]; //16*8bit 

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
    idle: 
        begin
        prdata = 8'h00;
        pready = 1'b0;
        next_state = psel?(pwrite?write:read):idle;
        end 
    write:
        begin
       
        if(psel==1'b1 && penable==1'b1)
        begin    
        if(s_wait)
        next_state = write;
        else begin
        pready=1'b1;
        mem[paddr]=pwdata;
        next_state=idle;
        end
        end
        else
        next_state=idle;
        end
    read:
        begin
        if(psel==1'b1 && penable==1'b1)
        begin
        if(s_wait)
        next_state = read;
        else begin
        pready=1'b1;
        prdata=mem[paddr];
        next_state=idle;
        end
        end
        else
        next_state=idle;
        end
    default: next_state=idle;
    endcase
end
    


endmodule
