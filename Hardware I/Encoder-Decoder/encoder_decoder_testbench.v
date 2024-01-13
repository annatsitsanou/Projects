// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module encryption_tb;
  
  reg [7:0] data;
  wire [7:0] decrypted_data;
  wire [7:0] encrypted_data;
  reg [7:0] encryption_key;
  reg [3:0] cur_state;
  reg Tx_WR;
  reg Rx_data_transfer_signal;
  reg clk;
  encoder encoder_module(clk, Tx_WR, cur_state, data, encrypted_data, encryption_key);
  decoder decoder_module(clk, reset, Rx_data_transfer_signal,decrypted_data, encrypted_data, encryption_key);
  initial begin
    $dumpfile("dump.vcd"); $dumpvars; 
	clk = 0;
    cur_state = 0;
    data = 8'b00000001;
    encryption_key = 13;
    Tx_WR = 0;
    cur_state = 0;
    #100
    Tx_WR = 1;
    #200
    Rx_data_transfer_signal = 1;
    #20000
    
    data = 8'b00001111;
    
    #1000000 $finish;
	
  end

  always begin
    #10 clk = ~ clk;
  end


  
  
endmodule
    