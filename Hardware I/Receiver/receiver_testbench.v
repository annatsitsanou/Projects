// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module counter_tb;
  
  reg clk;
  reg reset;
  reg [2:0] baud_select;
  reg TX_EN;
  reg RxD;
  wire [7:0] Rx_DATA;
  wire Rx_VALID;
  wire Rx_FERROR;
  wire Rx_PERROR;
  
  
  
  uart_receiver receiver_tb(.clk(clk),.reset(reset), .Rx_DATA(Rx_DATA), .baud_select(baud_select), .RX_EN(TX_EN), .RxD(RxD), .Rx_VALID(Rx_VALID), .Rx_FERROR(Rx_FERROR), .Rx_PERROR(Rx_PERROR));
  
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars; 
	
    clk = 0;
    reset = 1;
    RxD = 1;
    baud_select = 7;
    #100
    reset = 0;
    
    #100
    reset = 1;
    
    //start
    #1300 
    RxD = 0;
    
    //send 3
    //1
    #8960 
    RxD = 0;
    //2
    #8960 
    RxD = 0;
    //3
    #8960 
    RxD = 0;
    //4
    #8960 
    RxD = 0;
    //5
    #8960 
    RxD = 0;
    //6
    #8960 
    RxD = 0;
    //7
    #8960 
    RxD = 0;
    //8
    #8960 
    RxD = 0;
    
    //parity
    #8960 
    RxD = 0;
    
    //stop
    #8960 
    RxD = 1;
    
    #5000
    
    //send 2 with frame error
    //start
    #8960 
    RxD = 0;
    
    //1
    #8960 
    RxD = 0;
    //2
    #9100 
    RxD = 1;
    //3
    #8960 
    RxD = 0;
    //4
    #8960 
    RxD = 0;
    //5
    #8960 
    RxD = 0;
    //6
    #8960 
    RxD = 0;
    //7
    #8960 
    RxD = 0;
    //8
    #8960 
    RxD = 0;
    
    //parity
    #8960 
    RxD = 0;
    
    //stop
    #8960 
    RxD = 1;
    
    #8960
    
    //send 3 with parity error
    //start
    #8960 
    RxD = 0;
    
    //1
    #8960 
    RxD = 1;
    //2
    #8960 
    RxD = 1;
    //3
    #8960 
    RxD = 0;
    //4
    #8960 
    RxD = 0;
    //5
    #8960 
    RxD = 0;
    //6
    #8960 
    RxD = 0;
    //7
    #8960 
    RxD = 0;
    //8
    #8960 
    RxD = 0;
    
    //parity
    #8960 
    RxD = 1;
    
    //stop
    #8960 
    RxD = 1;
    
    #8960
    
    //send 3 with no stop bit error
    //start
    #8960 
    RxD = 0;
    
    //1
    #8960 
    RxD = 1;
    //2
    #8960 
    RxD = 1;
    //3
    #8960 
    RxD = 0;
    //4
    #8960 
    RxD = 0;
    //5
    #8960 
    RxD = 0;
    //6
    #8960 
    RxD = 0;
    //7
    #8960 
    RxD = 0;
    //8
    #8960 
    RxD = 0;
    
    //parity
    #8960 
    RxD = 0;
    
    //stop
    #8960 
    RxD = 0;
    
    
    #5000
    

    	
      
      
      
    
    #1000000 $finish;
	
  end

  always begin
    #10 clk = ~ clk;
  end


  
  
endmodule
    