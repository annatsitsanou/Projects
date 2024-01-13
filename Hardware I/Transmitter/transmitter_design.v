`timescale 1ns/1ps
module baud_controller(clk, reset, baud_select, baud_clk);
  input clk, reset;
  input [2:0] baud_select;
  output reg baud_clk;

  //one extra state for reset
  reg [12:0] cur_state;
  reg [12:0] next_state;
  
  reg [12:0] limit;
  
  
  //baud rate error at the report 
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
  
  
  	//I have an extra state for the initial pulse
  	//the first state is for waiting - reset
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


//creates the clock for transmitter/receiver
module sampling_timing (clk, reset, baud_select, sample_clk, sampling_counter);
  	input wire clk;
  	input wire reset;
  	input wire [2:0] baud_select;
  	output wire sample_clk;
	output wire [5:0] sampling_counter;
  
   wire baud_clk;
  
  	baud_controller baud_module(.reset(reset), .clk(clk), .baud_select(baud_select),.baud_clk(baud_clk));
  	transmitter_clock transmitter_clock_module(.reset(reset), .clk(clk), .baud_clk(baud_clk), .transmit_clk(sample_clk), .sampling_count(sampling_counter)); 
  
endmodule


module uart_transmitter(reset, clk, baud_select, Tx_DATA, Tx_WR, TX_EN, TxD, Tx_BUSY);
  input wire clk, reset;
  input wire [7:0] Tx_DATA;
  input wire [2:0] baud_select;
  input wire TX_EN;   //not used
  input wire Tx_WR;
  output reg TxD;
  output reg Tx_BUSY;
  
  
  wire sample_clk;
  wire [5:0] sampling_counter;
  wire [7:0] encrypted_data;
  
  function parity;
    input [7:0] data;
   	reg [3:0] temp;
    
  	begin
    	temp[0] = data[0]^data[1];
    	temp[1] = data[2]^data[3];
    	temp[2] = data[4]^data[5];
    	temp[3] = data[6]^data[7];
    	parity  = temp[0]^temp[1]^temp[2]^temp[3];
  	end
  endfunction
  
  //encoder encoder_module(.data(data),.encrypted_data(encrypted_data), .encryption_key(encryption_key));
  
  sampling_timing sample(.clk(clk), .reset(baud_reset), .baud_select(baud_select), .sample_clk(sample_clk), .sampling_counter(sampling_counter));
  
  
  reg [3:0] cur_state;  //current state of the counter
  reg [3:0] next_state; //next state of the counter
  reg [7:0] data;       //stored data

  parameter state_wait = 0;
  parameter state_last = 11;
  
  reg baud_reset;
  
  reg [3:0] cur_state_Tx_WR;
  reg [3:0] cur_state_transmit;
  
  always @ (posedge clk or negedge reset)
    begin
      if (!reset)
        cur_state_Tx_WR <= state_wait;
      else if (Tx_WR)
        begin 
		  if (cur_state_Tx_WR == 0)
          cur_state_Tx_WR <= next_state;
      	else
          cur_state_Tx_WR <= cur_state;
		  end
      else
        cur_state_Tx_WR <= cur_state;
    end
  
  always @ (posedge sample_clk or negedge reset)
    begin
      if (!reset)
        cur_state_transmit <= 0;
      else
        cur_state_transmit <= next_state;
    end
  
  always @ (cur_state)	
    begin: NEXT_STATE_LOGIC
      if (cur_state == state_last)
        next_state <= 0;
      else
        next_state <= cur_state + 1;
    end
	
  
  always @ (cur_state_transmit or cur_state_Tx_WR)
    begin
      if (cur_state == 0)
        cur_state <= cur_state_Tx_WR;
      else
        cur_state <= cur_state_transmit;
    end
    
  
  always @ (posedge clk)
    begin
      //the cur_state == 0 might cause problems
      if (Tx_WR && cur_state == 0)
        data <= Tx_DATA;
      else 
        data <= data;
    end
  
   always @ (cur_state)
    begin: OUTPUT_LOGIC
      case (cur_state)
        state_wait  : 
          begin 
            baud_reset <= 0;
            //data <= Tx_DATA;
            TxD <= 1; 
            Tx_BUSY <= 0;   
          end 
        1  : 
          begin 
            baud_reset <= 1;
            //data <= data;
            TxD <= 0;
            Tx_BUSY <= 1;
          end //start bit
        11 : 
          begin
            baud_reset <= 1;
            Tx_BUSY <= 1;
            TxD <= 1; //stop bit
          end
  		default : 
          begin
            baud_reset <= 1;
            if (cur_state == 10)
              begin 
                TxD <= parity(data[7:0]);
              end
            else
              TxD <= data[cur_state - 2];
            Tx_BUSY <= 1;
          end
      endcase
    end
endmodule

