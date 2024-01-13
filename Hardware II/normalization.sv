module normalize_mult(output logic sticky, guard,
					output logic [22:0] norm_mantissa,
					output logic [9:0] norm_exponent,
					input logic [47:0] p, 
					input logic [9:0] exponent);
always_comb
begin					
if(p[47] == 1) 
	begin 
	norm_exponent <=  exponent + 1;
	norm_mantissa <= p[46:24];
	guard <= p[23];
	sticky <= |p[22:0];
	end
else if(p[47] == 0)
	begin
	norm_exponent <= exponent;
	norm_mantissa <= p[45:23];
	guard <= p[22];
	sticky <= |p[21:0];
	end
else
	begin
	norm_mantissa <= 0;
	norm_exponent <= 0;
	guard <= 0;
	sticky <= 0;
	end
end
endmodule