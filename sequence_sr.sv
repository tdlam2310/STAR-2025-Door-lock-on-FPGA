`default_nettype none
module sequence_sr(
    input logic clk,
    input logic rst,
    input logic en,
    input logic [4:0] in,
    output logic [31:0] out
);
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            out<= '0;
        end else if (en) begin
            out<= {out[27:0], in};
        end
    end
endmodule
