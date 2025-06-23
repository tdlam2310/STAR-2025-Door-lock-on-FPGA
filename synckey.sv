`default_nettype none
module synckey(
    input logic [19:0] in,
    input clk, rst,
    output logic strobe,
    output logic [4:0] out
); 
    logic strobe_a;
    logic strobe_b;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            strobe_b <= 0;
            strobe <=0;
        end else begin
            strobe_b <= strobe_a;
            strobe <= strobe_b;
        end
    end 
    always_comb begin
        strobe_a = |in;
        out = 5'b0;
        for(integer i = 0; i <=19; i++) begin
            if(in[i]) begin
                out = i[4:0];
            end
        end
    end
endmodule
