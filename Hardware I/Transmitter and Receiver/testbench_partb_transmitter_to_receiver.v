// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module uart_channel_tb1;

  reg clk;
  reg reset;
  reg [2:0] baud_select;
  reg TX_EN, RX_EN;
  wire Tx_WR;
  reg [15:0] data;
  reg signal;
  wire TxD;
  wire [15:0] incoming_data;
  
 channel_uart_transmitter channel_uart_transmitter_module(.clk(clk),.reset(reset),.data(data),.transfer_data(signal),.baud_select(baud_select), .TxD(TxD));
  channel_uart_receiver channel_uart_receiver_module(.clk(clk),.reset(reset), .baud_select(baud_select), .RX_EN(RX_EN), .RxD(TxD), .data(incoming_data));
  

  initial begin
    $dumpfile("dump.vcd"); $dumpvars; 
	
    baud_select = 7;
    clk = 0;
    reset = 1;
    data = 16'b0001000100010001;//4;
    
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
    data = 4;//16'b0001000100010001;
    
    #1000000 $finish;
  
  end
  
  always begin
    #10 clk = ~ clk;
  end
  
endmodule
  
  
  
	 