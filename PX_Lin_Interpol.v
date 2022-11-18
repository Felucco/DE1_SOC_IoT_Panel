/*
    Module Instantiation

PX_Lin_Interpol #(
    .N_COLS(N_COLS),
    .SCREEN_W(SCREEN_W),
    .SCREEN_H(SCREEN_H)
) NAME (
    .col_hs(COL_HEIGHT_LIST),
    .px(PX),.py(PY),.en(EN),
    .pxy_line(OUT_LINE)
);

*/


module PX_Lin_Interpol #(
    parameter N_COLS=20,
    parameter SCREEN_W=640,
    parameter SCREEN_H=480
) (
    input [8*N_COLS-1:0] col_hs,
    input [$clog2(SCREEN_W)-1:0] px,
    input [$clog2(SCREEN_H)-1:0] py,
    input en,
    output reg pxy_line
);

    parameter DW = SCREEN_W/N_COLS;
    parameter X_MAX = DW*(N_COLS-1);

    wire [7:0] col_hs_mx [N_COLS-1:0];

    genvar idx;
    generate
        for (idx=0;idx<N_COLS;idx=idx+1) begin: col_assign
            assign col_hs_mx[idx]=col_hs[8*(idx+1)-1:8*idx];
        end
    endgenerate

    reg [$clog2(N_COLS)-1:0] col_idx;
    reg [7:0] px_liny;
    reg oob;
    reg [$clog2(DW)+8-1:0]tmp_mul; //In order to avoid overflow
    always @(*) begin: y_interpolation
        col_idx=px/DW;
        oob=0;
        tmp_mul=0;
        if (px > X_MAX) begin
            px_liny=0;
            oob=1;
        end else if (px % DW == 0) begin
            px_liny=col_hs_mx[col_idx];
        end else begin
            if (col_hs_mx[col_idx+1] >= col_hs_mx[col_idx]) begin
                tmp_mul=(col_hs_mx[col_idx+1]-col_hs_mx[col_idx])*(px%DW);
                px_liny=tmp_mul/DW+col_hs_mx[col_idx];
            end else begin
                tmp_mul=(col_hs_mx[col_idx]-col_hs_mx[col_idx+1])*(px%DW);
                px_liny=col_hs_mx[col_idx]-tmp_mul/DW;
            end
        end
    end

    always @(*) begin: px_evaluation
        if (oob | ~en) pxy_line=1'b0;
        else if (py/2==px_liny) pxy_line=1'b1;
        else pxy_line=1'b0;
    end
    
endmodule