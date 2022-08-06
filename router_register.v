module router_register(input clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,
       input [7:0]data_in,output reg parity_done,low_pkt_valid,err,output reg [7:0]dout);
	   
//defining internal registers

reg [7:0]header_byte;
reg [7:0]fifo_full_state_byte;
reg [7:0]internal_parity_byte;
reg [7:0]packet_parity_byte;

//logic for reset

always @(posedge clock)
 begin 
   if(!resetn)
    begin
	header_byte          = 8'd0;
    fifo_full_state_byte = 8'd0;
	end
 
//logic for header_byte

else
 begin
  header_byte = (detect_add && pkt_valid && data_in[1:0] != 2'b11) ? data_in : header_byte;
	
//logic for fifo_full_state_byte

  fifo_full_state_byte = (ld_state && fifo_full) ? data_in : fifo_full_state_byte;

end
end
 
  
//logic for packet_parity_byte

always@(posedge clock)
 begin
  if(!resetn)
   packet_parity_byte   = 8'd0;
  else
  packet_parity_byte = ((ld_state && !fifo_full && !pkt_valid) || (laf_state && !pkt_valid && !parity_done)) ? data_in : packet_parity_byte;
 end

//logic for internal_parity_byte

always@(posedge clock)
 begin
  if(!resetn)
	internal_parity_byte <= 8'd0;
  else if(detect_add)
	internal_parity_byte <= 8'd0;
  else if(!full_state)
	begin
    if (lfd_state)
    internal_parity_byte <=  internal_parity_byte ^ header_byte;
    else if (ld_state && pkt_valid)
    internal_parity_byte <=  internal_parity_byte ^ data_in; 
end 
  else
	internal_parity_byte <= internal_parity_byte;
    end
  
   
 //output logic

always @(posedge clock)
 begin
  if (!resetn)
    parity_done <= 1'b0;
  else if (detect_add)
    parity_done <= 1'b0;
  else
   parity_done <= ((ld_state && !fifo_full && !pkt_valid) || (laf_state && !pkt_valid && !parity_done)) ? 1'b1 : 1'b0;
  end
  
always @(posedge clock)
 begin
  if(!resetn) 
    dout <= 8'd0;
  else if(lfd_state)
    dout <= header_byte;
  else if(laf_state)
    dout <= fifo_full_state_byte;
  else if (ld_state && !fifo_full)
    dout <= data_in;
  else if(parity_done && (internal_parity_byte == packet_parity_byte))
    dout <= packet_parity_byte;
  else
    dout <= dout;
 end
 
always @(posedge clock)
 begin
  if(!resetn)
   low_pkt_valid <= 1'b0;
  else if(rst_int_reg)
   low_pkt_valid <= 1'b0;
  else 
   low_pkt_valid <= (!pkt_valid) ? 1'b1 : 1'b0;
 end

always @(posedge clock)
  begin
	if(!resetn)
	  err <= 1'b0;
	else if(parity_done)
	  err <= (packet_parity_byte != internal_parity_byte) ? 1'b1 : 1'b0;
	else
	 err <= 1'b0;
	end
	
endmodule