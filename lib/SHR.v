module SHR #(
    parameter N_BIT=4
) (
    input clk, rst, en, l_nr, pl, sin,
    input [N_BIT-1:0] pin,
    output wire sout,
    output wire [N_BIT-1:0] pout
);

    reg [N_BIT-1:0] int_bits;

    always @(posedge clk or posedge rst) begin
        if (rst) int_bits<=0;
        else begin
            if (en) begin
                if (pl) int_bits<=pin;
                else begin 
                    if (l_nr) int_bits<={int_bits[N_BIT-2:0],sin};
                    else int_bits<={sin,int_bits[N_BIT-1:1]};
                end
            end
        end
    end

    assign sout= l_nr ? int_bits[N_BIT-1] : int_bits[0];
    assign pout=int_bits;
    
endmodule