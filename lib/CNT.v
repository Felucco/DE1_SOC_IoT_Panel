module CNT #(
    parameter N_BIT=4
) (
    input clk, rst, en, d_nu,
    output reg [N_BIT-1:0] cnt
);

    always @(posedge clk or posedge rst) begin
        
        if (rst) cnt <= 0;

        else begin
            if (en) begin
                if (d_nu) cnt <= cnt-1;
                else cnt <= cnt+1;
            end
        end
    end
    
endmodule