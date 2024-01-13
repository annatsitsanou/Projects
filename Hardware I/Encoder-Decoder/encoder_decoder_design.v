`timescale 1ns/1ps
//Ok change function 
//data -> encypted data -> decrypted_data
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
  /*
  always @ (data)
    begin
      temp_data[8] <= 1;
          temp_data[7:0] <= data;
          encrypted_data <= data - encryption_key;
    end
  
  */
endmodule

//Ok change function
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
  /*
  always @ (encrypted_data)
    begin
      data <= encrypted_data + encryption_key;
    end
   */
  
endmodule

 