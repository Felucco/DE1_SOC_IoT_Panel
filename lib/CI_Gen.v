module CI_Gen #(
    parameter FONT_W=10, parameter FONT_H=12,
    parameter SCREEN_W=640, parameter SCREEN_H=480
) (
    input [$clog2(SCREEN_W)-1:0] px,
    input [$clog2(SCREEN_H)-1:0] py,
    output [$clog2((SCREEN_W/FONT_W) * (SCREEN_H/FONT_H))-1:0] ci,
    output off_limits
);

parameter NCW       =   SCREEN_W/FONT_W;
parameter NCH       =   SCREEN_H/FONT_H;
parameter X_LIM     =   NCW * FONT_W;
parameter Y_LIM     =   NCH * FONT_H;

reg [$clog2(NCW)-1:0] cx;
reg [$clog2(NCH)-1:0] cy;

reg ol_x, ol_y;

assign off_limits = ol_x | ol_y;

always @(*) begin       : X_handler
    if (px<X_LIM) begin
        cx=px/FONT_W;
        ol_x=1'b0;
    end else begin
        cx=0;
        ol_x=1'b1;
    end
end

always @(*) begin       : Y_handler
    if (py<Y_LIM) begin
        cy=py/FONT_H;
        ol_y=1'b0;
    end else begin
        cy=0;
        ol_y=1'b1;
    end
end

assign ci = off_limits ? 0 : NCW*cy+cx;

endmodule