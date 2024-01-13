`timescale 1ns/1ps
module fp_tb;

logic [31:0] z;
logic [31:0] a;
logic [31:0] b;
logic [7:0] status;
bit clk, rst;

parameter round = "away_zero";

fp_mult_top #(round) fp1(.d_z(z),.d_a(a),.d_clk(clk),.d_rst(rst),.d_b(b),.d_status(status));

initial begin 
	clk = 0;
	a = 0;
	b = 0;
	rst = 1;
	
	#50
	rst = 0;
	
	
	//first part
	a = $urandom(); 
	b = $urandom();
	#100
	a = $urandom(); 
	b = $urandom();
	#200
	a = $urandom(); 
	b = $urandom();
	#300
	a = $urandom(); 
	b = $urandom();
	
	//second part
	#400
	a = string_to_binary("neg_nan");
	b = string_to_binary("neg_nan");
	#500
	a = string_to_binary("neg_nan");
	b = string_to_binary("pos_nan");
	#600
	a = string_to_binary("neg_nan");
	b = string_to_binary("neg_inf");
	#700
	a = string_to_binary("neg_nan");
	b = string_to_binary("pos_inf");
	#800
	a = string_to_binary("neg_nan");
	b = string_to_binary("neg_norm");
	#900
	a = string_to_binary("neg_nan");
	b = string_to_binary("pos_norm");
	#1000
	a = string_to_binary("neg_nan");
	b = string_to_binary("neg_denorm");
	#1100
	a = string_to_binary("neg_nan");
	b = string_to_binary("pos_denorm");
	#1200
	a = string_to_binary("neg_nan");
	b = string_to_binary("neg_zero");
	#1300
	a = string_to_binary("neg_nan");
	b = string_to_binary("pos_zero");
	
	
	#1400
   a = string_to_binary("pos_nan");
	b = string_to_binary("neg_nan");
	#1500
	a = string_to_binary("pos_nan");
	b = string_to_binary("pos_nan");
	#1600
	a = string_to_binary("pos_nan");
	b = string_to_binary("neg_inf");
	#1700
	a = string_to_binary("pos_nan");
	b = string_to_binary("pos_inf");
	#1800
	a = string_to_binary("pos_nan");
	b = string_to_binary("neg_norm");
	#1900
	a = string_to_binary("pos_nan");
	b = string_to_binary("pos_norm");
	#2000
	a = string_to_binary("pos_nan");
	b = string_to_binary("neg_denorm");
	#2100
	a = string_to_binary("pos_nan");
	b = string_to_binary("pos_denorm");
	#2200
	a = string_to_binary("pos_nan");
	b = string_to_binary("neg_zero");
	#2300
	a = string_to_binary("pos_nan");
	b = string_to_binary("pos_zero");
	
	
	#2400
	a = string_to_binary("neg_inf");
	b = string_to_binary("neg_nan");
	#2500
	a = string_to_binary("neg_inf");
	b = string_to_binary("pos_nan");
	#2600
	a = string_to_binary("neg_inf");
	b = string_to_binary("neg_inf");
	#2700
	a = string_to_binary("neg_inf");
	b = string_to_binary("pos_inf");
	#2800
	a = string_to_binary("neg_inf");
	b = string_to_binary("neg_norm");
	#2900
	a = string_to_binary("neg_inf");
	b = string_to_binary("pos_norm");
	#3000
	a = string_to_binary("neg_inf");
	b = string_to_binary("neg_denorm");
	#3100
	a = string_to_binary("neg_inf");
	b = string_to_binary("pos_denorm");
	#3200
	a = string_to_binary("neg_inf");
	b = string_to_binary("neg_zero");
	#3300
	a = string_to_binary("neg_inf");
	b = string_to_binary("pos_zero");
	
	
	#3400
	a = string_to_binary("pos_inf");
	b = string_to_binary("neg_nan");
	#3500
	a = string_to_binary("pos_inf");
	b = string_to_binary("pos_nan");
	#3600
	a = string_to_binary("pos_inf");
	b = string_to_binary("neg_inf");
	#3700
	a = string_to_binary("pos_inf");
	b = string_to_binary("pos_inf");
	#3800
	a = string_to_binary("pos_inf");
	b = string_to_binary("neg_norm");
	#3900
	a = string_to_binary("pos_inf");
	b = string_to_binary("pos_norm");
	#4000
	a = string_to_binary("pos_inf");
	b = string_to_binary("neg_denorm");
	#4100
	a = string_to_binary("pos_inf");
	b = string_to_binary("pos_denorm");
	#4200
	a = string_to_binary("pos_inf");
	b = string_to_binary("neg_zero");
	#4300
	a = string_to_binary("pos_inf");
	b = string_to_binary("pos_zero");
	
	
	#4400
	a = string_to_binary("neg_norm");
	b = string_to_binary("neg_nan");
	#4500
	a = string_to_binary("neg_norm");
	b = string_to_binary("pos_nan");
	#4600
	a = string_to_binary("neg_norm");
	b = string_to_binary("neg_inf");
	#4700
	a = string_to_binary("neg_norm");
	b = string_to_binary("pos_inf");
	#4800
	a = string_to_binary("neg_norm");
	b = string_to_binary("neg_norm");
	#4900
	a = string_to_binary("neg_norm");
	b = string_to_binary("pos_norm");
	#5000
	a = string_to_binary("neg_norm");
	b = string_to_binary("neg_denorm");
	#5100
	a = string_to_binary("neg_norm");
	b = string_to_binary("pos_denorm");
	#5200
	a = string_to_binary("neg_norm");
	b = string_to_binary("neg_zero");
	#5300
	a = string_to_binary("neg_norm");
	b = string_to_binary("pos_zero");
	
	
	#5400
	a = string_to_binary("pos_norm");
	b = string_to_binary("neg_nan");
	#5500
	a = string_to_binary("pos_norm");
	b = string_to_binary("pos_nan");
	#5600
	a = string_to_binary("pos_norm");
	b = string_to_binary("neg_inf");
	#5700
	a = string_to_binary("pos_norm");
	b = string_to_binary("pos_inf");
	#5800
	a = string_to_binary("pos_norm");
	b = string_to_binary("neg_norm");
	#5900
	a = string_to_binary("pos_norm");
	b = string_to_binary("pos_norm");
	#6000
	a = string_to_binary("pos_norm");
	b = string_to_binary("neg_denorm");
	#6100
	a = string_to_binary("pos_norm");
	b = string_to_binary("pos_denorm");
	#6200
	a = string_to_binary("pos_norm");
	b = string_to_binary("neg_zero");
	#6300
	a = string_to_binary("pos_norm");
	b = string_to_binary("pos_zero");
	
	
	#6400
	a = string_to_binary("neg_denorm");
	b = string_to_binary("neg_nan");
	#6500
	a = string_to_binary("neg_denorm");
	b = string_to_binary("pos_nan");
	#6600
	a = string_to_binary("neg_denorm");
	b = string_to_binary("neg_inf");
	#6700
	a = string_to_binary("neg_denorm");
	b = string_to_binary("pos_inf");
	#6800
	a = string_to_binary("neg_denorm");
	b = string_to_binary("neg_norm");
	#6900
	a = string_to_binary("neg_denorm");
	b = string_to_binary("pos_norm");
	#7000
	a = string_to_binary("neg_denorm");
	b = string_to_binary("neg_denorm");
	#7100
	a = string_to_binary("neg_denorm");
	b = string_to_binary("pos_denorm");
	#7200
	a = string_to_binary("neg_denorm");
	b = string_to_binary("neg_zero");
	#7300
	a = string_to_binary("neg_denorm");
	b = string_to_binary("pos_zero");
	

	#7400
	a = string_to_binary("pos_denorm");
	b = string_to_binary("neg_nan");
	#7500
	a = string_to_binary("pos_denorm");
	b = string_to_binary("pos_nan");
	#7600
	a = string_to_binary("pos_denorm");
	b = string_to_binary("neg_inf");
	#7700
	a = string_to_binary("pos_denorm");
	b = string_to_binary("pos_inf");
	#7800
	a = string_to_binary("pos_denorm");
	b = string_to_binary("neg_norm");
	#7900
	a = string_to_binary("pos_denorm");
	b = string_to_binary("pos_norm");
	#8000
	a = string_to_binary("pos_denorm");
	b = string_to_binary("neg_denorm");
	#8100
	a = string_to_binary("pos_denorm");
	b = string_to_binary("pos_denorm");
	#8200
	a = string_to_binary("pos_denorm");
	b = string_to_binary("neg_zero");
	#8300
	a = string_to_binary("pos_denorm");
	b = string_to_binary("pos_zero");


	
	#8400
	a = string_to_binary("neg_zero");
	b = string_to_binary("neg_nan");
	#8500
	a = string_to_binary("neg_zero");
	b = string_to_binary("pos_nan");
	#8600
	a = string_to_binary("neg_zero");
	b = string_to_binary("neg_inf");
	#8700
	a = string_to_binary("neg_zero");
	b = string_to_binary("pos_inf");
	#8900
	a = string_to_binary("neg_zero");
	b = string_to_binary("neg_norm");
	#9000
	a = string_to_binary("neg_zero");
	b = string_to_binary("pos_norm");
	#9100
	a = string_to_binary("neg_zero");
	b = string_to_binary("neg_denorm");
	#9200
	a = string_to_binary("neg_zero");
	b = string_to_binary("pos_denorm");
	#9300
	a = string_to_binary("neg_zero");
	b = string_to_binary("neg_zero");
	#9400
	a = string_to_binary("neg_zero");
	b = string_to_binary("pos_zero");
	
	
	#9500
	a = string_to_binary("pos_zero");
	b = string_to_binary("neg_nan");
	#9600
	a = string_to_binary("pos_zero");
	b = string_to_binary("pos_nan");
	#9700
	a = string_to_binary("pos_zero");
	b = string_to_binary("neg_inf");
	#9800
	a = string_to_binary("pos_zero");
	b = string_to_binary("pos_inf");
	#9900
	a = string_to_binary("pos_zero");
	b = string_to_binary("neg_norm");
	#10000
	a = string_to_binary("pos_zero");
	b = string_to_binary("pos_norm");
	#10100
	a = string_to_binary("pos_zero");
	b = string_to_binary("neg_denorm");
	#10200
	a = string_to_binary("pos_zero");
	b = string_to_binary("pos_denorm");
	#10300
	a = string_to_binary("pos_zero");
	b = string_to_binary("neg_zero");
	#10400
	a = string_to_binary("pos_zero");
	b = string_to_binary("pos_zero");

	#20000 $finish;
end

always #10 clk = !clk;

always @(z) 
begin
	if( z != multiplication(round,a,b))
		$display("Error: different results");
	else 
		$display("Correct multiplication");
end
endmodule


function [31:0] string_to_binary(string corner_case);
	if(corner_case == "neg_nan")
		return 32'b11111111100000010000000000000000;
	else if(corner_case == "pos_nan")
		return 32'b01111111100000000000001000000000;
	else if(corner_case == "neg_inf")
		return 32'b11111111100000000000000000000000;
	else if(corner_case == "pos_inf")
		return 32'b01111111100000000000000000000000;
	else if(corner_case == "neg_norm")
		return 32'b10001101100000010000101010010100;
	else if(corner_case == "pos_norm")
		return 32'b00110010100001010001010100101010;
	else if(corner_case == "neg_denorm")
		return 32'b10000000000000010000000000000000;
	else if(corner_case == "pos_denorm")
		return 32'b00000000000000000000001000000000;
	else if(corner_case == "neg_zero")
		return 32'b10000000000000000000000000000000;
	else if(corner_case == "pos_zero")
		return 32'b00000000000000000000000000000000;
	else
		return 0;
endfunction

// This function should be used as the baseline for verifying the correctness of your circuit/design.
// The output of this function for all possible cases should be compared with the output of your SV code and should match 100%
// See related subsection 3.2.7 (p. 15) in the manual and description of this coursework that has been provided to you. 
    
	
//This function will be given for the exercises


 function [31:0] multiplication (string round, logic [31:0] a, logic [31:0] b);
    bit [31:0] result;
    if(a[30:23] == '0) a[22:0] = '0; 
    if(b[30:23] == '0) b[22:0] = '0; 
    if(a[30:23] == '1) a[22:0] = '0;
    if(b[30:23] == '1) b[22:0] = '0; 
    
    if((a[30:23] == '1 && b[30:23] == '0) || (a[30:23] == '0 && b[30:23] == '1)) result = {1'b0, {8{1'b1}}, {23{1'b0}}}; 
    else begin
        result = $shortrealtobits($bitstoshortreal(a) * $bitstoshortreal(b)); 
        case (round)
            //IEEE_NEAR ROUNDING
            "IEEE_near": begin
                if(result[30:23] == '1) result[22:0] = '0;
                if(result[30:23] == '0) result[22:0] = '0;
            end
            //IEEE_ZERO ROUNDING
            "IEEE_zero": begin
                //Round towards zero instead if rounded up and positive
                if($bitstoshortreal(result) > ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                    begin 
                        if($bitstoshortreal(result) > 0) 
                            begin
                                result = result - 1; 
                            end
                    end
                //Round towards zero instead if rounded down and negative
                if($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                    begin
                        if($bitstoshortreal(result) < 0) 
                            begin
                                result = result - 1; 
                            end
                    end
                if(result[30:23] == '0) result[22:0] = '0;
            end
            //AWAY_ZERO ROUNDING
            "away_zero": begin
                //Check if the result is denormal and round to minNormal
                if((result[30:23] == '0 && result[22:0] != '0) || (a[30:23] != '0 && b[30:23] != '0 && result[30:23] == '0 && result[22:0] == '0)) begin
                    result = {result[31], {7{1'b0}}, 1'b1, {23{1'b0}}};
                end
                else begin
                    //Round away from zero instead if rounded up and negative
                    if($bitstoshortreal(result) > ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin 
                            if($bitstoshortreal(result) < 0) 
                                begin
                                    result = result + 1; 
                                end
                        end
                    //Round away from zero instead if rounded down and positive
                    if($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin
                            if($bitstoshortreal(result) > 0) 
                                begin
                                    result = result + 1; 
                                end
                        end
                end
                if(result[30:23] == '1) result[22:0] = '0;
            end
            //IEEE_PINF ROUNDING
            "IEEE_pinf": begin
                //Check if the result is denormal and round to minNormal, but only for positives
                if((result[31] == 0 && result[30:23] == '0 && result[22:0] != '0) || (result[31] == 0 &&  a[30:23] != '0 && b[30:23] != '0 && result[30:23] == '0 && result[22:0] == '0)) begin
                    result = {{8{1'b0}}, 1'b1, {23{1'b0}}};
                end
                else begin
                    //Round towards positive infinity instead if rounded down and positive
                    if($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin 
                            if($bitstoshortreal(result) > 0) 
                                begin
                                    result = result + 1; 
                                end
                        end
                    //Round towards positive infinity instead if rounded down and negative
                    if($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin
                            if($bitstoshortreal(result) < 0) 
                                begin
                                    result = result - 1; 
                                end
                        end
                end
                if(result[30:23] == '0) result[22:0] = '0;
            end
            //IEEE_NINF ROUNDING
            "IEEE_ninf": begin
                //Check if the result is denormal and round to minNormal, but only for negatives
                if((result[31] == 1 && result[30:23] == '0 && result[22:0] != '0) || (result[31] == 1 &&  a[30:23] != '0 && b[30:23] != '0 && result[30:23] == '0 && result[22:0] == '0)) begin
                    result = {1'b1, {7{1'b0}}, 1'b1, {23{1'b0}}};
                end
                else begin
                    //Round towards negative infinity instead if rounded up and positive
                    if($bitstoshortreal(result) > ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin 
                            if($bitstoshortreal(result) > 0) 
                                begin
                                    result = result - 1; 
                                end
                        end
                    //Round towards negative infinity instead if rounded up and negative
                    if($bitstoshortreal(result) > ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin
                            if($bitstoshortreal(result) < 0) 
                                begin
                                    result = result + 1; 
                                end
                        end
                end
                if(result[30:23] == '0) result[22:0] = '0;
            end
            //NEAR_UP ROUNDING
            "near_up": begin
                //Round towards positive infinity if rounded down, negative and in the middle
                if(($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b)))) 
                    begin
                        if(($bitstoshortreal(result) - ($bitstoshortreal(a) * $bitstoshortreal(b))) == (($bitstoshortreal(a) * $bitstoshortreal(b)) - $bitstoshortreal(result-1))) 
                            begin
                                if($bitstoshortreal(result) < 0) 
                                    begin
                                        result = result - 1;
                                    end
                            end
                    end
                
                //Round towards positive infinity if rounded down, positive and in the middle
                if(($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b)))) 
                    begin
                        if(($bitstoshortreal(result+1) - ($bitstoshortreal(a) * $bitstoshortreal(b))) == (($bitstoshortreal(a) * $bitstoshortreal(b)) - $bitstoshortreal(result))) 
                            begin
                                if($bitstoshortreal(result) > 0) 
                                    begin
                                        result = result + 1;
                                    end
                            end
                    end
                
                if(result[30:23] == '1) result[22:0] = '0;
                if(result[30:23] == '0) result[22:0] = '0;
            end
    endcase
    end
    
    return result;
 endfunction

 