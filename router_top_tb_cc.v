`timescale 1ns/1ps
module router_top_tb_cc();

//defining internal variables
 
reg clock,resetn;
reg pkt_valid;
reg [7:0]data_in;
reg read_enb_0,read_enb_1,read_enb_2;

wire [7:0]data_out_0,data_out_1,data_out_2;
wire vld_out_0,vld_out_1,vld_out_2,busy,error;

parameter T = 10;
integer k;
event e1,e2;

//instantiating router_top rtl

router_top ROUTER_DUT(clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_in,data_out_0,
                      data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,error,busy);
					  
//initialise clock

initial 
  begin
   clock = 1'b0;  
//initialized clock to 0 at time = 0 
   forever #(T/2) clock = ~clock;
// toggle after time 5 units as T=10
 end

//initialise task for resetn

task rst;
  begin
   @(negedge clock)
    resetn = 1'b0;
   @(negedge clock)
    resetn = 1'b1;
  end
endtask

//initial inputs

task initialise;
  begin
    {read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_in} = 12'd0;
  end
 endtask
 
//packet with payload 14

task pkt_gen_14(input [1:0]addr);
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]address;
  begin
   @(negedge clock);
    wait(~busy)
   parity = 8'd0;
	@(negedge clock);
    payload_length = 6'd14;
	address = addr;
	header = {payload_length,address};
	data_in = header;
	pkt_valid = 1'b1;
	parity = parity ^ header;
	@(negedge clock);
	wait(~busy)
	for(k=0;k<payload_length;k=k+1)
	 begin
	  @(negedge clock);
	   wait(~busy)
	  payload_data = {$random}%256;
	  data_in = payload_data;
	  parity = parity ^ payload_data;
	end
	@(negedge clock);
	wait(~busy)
	pkt_valid = 1'b0;
	data_in = parity;
  end
endtask

//packet with payload less than 14

task pkt_gen_12(input [1:0]addr);
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]address;
  begin
   @(negedge clock);
    wait(~busy)
     parity = 8'd0;
	@(negedge clock);
    payload_length = 6'd12;
	address = addr;
	header = {payload_length,address};
	data_in = header;
	pkt_valid = 1'b1;
	parity = parity ^ header;
	@(negedge clock);
	wait(~busy)
	for(k=0;k<payload_length;k=k+1)
	 begin
	  @(negedge clock);
	   wait(~busy)
	  payload_data = {$random}%256;
	  data_in = payload_data;
	  parity = parity ^ payload_data;
	end
	@(negedge clock);
	wait(~busy)
	pkt_valid = 1'b0;
	data_in = parity;
  end
endtask

//packet with payload 16

task pkt_gen_16(input [1:0]addr);
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]address;
  begin
   @(negedge clock);
    wait(~busy)
	parity = 8'd0;
	@(negedge clock);
    payload_length = 6'd16;
	address = addr;
	header = {payload_length,address};
	data_in = header;
	pkt_valid = 1'b1;
	parity = parity ^ header;
	@(negedge clock);
	wait(~busy)
	for(k=0;k<payload_length;k=k+1)
	 begin
	  @(negedge clock);
	   wait(~busy)
	  payload_data = {$random}%256;
	  data_in = payload_data;
	  parity = parity ^ payload_data;
	end
	@(negedge clock);
	wait(~busy)
	pkt_valid = 1'b0;
	data_in = parity;
  end
endtask

//packet with random payload

task random_pkt(input [1:0]addr);
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]address;
  begin
  ->e2;
   @(negedge clock);
    wait(~busy)
	parity = 8'd0;
	@(negedge clock);
    payload_length = {$random}%63 + 1;
	address = addr;
	header = {payload_length,address};
	data_in = header;
	pkt_valid = 1'b1;
	parity = parity ^ header;
	@(negedge clock);
	wait(~busy)
	for(k=0;k<payload_length;k=k+1)
	 begin
	  @(negedge clock);
	   wait(~busy)
	  payload_data = {$random}%256;
	  data_in = payload_data;
	  parity = parity ^ payload_data;
	end
	@(negedge clock);
	wait(~busy)
	pkt_valid = 1'b0;
	data_in = parity;
  end
endtask

//packet with payload 17

task pkt_gen_17(input [1:0]addr);
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]address;
  begin
   @(negedge clock);
    wait(~busy)
	parity = 8'd0;
	@(negedge clock);
    payload_length = 6'd17;
	address = addr;
	header = {payload_length,address};
	data_in = header;
	pkt_valid = 1'b1;
	parity = parity ^ header;
	@(negedge clock);
	wait(~busy)
	for(k=0;k<payload_length;k=k+1)
	 begin
	  @(negedge clock);
	   wait(~busy)
	  payload_data = {$random}%256;
	  data_in = payload_data;
	  parity = parity ^ payload_data;
	end
	->e1;
	@(negedge clock);
	wait(~busy)
	pkt_valid = 1'b0;
	data_in = parity;
  end
endtask

//packet with error signal high

task pkt_gen_error_10(input [1:0]addr);
reg [7:0]payload_data,parity,header;
reg [5:0]payload_length;
reg [1:0]address;
  begin
   @(negedge clock);
    wait(~busy)
   parity = 8'd0;
	@(negedge clock);
    payload_length = 6'd10;
	address = addr;
	header = {payload_length,address};
	data_in = header;
	pkt_valid = 1'b1;
	parity = parity ^ header;
	@(negedge clock);
	wait(~busy)
	for(k=0;k<payload_length;k=k+1)
	 begin
	  @(negedge clock);
	   wait(~busy)
	  payload_data = {$random}%256;
	  data_in = payload_data;
	  parity = parity ^ payload_data;
	end
	@(negedge clock);
	wait(~busy)
	pkt_valid = 1'b0;
	data_in = $random;
  end
endtask

//event (e1) controlled statement

initial
 begin
  forever
   begin
   @(e1);
   @(negedge clock);
   begin
    case(vld_out_0 || vld_out_1 || vld_out_2)
	  vld_out_0 :  read_enb_0 = 1'b1;
      vld_out_1 :  read_enb_1 = 1'b1;
      vld_out_2 :  read_enb_2 = 1'b1;
	endcase
   end
   @(negedge clock);
   wait(~(vld_out_0 || vld_out_1 || vld_out_2))
   @(negedge clock);
   {read_enb_0,read_enb_1,read_enb_2} = 3'b000;
   end
   end   

//event (e2) controlled statement

initial
 begin
  forever
  begin
   @(e2);
   @(negedge clock);
   wait(vld_out_0 || vld_out_1 || vld_out_2);
   @(negedge clock) 
   begin
    case(vld_out_0 || vld_out_1 || vld_out_2)
	  vld_out_0 :  read_enb_0 = 1'b1;
      vld_out_1 :  read_enb_1 = 1'b1;
      vld_out_2 :  read_enb_2 = 1'b1;
	endcase
   end
   wait (~(vld_out_0 || vld_out_1 || vld_out_2));
   @(negedge clock)
    {read_enb_0,read_enb_1,read_enb_2} = 3'b000;
   end
   end
   
/////////////////////////////

initial
 begin
  initialise;
  
//for FIFO_0

  rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b00);
  @(negedge clock);
   read_enb_0 = 1'b1;
   wait (~vld_out_0)
  @(negedge clock);
   read_enb_0 = 1'b0;
   #30;
   
///////////////////////////////

    rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_14(2'b00);
   @(negedge clock);
   read_enb_0 = 1'b1;
   wait (~vld_out_0)
  @(negedge clock);
   read_enb_0 = 1'b0;
   #30;
   
/////////////////////////////////

  rst;
 repeat(3)
@(negedge clock);
   pkt_gen_16(2'b00);
   @(negedge clock);
   read_enb_0 = 1'b1;
   wait (~vld_out_0)
  @(negedge clock);
   read_enb_0 = 1'b0;
   #30;
   
////////////////////////////////

rst;
 repeat(3)
@(negedge clock);
   pkt_gen_17(2'b00);
   #200;
   
/////////////////////////////

rst;
 repeat(3)
@(negedge clock);
   random_pkt(2'b00);
   #100;
   
///////////////////////////

rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_error_10(2'b00);
  @(negedge clock);
   read_enb_0 = 1'b1;
   wait (~vld_out_0)
  @(negedge clock);
   read_enb_0 = 1'b0;
   #30;
 
//for WAIT_TILL_EMPTY
 
 rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b00);
  @(negedge clock);
   read_enb_0 = 1'b1;
   @(negedge clock);
   pkt_gen_12(2'b00);
   wait (~vld_out_0)
  @(negedge clock);
   read_enb_0 = 1'b0;
   #30;

// for soft_reset_0

rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b00);
   #210;
 
//for FIFO_1

  rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b01);
  @(negedge clock);
   read_enb_1 = 1'b1;
   wait (~vld_out_1)
  @(negedge clock);
   read_enb_1= 1'b0;
   #30;
   
///////////////////////////////

    rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_14(2'b01);
   @(negedge clock);
   read_enb_1 = 1'b1;
   wait (~vld_out_1)
  @(negedge clock);
   read_enb_1 = 1'b0;
   #30;
   
/////////////////////////////////

  rst;
 repeat(3)
@(negedge clock);
   pkt_gen_16(2'b01);
   @(negedge clock);
   read_enb_1 = 1'b1;
   wait (~vld_out_1)
  @(negedge clock);
   read_enb_1 = 1'b0;
   #30;
   
////////////////////////////////

rst;                                   
 repeat(3)
@(negedge clock);
   pkt_gen_17(2'b01);
   #200;
   
/////////////////////////////

rst;
 repeat(3)
@(negedge clock);
   random_pkt(2'b01);
   #100;
   
///////////////////////////

rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_error_10(2'b01);
  @(negedge clock);
   read_enb_1 = 1'b1;
   wait (~vld_out_1)
  @(negedge clock);
   read_enb_1 = 1'b0;
   #30;
   
//for WAIT_TILL_EMPTY
 
 rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b01);
  @(negedge clock);
   read_enb_1 = 1'b1;
   @(negedge clock);
   pkt_gen_12(2'b01);
   wait (~vld_out_1)
  @(negedge clock);
   read_enb_1 = 1'b0;
   #30;

// for soft_reset_1

rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b01);
   #210;

//for FIFO_2

  rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b10);
  @(negedge clock);
   read_enb_2 = 1'b1;
   wait (~vld_out_2)
  @(negedge clock);
   read_enb_2 = 1'b0;
   #30;
   
///////////////////////////////

    rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_14(2'b10);
   @(negedge clock);
   read_enb_2 = 1'b1;
   wait (~vld_out_2)
  @(negedge clock);
   read_enb_2 = 1'b0;
   #30;
   
/////////////////////////////////

  rst;
 repeat(3)
@(negedge clock);
   pkt_gen_16(2'b10);
   @(negedge clock);
   read_enb_2 = 1'b1;
   wait (~vld_out_2)
  @(negedge clock);
   read_enb_2 = 1'b0;
   #30;
   
////////////////////////////////

rst;
 repeat(3)
@(negedge clock);
   pkt_gen_17(2'b10);
   #200;
   
/////////////////////////////

rst;
 repeat(3)
@(negedge clock);
   random_pkt(2'b10);
   #30;
   
///////////////////////////

rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_error_10(2'b10);
  @(negedge clock);
   read_enb_2 = 1'b1;
   wait (~vld_out_2)
  @(negedge clock);
   read_enb_2 = 1'b0;
   #30;
   
//for WAIT_TILL_EMPTY
 
 rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b10);
  @(negedge clock);
   read_enb_2 = 1'b1;
   @(negedge clock);
   pkt_gen_12(2'b10);
   wait (~vld_out_2)
  @(negedge clock);
   read_enb_2 = 1'b0;
   #30;

// for soft_reset_2

rst;
  repeat(3)
  @(negedge clock);
   pkt_gen_12(2'b10);
   
//toggle coverage of fifo

//FIFO_0

 @(negedge clock);
  ROUTER_DUT.FIFO_0.i = 32'h00000000;
 @(negedge clock);
  ROUTER_DUT.FIFO_0.i = 32'hFFFFFFFF;
 @(negedge clock);
  ROUTER_DUT.FIFO_0.i = 32'h00000000;
  
//FIFO_1

 @(negedge clock);
  ROUTER_DUT.FIFO_1.i = 32'h00000000;
 @(negedge clock);
  ROUTER_DUT.FIFO_1.i = 32'hFFFFFFFF;
 @(negedge clock);
  ROUTER_DUT.FIFO_1.i = 32'h00000000;
  
//FIFO_2
  
 @(negedge clock);
  ROUTER_DUT.FIFO_2.i = 32'h00000000;
 @(negedge clock);
  ROUTER_DUT.FIFO_2.i = 32'hFFFFFFFF;
 @(negedge clock);
  ROUTER_DUT.FIFO_2.i = 32'h00000000;

end

initial #10600 $finish; 

endmodule 	
   
