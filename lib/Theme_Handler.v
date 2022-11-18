module Theme_Handler (
    input pxi,
    input [2:0] theme,
    output reg [7:0] R,G,B
);

    localparam WoK  = 3'd0; //White char on blacK background
    localparam KoW  = 3'd1; //blacK char on White background
    localparam KoG  = 3'd2; //blacK char on Green background
    localparam KoGY = 3'd3; //blacK char on GraY background
    localparam GoK  = 3'd4; //Green char on blacK background
    localparam WoB  = 3'd5; //White char on Blue background
    localparam GYoK = 3'd6; //GraY char on blacK background
    localparam PoK  = 3'd7; //Pink char on blacK background

    always @(*) begin
        case (theme)
            WoK: begin
                if (pxi) begin
                    R=8'd255;
                    G=8'd255;
                    B=8'd255;
                end else begin
                    R=8'd0;
                    G=8'd0;
                    B=8'd0;
                end
            end
            KoW: begin
                if (pxi) begin
                    R=8'd0;
                    G=8'd0;
                    B=8'd0;
                end else begin
                    R=8'd255;
                    G=8'd255;
                    B=8'd255;
                end
            end
            KoG: begin
                if (pxi) begin
                    R=8'd0;
                    G=8'd0;
                    B=8'd0;
                end else begin
                    R=8'd42;
                    G=8'd87;
                    B=8'd42;
                end
            end
            KoGY: begin
                if (pxi) begin
                    R=8'd0;
                    G=8'd0;
                    B=8'd0;
                end else begin
                    R=8'd170;
                    G=8'd170;
                    B=8'd170;
                end
            end
            GoK: begin
                if (pxi) begin
                    R=8'd0;
                    G=8'd170;
                    B=8'd0;
                end else begin
                    R=8'd0;
                    G=8'd0;
                    B=8'd0;
                end
            end
            WoB: begin
                if (pxi) begin
                    R=8'd255;
                    G=8'd255;
                    B=8'd255;
                end else begin
                    R=8'd0;
                    G=8'd0;
                    B=8'd60;
                end
            end
            GYoK: begin
                if (pxi) begin
                    R=8'd170;
                    G=8'd170;
                    B=8'd170;
                end else begin
                    R=8'd0;
                    G=8'd0;
                    B=8'd0;
                end
            end
            PoK: begin
                if (pxi) begin
                    R=8'd244;
                    G=8'd112;
                    B=8'd246;
                end else begin
                    R=8'd0;
                    G=8'd0;
                    B=8'd0;
                end
            end
            default: begin
                R=8'd0;
                G=8'd0;
                B=8'd0;
            end
        endcase
    end

endmodule