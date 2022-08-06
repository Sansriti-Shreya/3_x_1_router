module router_fsm(input clock,resetn,pkt_valid,low_pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
                  fifo_empty_0,fifo_empty_1,fifo_empty_2,input [1:0]data_in,output detect_add,ld_state,laf_state,full_state,
				  write_enb_reg,rst_int_reg,lfd_state,busy);
				  
//moore fsm using coding style 1
//defining the state that is present state and next state(this code has 8 states so using 3 bit ps and ns)

reg [2:0] ps,ns;
reg [1:0]addr;

//defining parameter for states

parameter DECODE_ADDRESS     = 3'b000,
          LOAD_FIRST_DATA    = 3'b001,
          LOAD_DATA          = 3'b010,
          LOAD_PARITY        = 3'b011,
          CHECK_PARITY_ERROR = 3'b100,
          FIFO_FULL_STATE    = 3'b101,
          LOAD_AFTER_FULL    = 3'b110,
          WAIT_TILL_EMPTY    = 3'b111;

//present state logic
		  
always @(posedge clock)
  begin
    if(!resetn||soft_reset_0||soft_reset_1||soft_reset_2)
	  ps <= DECODE_ADDRESS;
	else
	  ps <= ns;
  end		  

//next state logic

always @(*)
  begin
     case (ps)
	  DECODE_ADDRESS  :  if((pkt_valid && (data_in[1:0] == 0) && fifo_empty_0)|| 
	                       (pkt_valid && (data_in[1:0] == 1) && fifo_empty_1) || 
						   (pkt_valid && (data_in[1:0] == 2) && fifo_empty_2))
					     ns = LOAD_FIRST_DATA;
					     else if((pkt_valid && (data_in[1:0] == 0) && !fifo_empty_0)|| 
	                       (pkt_valid && (data_in[1:0] == 1) && !fifo_empty_1) || 
						   (pkt_valid && (data_in[1:0] == 2) && !fifo_empty_2))
					     ns = WAIT_TILL_EMPTY;
					     else
					     ns = DECODE_ADDRESS;
					   
	  LOAD_FIRST_DATA :  ns = LOAD_DATA;
	  
	  LOAD_DATA       :  if (!fifo_full && !pkt_valid)
	                     ns = LOAD_PARITY;
						 else if (fifo_full)
						 ns = FIFO_FULL_STATE;
						 else
						 ns = LOAD_DATA;
						 
	  LOAD_PARITY     :  ns = CHECK_PARITY_ERROR;
	  
   CHECK_PARITY_ERROR :  if (!fifo_full)
	                     ns = DECODE_ADDRESS;
						 else
						 ns = FIFO_FULL_STATE;
						   
	  FIFO_FULL_STATE :  if (!fifo_full)
	                     ns = LOAD_AFTER_FULL;
						 else
						 ns = FIFO_FULL_STATE;
						 
	  LOAD_AFTER_FULL :  if (!parity_done && low_pkt_valid)
						 ns = LOAD_PARITY;
						 else if (!parity_done && !low_pkt_valid)
						 ns = LOAD_DATA;
						 else
						 ns = DECODE_ADDRESS;
						 
	  WAIT_TILL_EMPTY :  if ((fifo_empty_0 && (addr == 2'b00)) || (fifo_empty_1 && (addr == 2'b01)) || (fifo_empty_2 &&(addr == 2'b10)))
	                     ns = LOAD_FIRST_DATA;
						 else
						 ns = WAIT_TILL_EMPTY;
						 
	   default        :  ns = DECODE_ADDRESS;
						
	endcase
  end
  
always @(posedge clock)
  begin
    if(ps == DECODE_ADDRESS)
	 addr <= data_in;
	else
	 addr <= addr;
	end

//output logic

assign busy = ((ps == LOAD_FIRST_DATA) || (ps == LOAD_PARITY) || (ps == FIFO_FULL_STATE) || (ps == LOAD_AFTER_FULL) ||
               (ps == WAIT_TILL_EMPTY) || (ps == CHECK_PARITY_ERROR)) ? 1:0;
assign write_enb_reg = ((ps == LOAD_DATA) || (ps == LOAD_PARITY) || (ps == LOAD_AFTER_FULL)) ? 1:0;		   
assign detect_add = (ps == DECODE_ADDRESS) ? 1:0;
assign lfd_state = (ps == LOAD_FIRST_DATA) ? 1:0;
assign ld_state = (ps == LOAD_DATA) ? 1:0;
assign full_state = (ps == FIFO_FULL_STATE) ? 1:0;
assign laf_state = (ps == LOAD_AFTER_FULL) ? 1:0;
assign rst_int_reg = (ps == CHECK_PARITY_ERROR) ? 1:0;

endmodule