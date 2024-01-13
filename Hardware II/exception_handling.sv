module exception_mult#(parameter round = "away_zero")(output logic [31:0] z,
							 output logic zero_f, inf_f, nan_f, tiny_f, huge_f,inexact_f,
							 input logic [31:0] z_calc,a,b,
							 input logic overflow, underflow, inexact);

typedef enum {ZERO,INF,NORM,MIN_NORM,MAX_NORM} interp_t;
interp_t typeA, typeB;

function interp_t num_interp(logic [31:0] c);
	if (c[30:23] == 0 && c[22:0] == 0)
		return ZERO;
	else if(c[30:23] == 8'b11111111 && c[22:0] == 0)
		return INF;
	else if(c[30:23] == 8'b11111111 && c[22:0] > 0)
		return INF;
	else if(c[30:23] == 0 && c[22:0] > 0)
		return ZERO;
	else
		return NORM;
endfunction

function [30:0] z_num(interp_t num_type);
	unique case(num_type)
		ZERO: return 0;
	    INF: return 31'b1111111100000000000000000000000;
  MIN_NORM: return 31'b0000000100000000000000000000000;
  MAX_NORM: return 31'b1111111011111111111111111111111;
	endcase
endfunction	

always_comb begin
	zero_f = 0;
	inf_f = 0;
	nan_f = 0;
	tiny_f = 0;
	huge_f = 0;
	inexact_f = 0;
	typeA = num_interp(a);
	typeB = num_interp(b);
	if(typeA == ZERO && typeB == ZERO)
		begin
			z[31] = a[31]^ b[31];
			z[30:0] = z_num(ZERO);
			zero_f = 1;
		end
	else if(typeA == ZERO && typeB == NORM)
		begin
			z[31] = a[31] ^ b[31];
			z[30:0] = z_num(ZERO);
			zero_f = 1;
		end
	else if(typeA == ZERO && typeB == INF)
		begin
			z[31] = 0;
			z[30:0] = z_num(INF);
			nan_f = 1;
			inf_f = 1;
		end
	else if(typeA == INF && typeB == INF)
		begin
			z[31] = a[31] ^ b[31];
			z[30:0] = z_num(INF);
			inf_f = 1;
		end
	else if(typeA == INF && typeB == NORM)
		begin
			z[31] = a[31] ^ b[31];
			z[30:0] = z_num(INF);
			inf_f = 1;
		end
	else if(typeA == INF && typeB == ZERO)
		begin
			z[31] = 0;
			z[30:0] = z_num(INF);
			nan_f = 1;
			inf_f = 1;
		end
	else if(typeA == NORM && typeB == ZERO)
		begin
			z[31] = a[31] ^ b[31];
			z[30:0] = z_num(ZERO);
			zero_f = 1;
		end
	else if(typeA == NORM && typeB == INF)
		begin
			z[31] = a[31] ^ b[31];
			z[30:0] = z_num(INF);
			inf_f = 1;
		end
	else
		begin
			if(overflow)
				begin
					if(round == "IEEE_near" || round == "IEEE_zero" || round == "near_up")
						begin
							z[31] = z_calc[31];
							z[30:0] = z_num(MAX_NORM);
							huge_f = 1;
						end
					else
						begin
							z[31] = z_calc[31];
							z[30:0] = z_num(INF);
							inf_f = 1;
						end
				end
			else if(underflow)
				begin
					if(round == "IEEE_near" || round == "IEEE_zero" || round == "near_up")
						begin
							z[31] = z_calc[31];
							z[30:0] = z_num(MIN_NORM);
							tiny_f = 1;
						end
					else
						begin
							z[31] = z_calc[31];
							z[30:0] = z_num(ZERO);
							zero_f = 1;
						end
				end
			else
				begin
					z = z_calc;
					inexact_f = inexact;
				end
		end
end
endmodule