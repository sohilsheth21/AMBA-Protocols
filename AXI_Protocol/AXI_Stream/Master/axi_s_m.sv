`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 03:38:46 PM
// Design Name: 
// Module Name: axi_s_m
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


module axi_s_m(
input wire m_aclk,
input wire m_resetn,
input wire newd,
input wire m_tready,
input wire[7:0] din,
output wire m_tvalid,
output wire [7:0] m_tdata,
output wire m_tlast
    );
    
    reg [2:0] count=0; //keeping stream count fixed to 3
    typedef enum bit {idle=0, tx=1} state_t;
    state_t state = idle;;
    state_t next_state =idle;
    
    
    always @(posedge m_aclk) begin
    if(!m_resetn)
    state<=idle;
    else
   state<=next_state;
   end
   
   always @(*) begin
   case(state) 
   idle: next_state = (newd)?tx:idle;
   tx: next_state = m_tready?((count!=3)?tx:idle):tx;
   default: next_state=idle;
   endcase
   end
   
   always @(posedge m_aclk) begin 
   if(state==idle)
   count<=0;
   else if(state ==tx && count!=3 && m_tready)
   count<=count+1;
   else count<=count;
   end
   
    
   assign m_tdata=(m_tvalid)?din*count:0; //just to show different bytes
   assign m_tvalid = (state==tx)?1:0; //assuming that data is always valid when slave is ready
   assign m_tlast = (count==3&&state==tx)?1'b1:1'b0;
   
   
endmodule
