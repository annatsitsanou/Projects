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
        7 : limit <= 2;
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


module uart_receiver(reset, clk, Rx_DATA, baud_select, RX_EN, RxD, Rx_FERROR, Rx_PERROR, Rx_VALID, encryption_key); 
  input wire clk, reset;
  input wire [2:0] baud_select;
  input wire RX_EN;
  input wire RxD;
  output wire [7:0] Rx_DATA; //reg without decoder
  output reg Rx_FERROR;
  output reg Rx_PERROR;
  output reg Rx_VALID;
  input wire [7:0] encryption_key;
  
  
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
  
  
  decoder decoder_module(clk, reset, Rx_data_transfer_signal, Rx_DATA, data[8:1], encryption_key);
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
  
  /*
  //write data to Rx_DATA once the transfer is complete
  always @ (posedge Rx_data_transfer_signal or negedge reset)
    begin
      if (!reset)
        Rx_DATA <= 0;
      else 
        Rx_DATA <= data[8:1];
    end
  */
  

  
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
                if (data[9] == parity(data[8:1]))
                  Rx_PERROR <= 0;
                else
                  Rx_PERROR <= 1;
                if (data[9] == parity(data[8:1]) && temp_Rx_FERROR == 0 && data[10] == 1 && data[0] == 0)
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

module uart_transmitter(reset, clk, baud_select, Tx_DATA, Tx_WR, TX_EN, TxD, Tx_BUSY, encryption_key);
  input wire clk, reset;
  input wire [7:0] Tx_DATA;
  input wire [2:0] baud_select;
  input wire TX_EN;   //not used
  input wire Tx_WR;
  output reg TxD;
  output reg Tx_BUSY;
  input wire [7:0] encryption_key;
  
  
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
  
  wire [7:0] data;       //stored data
  encoder encoder_module(clk, Tx_WR, cur_state, Tx_DATA, data, encryption_key);
 
  reg baud_reset;
  sampling_timing sample(.clk(clk), .reset(baud_reset), .baud_select(baud_select), .sample_clk(sample_clk), .sampling_counter(sampling_counter));
  
  
  reg [3:0] cur_state;  //current state of the counter
  reg [3:0] next_state; //next state of the counter
  

  parameter state_wait = 0;
  parameter state_last = 11;
  
  
  
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
    
  
  /*
  always @ (posedge clk)
    begin
      //the cur_state == 0 might cause problems
      if (Tx_WR && cur_state == 0)
        data <= Tx_DATA;
      else 
        data <= data;
    end
  */
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
              TxD <= parity(data[7:0]);
            
            else
              TxD <= data[cur_state - 2];
            Tx_BUSY <= 1;
          end
      endcase
    end
endmodule




		
module channel_uart_receiver(clk, reset, baud_select, RX_EN, RxD, data, encryption_key);
  input wire clk, reset;
  input wire [2:0] baud_select;
  input wire RX_EN;
  input wire RxD;
  output reg [15:0] data;
  input wire [7:0] encryption_key;
  wire [7:0] Rx_DATA;
  wire Rx_FERROR;
  wire Rx_PERROR;
  wire Rx_VALID;
  
  uart_receiver receiver(.clk(clk),.reset(reset), .Rx_DATA(Rx_DATA), .baud_select(baud_select), .RX_EN(RX_EN), .RxD(RxD), .Rx_VALID(Rx_VALID), .Rx_FERROR(Rx_FERROR), .Rx_PERROR(Rx_PERROR), .encryption_key(encryption_key));
  
  
  
  //reg [15:0] incomplete_data;
  //wire [6:0] display;
  //wire an3, an2, an1, an0;
  
  //anode anode_module(.display(display),.char0(data[15:12]),.char1(data[11:8]),.char2(data[7:4]),.char3(data[3:0]),.an3(an3),.an2(an2),.an1(an1),.an0(an0),.clk(clk),.reset(reset));
  
  
  reg [1:0] cur_state;
  reg [1:0] next_state;
  reg transfer_complete;
  
  parameter limit = 2;
  
  
  always @ (negedge reset or posedge (Rx_VALID || Rx_PERROR || Rx_FERROR))
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
  
  //reg error_first_data;
  //reg error_second_data;
  reg first_data;
  reg second_data;
  reg error;
  reg [7:0] first_8_bit;
  reg [7:0] second_8_bit;
  //reg word_error;
  always @ (cur_state)
    begin
      case(cur_state)
        0:
          begin
            //error_first_data <= 0;
            //error_second_data <= 0;
            first_data <= 0;
  			second_data <= 0; 
            error <= 1;
          end
        1: 
          begin
            if (Rx_VALID)
              error <= 0;
              //error_first_data <= 0;
            else
              error <= 1;
              //error_first_data <= 1;
            //error_second_data <= 0;
            first_data <= 1;
  			second_data <= 0; 
            //error <= 0;
          end
        2: 
          begin
            if (Rx_VALID)
              begin
                if (error == 0)
                  error <= 0;
                else 
                  error <= 1;
              //error_second_data <= 0;
              end
            else
              error <= 1;
              //error_second_data <= 1;
            //error_first_data <= 0;
            first_data <= 0;
  			second_data <= 1;
            //error <= 0;
          end
        default :
          begin
            //error_first_data <= 0;
            //error_second_data <= 0;
            first_data <= 0;
  			second_data <= 0; 
            error <= 0;
          end
      endcase          
    end
  
  always @ (negedge reset or posedge first_data or posedge second_data)
    begin
      if (!reset)
        begin
          //incomplete_data <= 0;
      	  transfer_complete <= 0;
          first_8_bit <= 0;
          second_8_bit <= 0;
          //word_error <= 0;
        end
      else if (first_data)
        begin
          first_8_bit <= Rx_DATA;
          second_8_bit <= Rx_DATA;
          //incomplete_data[7:0] <= Rx_DATA;
          transfer_complete <= 0;
        end
      else
        begin
          second_8_bit <= Rx_DATA;
          first_8_bit <= first_8_bit;
          //incomplete_data[15:8] <= Rx_DATA;
          transfer_complete <= 1;
        end
    end
            
      

  
  
  
  always @ (posedge transfer_complete or negedge reset)
    begin
      if (!reset)
        data <= 65535;   
      else if (transfer_complete) 
        begin
          if (error == 0)
            begin
              data[7:0] <= second_8_bit;
              data[15:8] <= first_8_bit;
            end
          else
            data <= 65535;
        end
      else
        data <= data; 
    end
      

    
