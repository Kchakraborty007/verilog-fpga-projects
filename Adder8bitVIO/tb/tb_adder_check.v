`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Self-checking, exhaustive testbench for the 8-bit ripple-carry adder.
//
// Tries every combination of A (256) x B (256) x Cin (2) = 131,072 input
// combinations and compares {Cout, Sum} against A + B + Cin.
//
// Prints PASS or FAIL at the end.
//////////////////////////////////////////////////////////////////////////////////

module tb_adder_check;

    reg  [7:0] A;
    reg  [7:0] B;
    reg        Cin;
    wire [7:0] Sum;
    wire       Cout;

    integer a, b, c;
    integer errors;
    integer checks;
    reg [8:0] expected;

    adder_8 dut (
        .A    (A),
        .B    (B),
        .Cin  (Cin),
        .Sum  (Sum),
        .Cout (Cout)
    );

    initial begin
        errors = 0;
        checks = 0;

        // The example from the original testbench: 150 + 110 = 260 -> Sum = 4, Cout = 1
        A = 8'd150; B = 8'd110; Cin = 1'b0;
        #1;
        if ({Cout, Sum} !== 9'd260) begin
            $display("FAIL  150 + 110: got Cout=%b Sum=%0d", Cout, Sum);
            errors = errors + 1;
        end
        else
            $display("ok    150 + 110 = 260 (Cout=%b, Sum=%0d)", Cout, Sum);

        // Exhaustive sweep
        for (c = 0; c < 2; c = c + 1)
            for (a = 0; a < 256; a = a + 1)
                for (b = 0; b < 256; b = b + 1) begin
                    A = a; B = b; Cin = c;
                    expected = a + b + c;
                    #1;
                    checks = checks + 1;
                    if ({Cout, Sum} !== expected) begin
                        errors = errors + 1;
                        if (errors <= 5)
                            $display("FAIL  %0d + %0d + %0d: got Cout=%b Sum=%0d, expected %0d",
                                     a, b, c, Cout, Sum, expected);
                    end
                end

        $display("%0d input combinations checked", checks);
        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAIL: %0d check(s) failed", errors);
        $finish;
    end

endmodule
