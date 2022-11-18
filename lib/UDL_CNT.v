`ifndef UDL_CNT_INC
`define UDL_CNT_INC

module UDL_CNT #(
    parameter N_BIT=4
) (
    input clk, rst, en, d_nu, pl,
    input [N_BIT-1:0] pin,
    output reg [N_BIT-1:0] cnt
);

    always @(posedge clk or posedge rst) begin
        
        if (rst) cnt <= 0;

        else begin
            if (en) begin
               if (pl) cnt <= pin;
               else if (d_nu) cnt <= cnt-1;
               else cnt <= cnt+1;
            end
        end
    end
    
endmodule

`endif