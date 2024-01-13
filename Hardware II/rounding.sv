module round_mult#(parameter round = "away_zero")(output logic [24:0] result,
						output logic inexact,
						input logic [23:0] mantissa,
						input logic sign, sticky, guard);
						
						
always_comb
begin 
if(guard == 0 && sticky == 0) 
	begin
	inexact = 0;
	end
else
	inexact = 1;
end

always_comb
begin
case(round)
	"IEEE_near": begin
						if (guard == 0) 
							result = mantissa;
						else result = mantissa + 1;
						end
	"IEEE_zero": result = mantissa;
	"IEEE_pinf": begin
						if(sign == 0) result = mantissa + 1;
						else result = mantissa;
					 end
	"IEEE_ninf": begin
						if(sign == 1) result = mantissa + 1;
						else result = mantissa;
					 end
	  "near_up": begin
						if (guard == 0) result = mantissa;
						else result = mantissa + 1;
					 end
	"away_zero": result = mantissa + 1;	
		 default: begin
						if (guard == 0) 
							result = mantissa;
						else result = mantissa + 1;
					 end
	endcase 
end 


endmodule