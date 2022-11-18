module Buff_Controller (
	input clk, rst, en, trg,
	input [7:0] data_in,
	output [12:0] mem_addr,
	output [100*8-1:0] out
);

	localparam START_LOC = 13'h800;
	
	reg [6:0] tmp_addr;
	wire [6:0] cnt_out, en_line;
	reg [7:0] core_buf [99:0];

	genvar idx;
	generate
		for (idx = 0; idx<100; idx=idx+1) begin
			assign out[8*(idx+1)-1:8*idx]= core_buf[idx];
		end
	endgenerate
	
	always @(posedge clk or posedge rst) begin: buff_wr_ctrl
		if (rst) begin
			for (tmp_addr=0;tmp_addr<100;tmp_addr+=1) begin
				core_buf[tmp_addr] <= 8'd0;
			end
		end else begin
			if (en) begin
				for (tmp_addr=0;tmp_addr<100;tmp_addr+=1) begin
					if (tmp_addr == en_line) core_buf[tmp_addr]<=data_in;
				end
			end
		end
	end
	
	wire cnt_en;
	wire refr; //Refreshing
	
	assign cnt_en = trg | refr;
	
	UDL_CNT #(.N_BIT(7)) buf_line_CNT (
		.clk(clk),.rst(rst),.en(cnt_en),
		.d_nu(1'b0),.pl(cnt_out==7'd100),
		.pin(7'd0),.cnt(cnt_out));
		
	assign refr = cnt_out > 7'd0;

	assign en_line = refr ? cnt_out-1 : 100;
	
	assign mem_addr = en ? START_LOC+cnt_out : 13'hz;
	
endmodule