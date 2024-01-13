// Code your testbench here
// or browse Example
`timescale 1ns/1ps
module partA_test_bench;
  reg clk,reset;
  reg [2:0] baud_select;
  wire transmit_clk;
  wire baud_clk;
  wire [5:0] sampling_count;
  wire [5:0] output_clk;
  
  baud_controller test_baud_controller(clk, reset, baud_select, baud_clk);
  transmitter_clock test_transmitter_clock(clk, reset, baud_clk, transmit_clk, sampling_count);
  
  
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
    
    baud_select = 0;
    clk = 1;
    reset = 1;
    
    #50
    
    reset = 0;
    
    #50 
    
    reset = 1;
    
    #100000 $finish;
    
  end
 
  always begin
  	#10 clk = ~ clk;
  end
  
endmodule

