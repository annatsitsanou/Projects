//This module is given for the exercises
module fp_mult_top #(parameter round = "away_zero")(
     d_clk, d_rst, d_a, d_b, d_z, d_status
);

    input logic [31:0] d_a, d_b;  // Floating-Point numbers
    output logic [31:0] d_z;    // a ± b
    output logic [7:0] d_status;  // Status Flags 
    input logic d_clk, d_rst; 
    
    logic [31:0] a1, b1;  // Floating-Point numbers
    logic [31:0] z1;    // a ± b
    logic [7:0] status1;  // Status Flags 
    
    fp_mult #(round) multiplier(z1,status1,a1,b1); 
	 
	test_status_bits assert1bound(d_clk,d_rst,d_status,d_z,d_a,d_b);
	test_status_z_combinations assert2bound(d_clk,d_rst,d_status,d_z,d_a,d_b);

    
    always @(posedge d_clk)
       if (d_rst == 1)
          begin 
             a1 <= '0;
             b1 <= '0;
             d_z <= '0;
             d_status <= '0;
          end
       else
          begin
             a1 <= d_a;
             b1 <= d_b;
             d_z <= z1;
             d_status <= status1;
          end

endmodule