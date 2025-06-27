`timescale 1ms/10ps
module fsm_tb;
    logic clk, rst;
    logic [4:0] keyout;
    logic [31:0] seq;
    logic [3:0] state;
    
    //Call the function. This is the actual result. we compare this with our expected result
    fsm fsm_DUT(.clk(clk), .rst(rst), .keyout(keyout), .seq(seq), .state(state));


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

    state_t expected_state;
    assign seq = 32'h12345678; //lock


    //clock always run
    always begin
        #3 clk = ~clk;
    end

    //togle
    task toggle();
        rst = 1; #4;
        rst = 0; #4;
    endtask

    task compare(int expected, int actual);
    begin
        if(expected == actual) begin
            $display("GOOD: expected and actual both are %d", expected);
        end
        else begin
            $display("BAD: \n expected: %d, actual: %d", expected, actual);
        end
    end
    endtask

    initial begin

        
        $dumpfile("waves/fsm.vcd");
        $dumpvars(0, fsm_tb);

        clk = 0;
        keyout = 0;
        expected_state =INIT;

        //power on reset

        $display("Power on reset case");
        toggle();
        keyout = 0;
        expected_state = INIT;
        compare(expected_state, state);

        //normal operation
        $display("\n\nNormal operation cases: Lock password\n");
        toggle();
        keyout = 5'd16;
        expected_state = LS0;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);

        $display("Putting in password");
        keyout = 5'd1;
        expected_state = LS1;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);

        keyout = 5'd2;
        expected_state = LS2;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);
        
        keyout = 5'd3;
        expected_state = LS3;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);

        keyout = 5'd4;
        expected_state = LS4;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);

        keyout = 5'd5;
        expected_state = LS5;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);

        keyout = 5'd6;
        expected_state = LS6;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);
        
        keyout = 5'd7;
        expected_state = LS7;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);

        //mid-operation reset
        $display("mid-operation reset");
        toggle();
        keyout = 5'd16;
        expected_state = LS0;
        @(posedge clk);
        @(posedge clk);

        keyout = 5'd1;
        expected_state = LS1;
        @(posedge clk);
        @(posedge clk);

        toggle();
        expected_state = INIT;
        @(posedge clk);
        @(posedge clk);
        compare(expected_state, state);



        #1
        $finish;



        


         
        
        

    end
endmodule
