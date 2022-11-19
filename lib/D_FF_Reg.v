module D_FF_Reg #(parameter N_BIT=1)(
	input clk,rst,en,
    input [N_BIT-1:0] d,
	output reg [N_BIT-1:0] q);
	
	always @(posedge clk or posedge rst) begin
		if (rst) q <= 0;
		else if (en) q <= d;
	end
endmodule