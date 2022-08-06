module router_fifo(clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,data_out,empty,full);

// defining parameters

parameter FIFO_WIDTH = 9,
          FIFO_DEPHT = 16,
		  ADDR_SIZE = 4;
		  
//defining input output ports
		  
input clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
input [FIFO_WIDTH-2:0]data_in;
output reg [FIFO_WIDTH-2:0]data_out;
output  empty,full;

//defining the memory size and counters for read,write and for storing the total size of payload+parity bit
	  
reg [FIFO_WIDTH-1:0]mem[FIFO_DEPHT-1:0];
reg [ADDR_SIZE-1:0]wr_ptr,rd_ptr;
reg [ADDR_SIZE:0]fifo_count;
reg [6:0]counter;
reg temp;

integer i;

//reset logic

always @(posedge clock)
  begin
   temp <= (!resetn||soft_reset) ? 1'b0 : lfd_state;
    if(!resetn)
	 begin
	  for(i=0;i<FIFO_DEPHT;i=i+1)
	   mem[i] <= 9'd0;
	   {rd_ptr, wr_ptr} <= 8'd0;
       data_out <= 8'd0;
     end
	 
//soft_reset logic
	 
	else if (soft_reset)
	 begin
	  for(i=0;i<FIFO_DEPHT;i=i+1)
	   mem[i] <= 9'd0;
	   {rd_ptr, wr_ptr} <= 8'd0;
       data_out <= 8'dz;
     end
	 
    else
     begin
	 
	 //performs write operation
	 
       if(write_enb && !full)
	    begin
		  mem[wr_ptr] <= {temp,data_in};
		  wr_ptr <= wr_ptr + 1'b1;
	    end
	 
	 //performs read operation
	 
	   if(read_enb && !empty) 
		  begin
		  data_out <= mem[rd_ptr];
		  rd_ptr <= rd_ptr +1'b1;
		  end
     end
end

//counter logic

always @(posedge clock)
  begin
   if(!resetn)
	 counter <= 7'd0;
	else if(soft_reset)
	 counter <= 7'd0;
	else
	 begin
   if(temp)
    counter <= data_in[7:2] + 2'b10;
   else if(counter == 7'd0)
	  data_out <= 8'dz; 
   else if(read_enb && !empty)
	  counter <= counter - 1'b1;
   else 
	  counter <= counter;
   
    end
	end
  
// fifo_count for empty and full

always@ (posedge clock)
 begin
  if(!resetn||soft_reset)
   fifo_count <= 0;
    else 
	begin
	 case ({write_enb,read_enb})
	  2'b00 : fifo_count <= fifo_count;
	  2'b01 : fifo_count <= (fifo_count==0) ? 0 : fifo_count-1;
	  2'b10 : fifo_count <= (fifo_count==16) ? 16 : fifo_count +1;
	  2'b11 : fifo_count <= fifo_count;
	  default : fifo_count <= fifo_count;
	  endcase
	  end
	  end
	  
//assign output

assign empty =(fifo_count==0);
assign full =(fifo_count==16);
   
endmodule 
