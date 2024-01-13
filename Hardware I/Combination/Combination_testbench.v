// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module uart_channel_tb;

  reg clk;
  reg reset;
  reg [2:0] baud_select;
  reg TX_EN, RX_EN;
  wire Tx_WR;
  reg [15:0] data;
  reg signal;
  wire TxD;
  wire [15:0] incoming_data;
  wire [6:0] display;
  wire an3, an2, an1, an0;
  
 channel_uart_transmitter channel_uart_transmitter_module(.clk(clk),.reset(reset),.data(data),.transfer_data(signal),.baud_select(baud_select), .TxD(TxD));
  data_to_display data_to_display_module(clk, reset, TxD, baud_select, display, an3, an2, an1, an0); 
  //channel_uart_receiver channel_uart_receiver_module(.clk(clk),.reset(reset), .baud_select(baud_select), .RX_EN(RX_EN), .RxD(TxD), .data(incoming_data));
  

initial begin
    $dumpfile("dump.vcd"); $dumpvars; 
	
    baud_select = 7;
    clk = 0;
    reset = 1;
    data[3:0] = 0;
    data[7:4] = 1;
    data[11:8] = 12;
    data[15:12] = 12;
    
    
    #100
    reset = 0;
	 
	 //first word
	#100
    reset = 1;
    #100
    signal = 1;
    #100
    signal = 1;
    
    #1000
    data[3:0] = 1;
    data[7:4] = 1;
    data[11:8] = 12;
    data[15:12] = 12;
    
    
    #1000000 $finish;
  
  end
  
  always begin
    #10 clk = ~ clk;
  end
  
endmodule
  
  
  
	 