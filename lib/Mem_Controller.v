/*
INSTANCE TEMPLATE
Mem_Controller #(.M_WIDTH(<W>),.M_DEPTH(<D>)) u0 
	(
		.clk(<CLK>), .rst(<RST>),
		.cmd(<CMD_3b>),
		.addr(<CMD_ADDR>),
		.din1(<FIRST_IN>),
		.din2(<SEC_IN>),
		.mem_out(<MEM_RDLINE>),
		.dout1(<FIRST_OUT>),
		.dout2(<SEC_OUT>),
		.mem_in(<MEM_WRLINE>),
		.mem_w_nr(<MEM_WREN>),
		.mem_addr(<MEM_ADDR>),
		.op_cplt_flag(<OP_CPLT_FLAG>)
	);
*/


module Mem_Controller #(
	parameter M_WIDTH=8,
	parameter M_DEPTH=8192) (
	
	input clk, rst, 
	input [2:0] cmd,
	input [$clog2(M_DEPTH)-1:0] addr,
	input [M_WIDTH-1:0] din1,din2, mem_out,

	output reg [M_WIDTH-1:0] dout1, dout2, mem_in,
	output reg mem_w_nr,
	output reg [$clog2(M_DEPTH)-1:0] mem_addr,
	output op_cplt_flag);

	reg [3:0] state;

	localparam  idle=4'b0000,
				r1_1=4'b0001,
				r1_2=4'b0010,
				r1_3=4'b0011,
				r2_1=4'b0100,
				r2_2=4'b0101,
				r2_3=4'b0110,
				r2_4=4'b0111,
				w1_1=4'b1000,
				w1_2=4'b1001,
				w2_1=4'b1100,
				w2_2=4'b1101,
				w2_3=4'b1110,
				op_cplt=4'b1111;
	
	always @(posedge clk or posedge rst) begin : next_state_control
		if (rst) state <= idle;
		else begin
			case (state)
				idle: begin
					case (cmd)
						3'b100: state <= r1_1;
						3'b101: state <= r2_1;
						3'b110: state <= w1_1;
						3'b111: state <= w2_1; 
						default: state <= idle;
					endcase
				end
				r1_1: state <= r1_2;
				r1_2: state <= r1_3;
				r1_3: state <= op_cplt;

				r2_1: state <= r2_2;
				r2_2: state <= r2_3;
				r2_3: state <= r2_4;
				r2_4: state <= op_cplt;

				w1_1: state <= w1_2;
				w1_2: state <= op_cplt;

				w2_1: state <= w2_2;
				w2_2: state <= w2_3;
				w2_3: state <= op_cplt;

				op_cplt: state <= cmd[2] ? op_cplt : idle;
				default: state <= idle; 
			endcase
		end
	end

	assign op_cplt_flag = state==op_cplt ? 1'b1 : 1'b0;

	always @(posedge clk or posedge rst) begin : mem_control
		if (rst) begin
			mem_addr <= 0;
			mem_w_nr <= 0;
			mem_in <= 0;
			dout1 <= 0;
			dout2 <= 0;	
		end else begin
			case (state)
				// Read 1 value
				r1_1: begin
					mem_addr <= addr;
					mem_w_nr <= 1'b0;
				end 
				r1_3: dout1 <= mem_out;

				// Read 2 values
				r2_1: begin
					mem_addr <= addr;
					mem_w_nr <= 1'b0;
				end
				r2_2: mem_addr <= addr+1;
				r2_3: dout1 <= mem_out;
				r2_4: dout2 <= mem_out;

				// Write 1 value
				w1_1: begin
					mem_addr <= addr;
					mem_w_nr <= 1'b1;
					mem_in <= din1;
				end
				w1_2: mem_w_nr <= 1'b0;

				// Write 2 values
				w2_1: begin
					mem_addr <= addr;
					mem_w_nr <= 1'b1;
					mem_in <= din1;
				end
				w2_2: begin
					mem_addr <= addr+1;
					mem_in <= din2;
				end
				w2_3: mem_w_nr <= 1'b0;

			endcase
		end
	end

endmodule