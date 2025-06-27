`timescale 1ms/10ps
module synckey_tb;
    logic [19:0] in;
    logic clk;
    logic rst;
    logic strobe, expected_strobe;
    logic [4:0] out, expected;

    synckey synckey_DUT(.in(in), .clk(clk), .rst(rst), .strobe(strobe), .out(out));
    
     always begin
        #3 clk = ~clk;
    end

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
        $dumpfile("waves/synckey.vcd");
        $dumpvars(0, synckey_tb);
        //declare variables;
        clk = '0;
        in = '0;

        //power-on reset
        $display("power on reset\n");
        toggle();
        expected = 0;
        @(posedge clk);
        @(posedge clk);
        compare(expected, out);

        //normal operation
        $display("Normal operation \n");
        toggle();
        expected_strobe = 1;
        for(integer i = 0; i < 16; i++) begin
            expected = i;
            @(posedge clk);
            @(posedge clk);
            compare(expected, out);
            in = 1 << i+1;
            //expected_strobe = 1;
            compare(expected_strobe, strobe);
        end

        //mid operation reset
        $display("mid operation reset\n");
        toggle();
        
        expected_strobe = 1;
        for(integer i = 0; i < 3; i++) begin
            expected = i;
            @(posedge clk);
            @(posedge clk);
            compare(expected, out);
            in = 1 << i+1;
            //expected_strobe = 1;
            compare(expected_strobe, strobe);
            
        end
        toggle();
        expected = 1;
        compare(expected, out);


        $finish;




        
    end

    



endmodule
