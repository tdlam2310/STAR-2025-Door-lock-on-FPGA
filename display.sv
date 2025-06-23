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

    always_comb begin
        case(state)
            4'd10: begin
                ss7 = seq[3:0];
                ss6 = seq[7:4];
                ss5 = seq[11:8];
                ss4 = seq[15:12];
                ss3 = seq[19:16];
                ss2 = seq[23:20];
                ss1 = seq[27:24];
                ss0 = seq[31:28];
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
            end
//OPEN
            4'd8: begin  
                ss0 = 8'b00101010;
                ss1 = 8'b10011110;
                ss2 = 8'b11001110;
                ss3 = 8'b11111100; 
            end




        endcase

    end
endmodule