endmodule

module channel_uart_transmitter(clk, reset, data, transfer_data, baud_select, TxD, encryption_key);
  input wire [15:0] data;
  input wire clk, reset;
  input wire [2:0] baud_select;
  input wire transfer_data;
  output wire TxD;
  input wire [7:0] encryption_key;
  
  reg TX_EN;
  reg Tx_WR;
  wire Tx_BUSY;
  reg [15:0] stored_data;
  reg [7:0] Tx_DATA;
  
 uart_transmitter transmitter(.reset(reset),.clk(clk),.baud_select(baud_select),.Tx_DATA(Tx_DATA),.Tx_WR(Tx_WR),.TX_EN(TX_EN),.TxD(TxD),.Tx_BUSY(Tx_BUSY),.encryption_key(encryption_key));

  reg [1:0] cur_state;
  reg [1:0] next_state;

 parameter sWait = 0,
  first_word = 1,
  second_word = 2,
  limit = 2;
	
  reg [1:0] cur_state_data_transfer;
  always @ (posedge clk or negedge reset)
    begin
      if (!reset)
        cur_state_data_transfer <= sWait;
      else if (transfer_data)
        begin
          if (cur_state_data_transfer == 0)
            cur_state_data_transfer <= next_state;
          else
            cur_state_data_transfer <= cur_state;
        end
      else
        cur_state_data_transfer <= cur_state;
    end
  
  reg [1:0] cur_state_transmit;
  always @ (negedge Tx_BUSY or negedge reset)
    begin
      if (!reset)
        cur_state_transmit <= 0;
      else
        cur_state_transmit <= next_state;
    end
  
  always @ (cur_state_transmit or cur_state_data_transfer)
    begin
      if (cur_state == 0)
        cur_state <= cur_state_data_transfer;
      else
        cur_state <= cur_state_transmit;
    end
  
 always @ (cur_state)
   begin: NEXT_STATE_LOGIC
     if (cur_state == limit)
       next_state <= 0;
     else
       next_state <= cur_state + 1;
   end
  
  
  always @ (posedge clk)
    begin
      if (transfer_data && cur_state == 0)
        stored_data <= data;
      else 
        stored_data <= stored_data;
    end
  
  
 always @ (cur_state)
	begin: OUTPUT_LOGIC
      case(cur_state)
        sWait: 
          begin
            Tx_WR = 0;
            Tx_DATA <= 0;
          end
        first_word: 
          begin
            Tx_WR = 1;
            Tx_DATA <= stored_data[15:8];
          end
        second_word: 
          begin
            Tx_WR = 1;
            Tx_DATA <= stored_data[7:0];
          end
        default: 
          begin
            Tx_WR = 0;
            Tx_DATA <= 0;
          end
      endcase
    end
endmodule 


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
          10: LED = 7'b1111110;  //paula
          11: LED = 7'b0111000;  //F  

          12: LED = 7'b1111111;  //keno
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


module data_to_display(clk, reset, RxD, baud_select, display, an3, an2, an1, an0,encryption_key);
  input wire clk, reset, RxD;
  input [2:0] baud_select;
  output wire [6:0] display;
  output wire an3, an2, an1, an0;
  input wire [7:0] encryption_key;
  
  reg RX_EN;
  wire [15:0] data;
  
  channel_uart_receiver channel_uart_receiver_module(.clk(clk),.reset(reset), .baud_select(baud_select), .RX_EN(RX_EN), .RxD(RxD), .data(data), .encryption_key(encryption_key));
  anode anode_module(.display(display),.char3(data[15:12]),.char2(data[11:8]),.char1(data[7:4]),.char0(data[3:0]),.an3(an3),.an2(an2),.an1(an1),.an0(an0),.clk(clk),.reset(reset));
  
      
endmodule


module encoder(clk, Tx_WR, cur_state, data, encrypted_data, encryption_key);
  input wire clk, Tx_WR;
  input wire [7:0] data;
  input wire [3:0] cur_state;
  input wire [7:0] encryption_key;
  output reg [7:0] encrypted_data;
  reg [8:0] temp_data;
  
  always @ (posedge clk)
    begin
      //the cur_state == 0 might cause problems
      if (Tx_WR && cur_state == 0)
        begin
          temp_data[8] <= 1;
          temp_data[7:0] <= data;
          encrypted_data <= data - encryption_key;
        end
      else 
        encrypted_data <= encrypted_data;
    end
endmodule


module decoder(clk, reset, Rx_data_transfer_signal, data, encrypted_data, encryption_key);
  input wire clk, reset, Rx_data_transfer_signal;
  input wire [7:0] encrypted_data;
  input wire [7:0] encryption_key;
  output reg [7:0] data;
  
  always @ (posedge Rx_data_transfer_signal or negedge reset)
    begin
      if (!reset)
        data <= 0;
      else 
        data <= encrypted_data + encryption_key;
    end
endmodule