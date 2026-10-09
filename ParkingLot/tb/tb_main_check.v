`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// System-level testbench: clock divider + two debouncers + parking-lot FSM
// (module main), driven by "real" button presses.
//
// Each press is held for 20 ms and released for 20 ms, so this one simulates
// about 0.24 s of board time (24 million clock cycles). It takes noticeably
// longer than tb_parklot_check.
//
// Prints PASS or FAIL at the end.
//////////////////////////////////////////////////////////////////////////////////

module tb_main_check;

    reg        CLK;
    reg        RST;
    reg        PoutB;
    reg        PinB;
    wire [4:0] carcount;
    wire       Full;
    wire       Error;

    integer errors;

    main dut (
        .CLK      (CLK),
        .RST      (RST),
        .PoutB    (PoutB),
        .PinB     (PinB),
        .carcount (carcount),
        .Full     (Full),
        .Error    (Error)
    );

    initial CLK = 1'b0;
    always #5 CLK = ~CLK;                 // 100 MHz

    task press_out;
        begin
            PoutB = 1'b1; #20_000_000;    // 20 ms
            PoutB = 1'b0; #20_000_000;
        end
    endtask

    task press_in;
        begin
            PinB = 1'b1;  #20_000_000;
            PinB = 1'b0;  #20_000_000;
        end
    endtask

    task check_count;
        input [4:0]      expected;
        input [8*40-1:0] label;
        begin
            if (carcount !== expected) begin
                $display("FAIL  %0s: carcount=%0d (expected %0d)", label, carcount, expected);
                errors = errors + 1;
            end
            else
                $display("ok    %0s: carcount=%0d", label, carcount);
        end
    endtask

    initial begin
        errors = 0;
        RST = 1'b0; PoutB = 1'b0; PinB = 1'b0;

        #12 RST = 1'b1;
        #50 RST = 1'b0;
        #1_000_000;
        check_count(5'd0, "after reset");

        press_out; press_in;  check_count(5'd1, "car enters (outside, then inside)");
        press_out; press_in;  check_count(5'd2, "second car enters");
        press_in;  press_out; check_count(5'd1, "car exits (inside, then outside)");

        if (Error !== 1'b0 || Full !== 1'b0) begin
            $display("FAIL  Error/Full should be low (Error=%b Full=%b)", Error, Full);
            errors = errors + 1;
        end
        else
            $display("ok    Error and Full are low");

        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAIL: %0d check(s) failed", errors);
        $finish;
    end

endmodule
