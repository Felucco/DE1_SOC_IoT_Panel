//Only the 95 ASCII printable characters
module Font_BMP #(
    parameter FONT_W=10,
    parameter FONT_H=12
) (
    input en,
    input off_limits,
    input [6:0] cc,
    input [$clog2(FONT_W*FONT_H)-1:0] fi,
    input [FONT_W*FONT_H-1:0]font_mem_dout,
	 output reg [$clog2(95)-1:0]font_mem_addr,
    output reg pxi
);

reg [6:0] cpc;
reg cc_np;

always @(*) begin
    if (cc >= 32 & cc < 127) begin
        cpc=cc-7'd32;
        cc_np=1'b0;
    end else begin
        cpc=7'd0;
        cc_np=1'b1;
    end
end

always @(*) begin
	font_mem_addr = 0;
    if (off_limits | fi>=FONT_W*FONT_H | cc_np) pxi=1'b0;
    else begin
        if (en) begin
			font_mem_addr=cpc;
			pxi=font_mem_dout[fi];
        end else pxi=1'b0;
    end
end
    
endmodule