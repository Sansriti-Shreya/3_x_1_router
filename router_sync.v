module router_sync(input detect_add,write_enb_reg,clock,resetn,empty_0,empty_1,empty_2,full_0,full_1,full_2,
                   read_enb_0,read_enb_1,read_enb_2,input [1:0]data_in,output reg [2:0]write_enb,
                   output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,output vld_out_0,vld_out_1,vld_out_2); 

//defining internal variables

reg [1:0]temp;
reg [4:0]counter_0,counter_1,counter_2;

//defining parameters

parameter FIFO_1 = 2'b00,
          FIFO_2 = 2'b01,
		  FIFO_3 = 2'b10;
		  
// reset logic

always @(posedge clock)
  begin
    if(!resetn)
	   temp <= 2'b00;
	else if(detect_add)
	   temp <= data_in;
	else
		temp <= temp;
  end
  
// write_enb logic

always@(*)
	begin
      if(write_enb_reg)
		 begin
		  case(temp)
		   FIFO_1 : write_enb = 3'b001;
		   FIFO_2 : write_enb = 3'b010;
		   FIFO_3 : write_enb = 3'b100;
		  default : write_enb = 3'b000;
		 endcase
		end
		else
		write_enb = 3'b000;
	end
		
// fifo_full logic
always@(*)
	begin
		case(temp)
		    FIFO_1 : fifo_full = full_0;
			FIFO_2 : fifo_full = full_1;
			FIFO_3 : fifo_full = full_2;
		   default : fifo_full = 1'b0;
		  endcase
	end
   
// soft_reset logic

always @(posedge clock)
  begin
   if(!resetn)
	begin
     counter_0 <= 5'd0;
     counter_1 <= 5'd0;
     counter_2 <= 5'd0;
     soft_reset_0 <= 1'b0;
     soft_reset_1 <= 1'b0;
     soft_reset_2 <= 1'b0;
    end
   else
    begin
	 if(!empty_0)
	  begin
	  if(!read_enb_0)
	   begin
	   counter_0 <= (counter_0 <= 5'd28) ? counter_0 + 1 : 5'd0;
	   soft_reset_0 <= (counter_0 == 5'd29) ? 1'b1 : 1'b0;
	  end
	  if(read_enb_0)
	   counter_0 <= 5'd0;
	 end
	 if(!empty_1)
	  begin
	  if(!read_enb_1)
	   begin
	   counter_1 <= (counter_1 <= 5'd28) ? counter_1 + 1'b1 : 5'd0;
	   soft_reset_1 <= (counter_1 == 5'd29) ? 1'b1 : 1'b0;
	  end
	  if(read_enb_1)
	   counter_1 <= 5'd0;
	 end
	 if(!empty_2)
	  begin
	  if(!read_enb_2)
	   begin
	   counter_2 <= (counter_2 <= 5'd28) ? counter_2 + 1'b1 : 5'd0;
	   soft_reset_2 <= (counter_2 == 5'd29) ? 1'b1 : 1'b0;
	  end
	  if(read_enb_2)
	   counter_2 <= 5'd0;
	 end
	end
  end
  
// valid output logic

 assign vld_out_0 = ! empty_0;
 assign vld_out_1 = ! empty_1;
 assign vld_out_2 = ! empty_2;

endmodule
	  
		