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
  //logic [7:0] eight_bit_eg_out; 
  logic strobe_clock;
  logic [31:0] sqr_out;
  logic [3:0] state;
  
  synckey sync1(.in(pb[19:0]), .clk(hz100), .rst(reset), .strobe(strobe_clock), .out(encoder_out));
  sequence_sr sqr(.clk(strobe_clock), .rst(reset), .en(pb[16]), .in(encoder_out), .out(sqr_out));
  // synckey sync2(.in(pb[19:0]), .clk(hz100), .rst(reset), .strobe(green), .out(right[4:0]));
  //eight_bit_reg ebr(.clk(green), .rst(reset), .in(encoder_out), .out(eight_bit_eg_out));
  //ssdec seven_seg1(.in(eight_bit_eg_out[3:0]), .enable(1'b1), .out(ss0[6:0]));
  //ssdec seven_seg2(.in(eight_bit_eg_out[7:4]), .enable(1'b1), .out(ss1[6:0]));
  fsm state_machine(.clk(strobe_clock), .rst(reset), .keyout(encoder_out), .seq(sqr_out), .state(state));
  display dis(.state(), .seq(sqr_out), .ss({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0}), .red(red), .green(green), .blue(blue));

endmodule

// module eight_bit_reg(
//   input logic clk, rst,
//   input logic [4:0] in,
//   output logic [7:0] out
// );
//   always_ff @(posedge clk, posedge rst) begin
//     if (rst) begin
//       out <= 8'b0;
//     end
//     else begin
//       out <= {3'b0, in};
//     end
//   end
// endmodule

module synckey(
    input logic [19:0] in,
    input clk, rst,
    output logic strobe,
    output logic [4:0] out

);  logic strobe_a;
    logic strobe_b;
    always_ff @(posedge clk, posedge rst) begin
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
        end else if (!en) begin
            out<= {out[26:0], in};
        end
    end
endmodule

