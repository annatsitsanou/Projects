module fp_mult #(parameter round = "away_zero")
				(output logic [31:0] z,
				output logic [7:0] status,
				input logic [31:0] a, b); 

	
	logic sign, sticky, guard, inexact, overflow, underflow, zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;
	logic [9:0] exponent, norm_exponent, post_round_exponent;
	logic [47:0] mantissa; 
	logic [22:0] norm_mantissa;
	logic [23:0] mant_to_round, post_round_mantissa;
	logic [24:0] round_mantissa;
	logic [31:0] z_calc;
	
	
	normalize_mult n1(.sticky(sticky),.guard(guard),.norm_exponent(norm_exponent),.norm_mantissa(norm_mantissa),.p(mantissa),.exponent(exponent));
	round_mult r1(.result(round_mantissa),.inexact(inexact),.sign(sign),.sticky(sticky),.guard(guard),.mantissa(mant_to_round));
	exception_mult e1(.*);
	
	always_comb 
	begin
	sign <= a[31] ^ b[31];
	
	exponent <= a[30:23] + b[30:23] - 127;
	
	
	mantissa <= add_leading_one(a[22:0])  * add_leading_one(b[22:0]);
	end
	
	
	
	always_comb
	begin
	mant_to_round = add_leading_one(norm_mantissa);
	end
	
	always @ (round_mantissa)
	begin 
		if(round_mantissa[24])
			begin
				post_round_mantissa <= round_mantissa >> 1;
				post_round_exponent <= norm_exponent + 1;
			end
		else
			begin
				post_round_mantissa <= round_mantissa;
				post_round_exponent <= norm_exponent;
			end
	end
	

	always_comb begin
		if (post_round_exponent[7:0] > 8'b11111111) overflow = 1;
		else overflow = 0;
		if (norm_exponent[7:0] < 0) underflow = 1;
		else underflow = 0;
	end
	
	always_comb 
	begin
		z_calc[31] <= sign;
		z_calc[30:23] <= post_round_exponent[7:0];
		z_calc[22:0] <= post_round_mantissa[22:0];
	end
	
	always_comb
	begin 
		status[0] <= zero_f;
		status[1] <= inf_f;
		status[2] <= nan_f;
		status[3] <= tiny_f;
		status[4] <= huge_f;
		status[5] <= inexact_f;
		status[6] <= 1'b0;
		status[7] <= 1'b0;
	end

endmodule

function [23:0] add_leading_one(logic [22:0] variable);
	
	return variable + 24'b100000000000000000000000;
endfunction