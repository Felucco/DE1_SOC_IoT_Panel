module Sync_Gen #(parameter SYNC = 192, parameter BACK_P = 96,
                parameter DISP = 1280, parameter FRONT_P = 32,
                parameter DISP_OUT = 1) (
    input clk, rst, en,
    output eol,sync,
    output reg d,
    output [$clog2(SYNC+BACK_P+DISP+FRONT_P)-1:0] coord
);
    parameter N_CNT=SYNC+BACK_P+DISP+FRONT_P;
    parameter N_BIT=$clog2(N_CNT);

    wire [N_BIT-1:0] cnt_out, cnt_pin;
    wire p_e;

    assign cnt_pin=0;
    
    UDL_CNT #(.N_BIT(N_BIT)) Core_CNT (.clk(clk),.rst(rst),.en(en),
                                        .d_nu(1'b0),.pl(p_e),.pin(cnt_pin),
                                        .cnt(cnt_out));
    
    assign p_e=cnt_out==N_CNT-1;
    assign eol=p_e&en;
    assign sync=cnt_out>SYNC-1;

    always @(cnt_out) begin
        if (DISP_OUT) begin
            if ((cnt_out>(SYNC+BACK_P-1))&(cnt_out<(N_CNT-FRONT_P))) d=1;
            else d=0;
        end else d=1;
    end

    assign coord=d ? cnt_out-SYNC-BACK_P : 0;

    
endmodule
