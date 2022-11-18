module Edge_Trigger (
    input clk, rst, in,
    output wire out
);
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= 0;
        else
            begin
                if (state==0) state <= in ? 1 : 0;
                else if (state==1) state <= in ? 2 : 0;
                else state <= in ? 2 : 0;
            end
    end

    assign out= (state==1) ? 1 : 0;
endmodule