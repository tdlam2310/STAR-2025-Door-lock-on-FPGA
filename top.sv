`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  //enc20to5 a(.in(pb[19:0]), .out(right[4:0]), .strobe(green));
  
  
  // Your code goes here...
  //logic [3:0] temp;
  //logic temp2;

  
  //ssdec a(.in(pb[3:0]), .enable(1'b1), .out(ss7[6:0]));
  //ssdec b(.in(pb[7:4]), .enable(1'b1), .out(ss5[6:0]));
  //bcdad1 sum(.A(pb[3:0]), .B(pb[7:4]), .Cin(pb[8]), .binary_sum(temp), .Cout(temp2));
  //ssdec cout(.in({3'b0, temp2}), .enable(1'b1), .out(ss1[6:0]));
  //ssdec sum1(.in(temp), .enable(1'b1), .out(ss0[6:0]));
  logic [4:0] encoder_out; 
  logic [7:0] eight_bit_eg_out; 
  logic strobe_clock;
  logic [31:0] sqr_out;

  
  synckey sync1(.in(pb[19:0]), .clk(hz100), .rst(reset), .strobe(strobe_clock), .out(encoder_out));
  sequence_sr sqr(.clk(strobe_clock), .rst(reset), .en(1'b1), .in(encoder_out), .out)
  // synckey sync2(.in(pb[19:0]), .clk(hz100), .rst(reset), .strobe(green), .out(right[4:0]));
  eight_bit_reg ebr(.clk(green), .rst(reset), .in(encoder_out), .out(eight_bit_eg_out));
  ssdec seven_seg1(.in(eight_bit_eg_out[3:0]), .enable(1'b1), .out(ss0[6:0]));
  ssdec seven_seg2(.in(eight_bit_eg_out[7:4]), .enable(1'b1), .out(ss1[6:0]));

endmodule

module eight_bit_reg(
  input logic clk, rst,
  input logic [4:0] in,
  output logic [7:0] out
);
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      out <= 8'b0;
    end
    else begin
      out <= {3'b0, in};
    end
  end
endmodule
