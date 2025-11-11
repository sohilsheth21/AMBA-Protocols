module axi_s_s(
input wire s_aclk,
input wire s_resetn,
output wire s_tready,
output wire[7:0] dout,
input wire s_tvalid,
input wire [7:0] s_tdata,
input wire s_tlast
    );
    
    
    typedef enum bit {idle=0, rx=1} state_t;
    state_t state = idle;;
    state_t next_state =idle;
    
    
    always @(posedge s_aclk) begin
    if(!s_resetn)
    state<=idle;
    else
   state<=next_state;
   end
   
   always @(*) begin
   case(state) 
   idle: next_state = (s_tvalid)?rx:idle;
   rx: next_state = (!s_tlast && s_tvalid)?rx:idle;
   default: next_state=idle;
   endcase
   end
  
   
    
   assign dout = (state ==rx)?s_tdata:8'h00;;
   assign s_tready = (state==rx);
   
endmodule