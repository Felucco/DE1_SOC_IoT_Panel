module Axes_Checker #(
	parameter OFFSET=7,
	parameter WIDTH=5,
	parameter W_LEN=600,
	parameter H_LEN=450,
	parameter SCREEN_W=640,
   parameter SCREEN_H=480) (
	input [$clog2(SCREEN_W)-1:0] px,
   input [$clog2(SCREEN_H)-1:0] py,
   input en,
   output pxy_line);
	
	localparam ARR_LEN=WIDTH*2;
	
	reg x_ax, y_ax;
	reg x_arr, y_arr;
	assign pxy_line=(x_ax|y_ax|x_arr|y_arr)&en;
	
	always @(*) begin: x_ax_check
		x_ax=1'b0;
		if (px >= OFFSET & px < OFFSET+W_LEN) begin
			if (py-OFFSET <= WIDTH/2 | OFFSET-py <= WIDTH/2) x_ax=1'b1;
		end
	end
	
	always @(*) begin: y_ax_check
		y_ax=1'b0;
		if (py >= OFFSET & py < OFFSET+H_LEN) begin
			if (px-OFFSET <= WIDTH/2 | OFFSET-px <= WIDTH/2) y_ax=1'b1;
		end
	end
	
	always @(*) begin: x_arr_check
		x_arr=1'b0;
		if (px >= OFFSET+W_LEN & px < OFFSET+W_LEN+ARR_LEN) begin
			if (py-OFFSET <= (ARR_LEN-(px-OFFSET-W_LEN))/2 |
				OFFSET-py <= (ARR_LEN-(px-OFFSET-W_LEN))/2) x_arr=1'b1;
		end
	end
	
	always @(*) begin: y_arr_check
		y_arr=1'b0;
		if (py >= OFFSET+H_LEN & py < OFFSET+H_LEN+ARR_LEN) begin
			if (px-OFFSET <= (ARR_LEN-(py-OFFSET-H_LEN))/2 |
				OFFSET-px <= (ARR_LEN-(py-OFFSET-H_LEN))/2) y_arr=1'b1;
		end
	end

endmodule