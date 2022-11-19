module Graph_TH_Handler (
	input [4:0] px_code,
	output [7:0] graph_R, graph_G, graph_B);
	
	reg [10:0] tmp_R, tmp_G, tmp_B; //11 bits to avoid overflow
	
	localparam HUM_R=255;
	localparam HUM_G=0;
	localparam HUM_B=0;
	
	localparam TEMP_R=0;
	localparam TEMP_G=255;
	localparam TEMP_B=0;
	
	localparam MAGX_R=0;
	localparam MAGX_G=0;
	localparam MAGX_B=255;
	
	localparam MAGY_R=200;
	localparam MAGY_G=0;
	localparam MAGY_B=200;
	
	localparam MAGZ_R=150;
	localparam MAGZ_G=175;
	localparam MAGZ_B=0;
	
	always @(*) begin
		tmp_R=(px_code[0] ? HUM_R : 0)+(px_code[1] ? TEMP_R : 0)+
				(px_code[2] ? MAGX_R : 0)+(px_code[3] ? MAGY_R : 0)+
				(px_code[4] ? MAGZ_R : 0);
		tmp_G=(px_code[0] ? HUM_G : 0)+(px_code[1] ? TEMP_G : 0)+
				(px_code[2] ? MAGX_G : 0)+(px_code[3] ? MAGY_G : 0)+
				(px_code[4] ? MAGZ_G : 0);
		tmp_B=(px_code[0] ? HUM_B : 0)+(px_code[1] ? TEMP_B : 0)+
				(px_code[2] ? MAGX_B : 0)+(px_code[3] ? MAGY_B : 0)+
				(px_code[4] ? MAGZ_B : 0);
	end
	
	assign graph_R=tmp_R > 255 ? 255 : tmp_R;
	assign graph_G=tmp_G > 255 ? 255 : tmp_G;
	assign graph_B=tmp_B > 255 ? 255 : tmp_B;

endmodule
