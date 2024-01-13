// Code your testbench here
// or browse Example
`timescale 1ns/1ps
module partA_test_bench;
  reg clk,reset;
  reg [15:0] data;
  wire an3, an2, an1, an0;
  wire [6:0] display;
  wire [3:0] char0;
  wire [3:0] char1;
  wire [3:0] char2;
  wire [3:0] char3;
 
  anode test_anodes(clk, reset, display, an3, an2, an1, an0, data[15:12], data[11:8], data[7:4], data[3:0]);
  
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
    //send -194
    data[3:0] = 4;
    data[7:4] = 9;
    data[11:8] = 1;
    data[15:12] = 10;
    clk = 0;
    
    reset = 1;
    #500 
    reset = 0;
    
    #500 
    
    reset = 1;
    
    //send 10
    #5020
    data[3:0] = 0;
    data[7:4] = 1;
    data[11:8] = 12;
    data[15:12] = 12;
    
    //send - 32
    #5020
    
    data[3:0] = 2;
    data[7:4] = 3;
    data[11:8] = 12;
    data[15:12] = 10;
    
    //send FFFF
    #5020
    data[3:0] = 11;
    data[7:4] = 11;
    data[11:8] = 11;
    data[15:12] = 11;
  
    #20000 
    $finish;
    
  end
 
  always begin
  	#10 clk = ~ clk;
  end
  
endmodule