module fsm(
    input logic clk, rst,
    input logic [4:0] keyout,
    input logic [31:0] seq,
    output logic [3:0] state
);
    typedef enum logic [3:0] {
        LS0=0,
        LS1=1,
        LS2=2,
        LS3=3,
        LS4=4,
        LS5=5,
        LS6=6,
        LS7=7,
        OPEN=8,
        ALARM=9,
        INIT=10
    } state_t;
    logic [3:0] next_state;
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= INIT;
        end
        else begin
            state <= next_state;
        end
    end
    always_comb begin
        case (state)
            INIT: next_state = (keyout == 5'd16) ? LS0:INIT;
            LS0 : next_state = (seq[31:28] == keyout[3:0]) ? LS1:ALARM;
            LS1 : next_state = (seq[27:24] == keyout[3:0]) ? LS2:ALARM;
            LS2 : next_state = (seq[23:20] == keyout[3:0]) ? LS3:ALARM;
            LS3 : next_state = (seq[19:16] == keyout[3:0]) ? LS4:ALARM;
            LS4 : next_state = (seq[15:12] == keyout[3:0]) ? LS5:ALARM;
            LS5 : next_state = (seq[11:8] == keyout[3:0]) ? LS6:ALARM;
            LS6 : next_state = (seq[7:4] == keyout[3:0]) ? LS7:ALARM;
            LS7 : next_state = (seq[3:0] == keyout[3:0]) ? OPEN:ALARM;
            OPEN : next_state = (keyout == 5'd16) ? INIT: OPEN;
            ALARM: next_state = ALARM;
            default: next_state = INIT;


        endcase
    end

endmodule

module display(
    input logic [3:0] state,
    input logic [31:0] seq,
    output logic [63:0] ss,
    output logic red, green, blue
);
    typedef enum logic [3:0] {
        LS0=0,
        LS1=1,
        LS2=2,
        LS3=3,
        LS4=4,
        LS5=5,
        LS6=6,
        LS7=7,
        OPEN=8,
        ALARM=9,
        INIT=10
    } state_t;
    logic [7:0] ss0, ss1, ss2, ss3, ss4, ss5, ss6, ss7;
    
    assign ss = {ss7, ss7, ss5, ss4, ss3, ss2, ss1, ss0};
    ssdec a(.in(seq[31:28]), .enable(1), .out(ss7));
    ssdec b(.in(seq[27:24]), .enable(1), .out(ss6));
    ssdec c(.in(seq[23:20]), .enable(1), .out(ss5));
    ssdec d(.in(seq[19:16]), .enable(1), .out(ss4));
    ssdec e(.in(seq[15:12]), .enable(1), .out(ss3));
    ssdec f(.in(seq[11:8]), .enable(1), .out(ss2));
    ssdec g(.in(seq[7:4]), .enable(1), .out(ss1));
    ssdec h(.in(seq[3:0]), .enable(1), .out(ss0));
    

    always_comb begin
      ss0 = 8'b0; ss1 = 8'b0; ss2 = 8'b0; ss3 = 8'b0;
    ss4 = 8'b0; ss5 = 8'b0; ss6 = 8'b0; ss7 = 8'b0;
    red = 1'b0; green = 1'b0; blue = 1'b0;
        case(state)
            4'd10: begin
                ss7 = {4'b0, seq[3:0]};
                ss6 = {4'b0, seq[7:4]};
                ss5 = {4'b0, seq[11:8]};
                ss4 = {4'b0, seq[15:12]};
                ss3 = {4'b0, seq[19:16]};
                ss2 = {4'b0, seq[23:20]};
                ss1 = {4'b0, seq[27:24]};
                ss0 = {4'b0, seq[31:28]};
                red = '0;
                blue = '0;
                green = '0;
            end
            4'd0: ss7[7] = 1'b1;
            4'd1: ss6[7] = 1'b1;
            4'd2: ss5[7] = 1'b1;
            4'd3: ss4[7] = 1'b1;
            4'd4: ss3[7] = 1'b1;
            4'd5: ss2[7] = 1'b1;
            4'd6: ss1[7] = 1'b1;
            4'd7: ss0[7] = 1'b1;
 // 911
            4'd9: begin  // State 9 - Show "911"
                ss7 = 8'b10011100;
                ss6 = 8'b11101110;
                ss5 = 8'b00011100;
                ss4 = 8'b00011100;
                ss3 = 8'b00000000;
                ss2 = 8'b11100110; 
                ss1 = 8'b01100000;
                ss0 = 8'b01100000;
                blue = 1'b1;
                red = '0;
                green = '0;
            end
//OPEN
            4'd8: begin  
                ss0 = 8'b00101010;
                ss1 = 8'b10011110;
                ss2 = 8'b11001110;
                ss3 = 8'b11111100; 
                green = 1'b1;
                red = '0;
                blue = '0;
            end




        endcase

    end
endmodule

module ssdec(
    input logic [3:0] in,
    input logic enable,
    output logic [7:0] out
);
    always_comb begin
        if (enable == 0) begin
            out = 8'b00000000;
        end
        else begin
            case(in)
                4'b0000: out = 8'b01111110;  // 0
                4'b0001: out = 8'b00001100;  // 1
                4'b0010: out = 8'b10110110;  // 2
                4'b0011: out = 8'b10011110;  // 3
                4'b0100: out = 8'b11001100;  // 4
                4'b0101: out = 8'b11011010;  // 5
                4'b0110: out = 8'b11111010;  // 6
                4'b0111: out = 8'b00001110;  // 7
                4'b1000: out = 8'b11111110;  // 8
                4'b1001: out = 8'b11011110;  // 9
                4'b1010: out = 8'b11101110;  // A
                4'b1011: out = 8'b11111000;  // B
                4'b1100: out = 8'b01110010;  // C
                4'b1101: out = 8'b10111100;  // D
                4'b1110: out = 8'b11110010;  // E
                4'b1111: out = 8'b11100010;  // F
            endcase
        end
    end




endmodule




