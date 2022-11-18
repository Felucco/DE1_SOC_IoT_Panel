module FI_Gen #(
    parameter FONT_W=8, parameter FONT_H=10,
    parameter SCREEN_W=640, parameter SCREEN_H=480
) (
    input [$clog2(SCREEN_W)-1:0] px,
    input [$clog2(SCREEN_H)-1:0] py,
    output [$clog2(FONT_W*FONT_H)-1:0] fi
);

    wire [$clog2(FONT_W)-1:0] fx;
    wire [$clog2(FONT_H)-1:0] fy;

    assign fx = px%FONT_W;
    assign fy = py%FONT_H;
    assign fi = FONT_W*fy+fx;

endmodule