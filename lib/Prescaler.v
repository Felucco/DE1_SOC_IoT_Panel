`include "lib/UDL_CNT.v"

module Prescaler #(
    parameter PERIOD=10
) (
    input clk, rst, en,
    output wire p_e
);

    parameter N_BIT=$clog2(PERIOD+1);

    wire equal_period;
    wire [N_BIT-1:0] cnt_out;
    wire [N_BIT-1:0] pin_0;

    assign pin_0=0;

    UDL_CNT #(.N_BIT(N_BIT)) CNT (.clk(clk),.rst(rst),.en(en),.d_nu(1'b0),.pl(equal_period),.pin(pin_0),.cnt(cnt_out));

    assign equal_period = (cnt_out==PERIOD-1) ? en : 1'b0;

    assign p_e = equal_period;
    
endmodule