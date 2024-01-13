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


module uart_receiver(reset, clk, Rx_DATA, baud_select, RX_EN, RxD, Rx_FERROR, Rx_PERROR, Rx_VALID); 
  input wire clk, reset;
  input wire [2:0] baud_select;
  input wire RX_EN;
  input wire RxD;
  output reg [7:0] Rx_DATA; //reg without decoder
  output reg Rx_FERROR;
  output reg Rx_PERROR;
  output reg Rx_VALID;
  
  
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

  wire sample_clk;
  reg baud_reset;
  reg [10:0] data;
  wire [5:0] sampling_counter;
  wire [7:0] decrypted;
  
  
  
  sampling_timing sample(.clk(clk), .reset(baud_reset), .baud_select(baud_select), .sample_clk(sample_clk), .sampling_counter(sampling_counter));
  
  
  reg [3:0] cur_state;
  reg [3:0] next_state;
  reg first_sample;
  
  parameter state_wait = 0;
  parameter state_last = 11;
  
  reg Rx_data_transfer_signal;
  reg data_transfer_signal;
  reg frame_error_signal;
  reg frame_error_signal_reset;    
  reg first_sample_signal;
  
  
  //this is used to change the states during the receiver's operation
  reg [3:0] cur_state_clk;
  always @ (posedge sample_clk or negedge reset)
    begin
      if (!reset)
          cur_state_clk <= state_wait;
      else
        begin
          if (cur_state != 0)
          	cur_state_clk <= next_state;
          else 
            cur_state_clk <= cur_state;
        end
    end
  
  
  //this is used to change to the receiver's working state
  reg [3:0] cur_state_RxD;
  //this reg implements a pulse to reset the receiver 
  reg reset_cur_state_RxD;
  always @ (posedge !reset or negedge RxD or posedge reset_cur_state_RxD)
    begin
      if (!reset)
        cur_state_RxD <= state_wait;
      else if (reset_cur_state_RxD)
			if(cur_state_RxD != 0)
				cur_state_RxD <= 0;
			else
				cur_state_RxD <= next_state;
      else
        cur_state_RxD <= next_state;
    end
  
  //change the receiver's state
  always @ (cur_state_RxD or cur_state_clk)
    begin
      if (cur_state == 0)
        cur_state <= cur_state_RxD;
      else 
        cur_state <= cur_state_clk;
    end
  
  //next state logic
  always @ (cur_state)
    begin
      if (cur_state == state_last)
        next_state <= 0;
      else  
      	next_state <= cur_state + 1;
    end
  
  //save the first sample of a bit
  always @ (posedge first_sample_signal or negedge reset)
    begin
      if (!reset)
        first_sample <= 0;
      else
        first_sample <= RxD;
    end
  
  
  //save the framing error of the receiver
  //the frame error reset signal is used to reset the framing error when a new sequence of bits arrives
  
  reg temp_Rx_FERROR;
  always @ (posedge frame_error_signal or negedge reset or posedge frame_error_signal_reset)
    begin
      if (!reset)
        temp_Rx_FERROR <= 0;
      else if (frame_error_signal_reset)
        temp_Rx_FERROR <= 0;
      else
        temp_Rx_FERROR <= ((!first_sample & RxD)|(first_sample & !RxD))|temp_Rx_FERROR;
    end
        
   
  
  //save the data 
  always @ (posedge data_transfer_signal or negedge reset)
    begin
      if (!reset)
        data <= 0;
      else 
        data[cur_state - 1] <= RxD;
    end
  
  //write data to Rx_DATA once the transfer is complete
  always @ (posedge Rx_data_transfer_signal or negedge reset)
    begin
      if (!reset)
        Rx_DATA <= 0;
      else 
        Rx_DATA <= data[8:1];
    end
  
  

  
  always @ (cur_state or sampling_counter)
    begin
      if (!reset)
        begin
          reset_cur_state_RxD <= 0;
          Rx_data_transfer_signal <= 0;
          data_transfer_signal <= 0;
          baud_reset <= 0;
          Rx_VALID <= 0;
          Rx_FERROR <= 0;
          Rx_PERROR <= 0;
          first_sample_signal <= 0;
          frame_error_signal <= 0;
          frame_error_signal_reset <= 0;
        end
      else
        begin
          case(cur_state)
            0: //this is the output logic
              begin
                frame_error_signal <= 0;
                reset_cur_state_RxD <= 1;
                Rx_data_transfer_signal <= 0;
                data_transfer_signal <= 0;
                frame_error_signal_reset <= 0;
                first_sample_signal <= 0;
              	baud_reset <= 0;
                if (temp_Rx_FERROR == 0 && data[10] == 1 && data[0] == 0)
                  Rx_FERROR <= 0;
                else
                  Rx_FERROR <= 1;
                if (data[9] == parity(Rx_DATA))
                  Rx_PERROR <= 0;
                else
                  Rx_PERROR <= 1;
                if (data[9] == parity(Rx_DATA) && temp_Rx_FERROR == 0 && data[10] == 1 && data[0] == 0)
                  Rx_VALID <= 1;
                else
                  Rx_VALID <= 0;
              end
            default:
              begin
                frame_error_signal_reset <= 0;
                reset_cur_state_RxD <= 0;
                Rx_PERROR <= 0;
                Rx_FERROR <= 0;
                Rx_VALID <= 0;
                baud_reset <= 1;
					 
					 case (sampling_counter)
                  0: begin
                    if (cur_state == 1)
                      frame_error_signal_reset <= 1; //here change
                    else 
                      frame_error_signal_reset <= 0; //here change
                  end
                  default: frame_error_signal_reset <= 0; //here change
                endcase
                
                case (sampling_counter)
                  31: Rx_data_transfer_signal <= 1;
                  default : Rx_data_transfer_signal <= 0;
                endcase
                
                case (sampling_counter)
                  1: data_transfer_signal <= 1;
                  default: data_transfer_signal <=0;
                endcase
                
                case (sampling_counter)
                  1: frame_error_signal <= 0;
                  3: frame_error_signal <= 1;
                  5: frame_error_signal <= 1;
                  7: frame_error_signal <= 1;
                  9: frame_error_signal <= 1;
                  11: frame_error_signal <= 1;
                  13: frame_error_signal <= 1;
                  15: frame_error_signal <= 1;
                  17: frame_error_signal <= 1;
                  19: frame_error_signal <= 1;
                  21: frame_error_signal <= 1;
                  23: frame_error_signal <= 1;
                  25: frame_error_signal <= 1;
                  27: frame_error_signal <= 1;
                  29: frame_error_signal <= 1;
                  31: frame_error_signal <= 1;
                  default: frame_error_signal <= 0;
                endcase
                
                case (sampling_counter)
                  1: first_sample_signal <= 1;
                  default: first_sample_signal <=0;
                endcase
                
              end
          endcase
        end
    end   
endmodule