module top;

    reg [2:0] oc;
    reg [3:0] a;
    reg [3:0] b;
    wire [3:0] f;

    reg clk;
    reg rst_n;
    reg cl;
    reg ld;
    reg [3:0] in;
    reg inc;
    reg dec;
    reg sr;
    reg ir;
    reg sl;
    reg il;
    wire [3:0] out;

    alu dut_alu(oc, a, b, f);
    register dut_register(clk, rst_n, cl, ld, in, inc, dec, sr, ir, sl, il, out);

    integer i;

    initial begin
        rst_n = 1'b0;
        clk = 1'b0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        for(i = 0; i < 2**11; i = i + 1)begin
            {oc, a, b} = i;
            #5;
        end
        $stop;

        in = 4'd0;
        #7 rst_n = 1'b1;
        repeat(1000) begin
            cl = $urandom_range(1);
            ld = $urandom_range(1);
            in = $urandom_range(15);
            inc = $urandom_range(1);
            dec = $urandom_range(1);
            sr = $urandom_range(1);
            ir = $urandom_range(1);
            sl = $urandom_range(1);
            il = $urandom_range(1);
            #10;
        end

        $finish;
    end

    initial begin
        $monitor(
            "time = %4d, oc = %3b, a = %4b, b = %4b, f = %4b",
            $time, oc, a, b, f
        );
    end

    always @(cl, ld, in, inc, dec, sr, ir, sl, il) begin
        $strobe(
            "time = %4d, cl = %b, ld = %b, in = %4b, inc = %b, dec = %b, sr = %b, ir = %b, sl = %b, il = %b, out = %4b",
            $time, cl, ld, in, inc, dec, sr, ir, sl, il, out
        );
    end

endmodule