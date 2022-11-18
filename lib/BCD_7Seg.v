module BCD_7Seg(
	input [3:0] A,
	output [6:0] HEX0);

	reg [6:0] HEX0_N;
	
	always @(A) begin
		case (A)
			4'h0: HEX0_N=7'b0111111;
			4'h1: HEX0_N=7'b0000110;
			4'h2: HEX0_N=7'b1011011;
			4'h3: HEX0_N=7'b1001111;
			4'h4: HEX0_N=7'b1100110;
			4'h5: HEX0_N=7'b1101101;
			4'h6: HEX0_N=7'b1111101;
			4'h7: HEX0_N=7'b0000111;
			4'h8: HEX0_N=7'b1111111;
			4'h9: HEX0_N=7'b1101111;
			4'ha: HEX0_N=7'b1110111;
			4'hb: HEX0_N=7'b1111100;
			4'hc: HEX0_N=7'b0111001;
			4'hd: HEX0_N=7'b1011110;
			4'he: HEX0_N=7'b1111001;
			4'hf: HEX0_N=7'b1110001;
			default: HEX0_N=7'd0;
		endcase
	end

	assign HEX0 = ~HEX0_N;


endmodule
