// Code your design here
`timescale 1ns/1ps

module LEDdecoder(char, LED);
  input [3:0] char;
  output reg [6:0] LED;
  
  always @ (char)
    begin
      case (char)
        //a-b-c-d-e-f-g
          0 : LED = 7'b0000001;  //0
          1 : LED = 7'b1001111;  //1
          2 : LED = 7'b0010010;  //2
          3 : LED = 7'b0000110;  //3

          4 : LED = 7'b1001100;  //4
          5 : LED = 7'b0100100;  //5
          6 : LED = 7'b0100000;  //6
          7 : LED = 7'b0001111;  //7

          8 : LED = 7'b0000000;  //8
          9 : LED = 7'b0001100;  //9 equals 12
          10: LED = 7'b1111110;  //a-paula
          11: LED = 7'b0111000;  //b-F  

          12: LED = 7'b1111111;  //c-keno
          default : LED = 7'b0111000;  //F  
      endcase
    end
endmodule


module led_timer(clk, reset, anode_clk);
  input wire reset, clk;
  output reg anode_clk;
  
  reg [3:0] cur_state;
  reg [3:0] next_state;
  
  always @ (posedge clk or negedge reset) 
    begin: COUNTER
      if(!reset)
      	cur_state <= 0;
      else
        cur_state <= next_state;
    end
  
  always @ (cur_state)
    begin
      next_state <= cur_state + 1;
    end
  
  always @ (cur_state)
    begin
      if (cur_state == 15)
        anode_clk <= 1;
      else
        anode_clk <= 0;
    end
  
endmodule


module anode (clk, reset, display, an3, an2, an1, an0, char3, char2, char1, char0);
  input wire clk, reset;
  input wire [3:0] char0;
  input wire [3:0] char1;
  input wire [3:0] char2;
  input wire [3:0] char3;
  output reg an3, an2, an1, an0;
  output wire [6:0] display;
 
  
  wire anode_clk;
  reg [3:0] decoder_data;
  
  led_timer led_timer_module(.anode_clk(anode_clk),.clk(clk),.reset(reset));
  LEDdecoder decoder_module(decoder_data, display);
  
  reg [3:0] cur_state;      //current state of the counter
  reg [3:0] next_state; 	//next state of the counter
  
  always @ (posedge anode_clk or negedge reset)
    begin
      if (!reset)
        cur_state <= 15;
      else
        cur_state <= next_state;
    end
  
  always @ (cur_state)
    begin: NEXT_STATE_LOGIC
      next_state <= cur_state - 1;
    end

  always @ (cur_state)
    begin: OUTPUT_LOGIC
      case (cur_state)
        15  : 
          begin
          	decoder_data <= char3;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        14  : 
          begin
          	decoder_data <= char3;
            an3 <= 0;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        13  : 
          begin
          	decoder_data <= char3;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        12  : 
          begin
          	decoder_data <= char3;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        11  : 
          begin
          	decoder_data <= char2;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        10  : 
          begin
          	decoder_data <= char2;
            an3 <= 1;
          	an2 <= 0;
            an1 <= 1;
            an0 <= 1;
          end
        9  : 
          begin
          	decoder_data <= char2;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        8  : 
          begin
          	decoder_data <= char2;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        7   : 
          begin
          	decoder_data <= char1;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        6   : 
          begin
          	decoder_data <= char1;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 0;
            an0 <= 1;
          end
        5  : 
          begin
          	decoder_data <= char1;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        4  : 
          begin
          	decoder_data <= char1;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        3   : 
          begin
          	decoder_data <= char0;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        2  : 
          begin
          	decoder_data <= char0;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 0;
          end
        1  : 
          begin
          	decoder_data <= char0;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        0  : 
          begin
          	decoder_data <= char0;
            an3 <= 1;
          	an2 <= 1;
            an1 <= 1;
            an0 <= 1;
          end
        
      endcase
    end

endmodule 
