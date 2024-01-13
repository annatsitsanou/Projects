module test_status_bits(input clk, rst,
					  input [7:0] status,
					  input [31:0] z, a, b);
	
always @(posedge clk)
	begin
		if(!rst) begin
		zeroANDinf: assert ((!status[0] && !status[1]) || (status[0]^status[1])) $display("\n",$stime,,,"%m passed\n");
		else
			$fatal("\n",$stime,,,"%m assert failled \n");
		zeroANDnan: assert ((!status[0] && !status[2]) || (status[0]^status[2])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
	  zeroANDtiny: assert ((!status[0] && !status[3]) || (status[0]^status[3])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
	  zeroANDhuge: assert ((!status[0] && !status[4]) || (status[0]^status[4])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
  zeroANDinexact: assert ((!status[0] && !status[5]) || (status[0]^status[5])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
	zeroANDunused: assert ((!status[0] && !status[6]) || (status[0]^status[6])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
 zeroANDdivbytwo: assert ((!status[0] && !status[7]) || (status[0]^status[7])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
	   infANDtiny: assert ((!status[1] && !status[3]) || (status[1]^status[3])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
	   infANDhuge: assert ((!status[1] && !status[4]) || (status[1]^status[4])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
	infANDinexact: assert ((!status[1] && !status[5]) || (status[1]^status[5])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");		
	 infANDunused: assert ((!status[1] && !status[6]) || (status[1]^status[6])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
  infANDdivbytwo: assert ((!status[1] && !status[7]) || (status[1]^status[7])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
	   nanANDtiny: assert ((!status[2] && !status[3]) || (status[2]^status[3])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");		
	   nanANDhuge: assert ((!status[2] && !status[4]) || (status[2]^status[4])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
	nanANDinexact: assert ((!status[2] && !status[5]) || (status[2]^status[5])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");	
	 nanANDunused: assert ((!status[2] && !status[6]) || (status[2]^status[6])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");		
  nanANDdivbytwo: assert ((!status[2] && !status[7]) || (status[2]^status[7])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");		
	  tinyANDhuge: assert ((!status[3] && !status[4]) || (status[3]^status[4])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");		
  inexactANDtiny: assert ((!status[3] && !status[5]) || (status[3]^status[5])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");		
	tinyANDunused: assert ((!status[3] && !status[6]) || (status[3]^status[6])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");		
 tinyANDdivbytwo: assert ((!status[3] && !status[7]) || (status[3]^status[7])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");	
  hugeANDinexact: assert ((!status[4] && !status[5]) || (status[4]^status[5])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");			
	hugeANDunused: assert ((!status[4] && !status[6]) || (status[4]^status[6])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
 hugeANDdivbytwo: assert ((!status[4] && !status[7]) || (status[4]^status[7])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
unusedANDinexact: assert ((!status[5] && !status[6]) || (status[5]^status[6])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");
inexactANDdivbytwo: assert ((!status[5] && !status[7]) || (status[5]^status[7])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");			
unusedANDdivbytwo: assert ((!status[6] && !status[7]) || (status[6]^status[7])) $display("\n",$stime,,,"%m passed\n");
		else
			$error("\n",$stime,,,"%m assert failled \n");	
		end
end	

endmodule

module test_status_z_combinations(input clk,rst,
					  input [7:0] status,
					  input [31:0] z, a, b);

property p1;
@(posedge clk) status[0] |-> (z[30:23] == '0);
endproperty

property p2;
@(posedge clk) status[1] |-> (z[30:23] == '1);
endproperty

property p3;
@(posedge clk) ((a[30:23] == '0 && b[30:23] == '1) || (a[30:23] == '1 && b[30:23] == '0)) |-> ##2 (status[2] == '1);
endproperty

property p4;
@(posedge clk) status[4] |-> (z[30:23] == '1 || z[30:23] == 8'b11111110);
endproperty

property p5;
@(posedge clk) status[3] |-> (z[30:23] == '0 || z[30:23] == 8'b00000001);	
endproperty

zero: assert property (p1) $display($stime,,," p1 PASS");
		else $display ($stime,,,"FAIL");
 inf: assert property (p2) $display($stime,,,"p2 PASS");
		else $display ($stime,,,"FAIL");
 nan: assert property (p3) $display($stime,,,"p3 PASS");
		else $display ($stime,,,"FAIL");
huge: assert property (p4) $display($stime,,,"p4 PASS");
		else $display ($stime,,,"FAIL");
tiny: assert property (p5) $display($stime,,,"p5 PASS");
		else $display ($stime,,,"FAIL"); 
endmodule 