/*
	Starting from the period following the trigger one, the Debug SHR will save DEPTH values of WIDTH bits
	
    Module Instantiation Template

    Debug_SHR #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) NAME (
        .clk(CLK), .rst(RST), .en(EN),
        .trg(TRG_LINE), .choice_in(CHOICE_LINE),
        .data_in(DIN_WIDTH_BIT), .addr_out(POS_OUT),
        .data_out(DOUT_WIDTH_BIT)
    );
*/

module Debug_SHR #(
		parameter WIDTH=8,
		parameter DEPTH=16
	)(
		input clk, rst, en,
		input trg, choice_in,
		input [WIDTH-1:0] data_in,
		output [$clog2(DEPTH)-1:0] addr_out,
		output [WIDTH-1:0] data_out);
		
	
	wire core_shr_en;
	wire [DEPTH-1:0] shr_pout [WIDTH-1:0];
	wire [WIDTH-1:0] shr_sout ;
	
	wire [WIDTH-1:0] resh_data [DEPTH-1:0];
	genvar time_idx, bit_idx;
	generate
		for (bit_idx=0;bit_idx<WIDTH;bit_idx=bit_idx+1) begin: bit_gen
			for (time_idx=0;time_idx<DEPTH;time_idx=time_idx+1) begin: time_gen
				assign resh_data[time_idx][bit_idx]=shr_pout[bit_idx][time_idx];
			end
		end
	endgenerate

	genvar in_bit;
	generate
		for (in_bit=0; in_bit<WIDTH; in_bit=in_bit+1) begin: core_shr_gen
			SHR #(.N_BIT(DEPTH)) core_shr (.clk(clk),.rst(rst),.en(core_shr_en),
											.l_nr(1'b0), .pl(1'b0), .sin(data_in[in_bit]),
											.pin(0),.sout(shr_sout[in_bit]),.pout(shr_pout[in_bit]));
		end
	endgenerate
	
	wire cnt_en;
	wire refr; //Refreshing
	wire [$clog2(DEPTH)-1:0] cnt_out;
	
	assign cnt_en = trg | refr;
	
	UDL_CNT #(.N_BIT($clog2(DEPTH))) update_CNT (
		.clk(clk),.rst(rst),.en(cnt_en),
		.d_nu(1'b0),.pl(cnt_out==DEPTH),
		.pin(0),.cnt(cnt_out));
		
	assign refr = cnt_out > 7'd0;
    assign core_shr_en=refr;
	
	wire out_addr_en;
	wire [$clog2(DEPTH)-1:0] out_addr;
	
	Edge_Trigger oa_ET (.clk(clk), .rst(rst), .in(choice_in), .out(out_addr_en));
	UDL_CNT #(.N_BIT($clog2(DEPTH))) oa_CNT (
		.clk(clk),.rst(rst),.en(out_addr_en),
		.d_nu(1'b0),.pl(out_addr==DEPTH-1),
		.pin(0),.cnt(out_addr));
	
	assign addr_out=out_addr;
	
	genvar gen_addr;
	generate
		for (gen_addr=0; gen_addr<DEPTH; gen_addr=gen_addr+1) begin: addr_choice_gen
			assign data_out = gen_addr==out_addr ? resh_data[gen_addr] : {WIDTH{1'bz}};
		end
	endgenerate
			
	
endmodule
	