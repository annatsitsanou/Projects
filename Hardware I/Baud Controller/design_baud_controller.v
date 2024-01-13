`timescale 1ns/1ps
module baud_controller(clk, reset, baud_select, baud_clk);
  input clk, reset;
  input [2:0] baud_select;
  output reg baud_clk;

  reg [12:0] cur_state;
  reg [12:0] next_state;
  
  reg [12:0] limit;
  
  	
  //one extra state for reset
  
  always @ (baud_select)
  	begin
      case (baud_select)
        0 : limit <= 5208; //limit
        1 : limit <= 1302;
        2 : limit <= 326;
        3 : limit <= 163;
        4 : limit <= 81;
        5 : limit <= 41;
        6 : limit <= 27;
        7 : limit <= 14;
      endcase
    end
  
  always @ (posedge clk or negedge reset)
    begin
      if (!reset)
        cur_state <= 0;
      else 
        cur_state <= next_state;
    end
  
  always @ (cur_state)
    begin
      if (cur_state == limit)
        next_state <= 1;
      else	
        next_state <= cur_state + 1;
    end
  
  always @ (cur_state)
    begin
      case (cur_state)
        limit : baud_clk <= 1;
        default : baud_clk <= 0;
      endcase
    end
endmodule


module transmitter_clock(clk, reset, baud_clk, transmit_clk, sampling_count);
  	input wire clk, reset, baud_clk;
  	output reg transmit_clk;
 	output reg [5:0] sampling_count;
  
  	//one extra state for reset
  	reg [5:0] cur_state;
  	reg [5:0] next_state;
  
  	parameter limit = 32;
  	
  
  always @ (posedge baud_clk or negedge reset)
    begin
      if (!reset)
        cur_state <= 0;
      else
        cur_state <= next_state;
    end
  
  always @ (cur_state)
    begin
      if (cur_state == limit)
        next_state <= 1;
      else	
        next_state <= cur_state + 1;
    end
  
  always @ (cur_state)
    begin
      case (cur_state)
        limit : transmit_clk <= 1;
        default : transmit_clk <= 0;
      endcase
      sampling_count <= cur_state ;
    end
endmodule