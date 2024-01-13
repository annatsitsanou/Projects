// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module counter_tb;
  
  reg clk;
  reg reset;
  reg [2:0] baud_select;
  reg TX_EN;
  wire TxD;
  reg Tx_WR;
  reg [7:0] Tx_DATA;
  wire Tx_BUSY;
  
  
  uart_transmitter uart_transmitter_module(.clk(clk),.reset(reset),.TxD(TxD),.baud_select(baud_select),.Tx_DATA(Tx_DATA),.Tx_BUSY(Tx_BUSY),.Tx_WR(Tx_WR), .TX_EN(TX_EN));
  
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars; 
	
    baud_select = 7;
    clk = 0;
    reset = 1;
    Tx_DATA = 0;
    TX_EN = 1;
    #100
    reset = 0;
    
    #100
    Tx_WR = 1;
    reset = 1;
    #200 
    Tx_WR = 0;
    #26000
    Tx_WR = 1;
    Tx_DATA = 1;
    
    #1000000 $finish;
	
  end

  always begin
    #10 clk = ~ clk;
  end


  
  
endmodule
    