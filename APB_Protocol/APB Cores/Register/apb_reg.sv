module apb_reg (
    input  wire                   rst,        // Reset input
    input  wire                   pclk,       // APB clock input
    input  wire                   presetn,    // APB reset input
    input  wire                   psel,       // APB select input
    input  wire [31:0]            paddr,      // APB address input
    input  wire [31:0]            pwdata,     // APB write data input
    input  wire                   penable,    // APB enable input
    input  wire                   pwrite,     // APB write enable input
    output reg  [31:0]            prdata,     // APB read data output
    output reg                    pready      // APB read data ready output
);

parameter GPIO_REG_ADDR = 32'h0000_0000;
parameter idle = 3'b000, check_op = 3'b001, write_data = 3'b010, read_data =3'b011,send_ready = 3'b100; //states

reg [2:0] state = idle;
reg [31:0] addr,wdata;
reg [31:0] GPIO_REG = 32'h0;


always @(posedge pclk or negedge rst) begin
    if (rst == 0) begin
        pready <= 0;
        state   <= idle;
        prdata <= 0;
        addr   <= 0;
        wdata  <= 0; 
    end else begin
        case(state)
        idle:
        begin
            pready <= 0;
            prdata <= 0;
            addr   <= 0;
            wdata  <= 0;
            state <= check_op;
        end
        
        check_op:
        begin
         if (penable && psel && pwrite && paddr == 0 )
         begin 
            state   <= write_data;
            addr    <= paddr;
            wdata   <= pwdata;
         end
         else if (penable && psel && !pwrite && paddr == 0)
         begin
            state  <= read_data;
            addr   <= paddr;
         end
         else 
            state  <= check_op;
        end
        
        write_data:
        begin
            GPIO_REG <= wdata;
            pready <= 1'b1;
            state <= send_ready;
        end
        
        read_data : 
        begin
            pready <= 1'b1;
            prdata <= GPIO_REG;
            state <= send_ready;
        end
        
        send_ready: 
        begin
           state  <= check_op;
           pready <= 1'b0;    
         end
     
     endcase
     
     end
        
   end  
endmodule