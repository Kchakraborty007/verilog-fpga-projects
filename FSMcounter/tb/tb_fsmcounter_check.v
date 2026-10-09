`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Self-checking testbench for FSMcounter.
//
// The real design divides 100 MHz down to 1 Hz, so the FSM only moves once per
// simulated second (100,000,000 clock cycles). To keep the simulation short, this
// testbench "fast-forwards" the divider by loading its counter close to the
// terminal count (49_999_999) before each step. The RTL itself is not modified.
//
// Prints PASS or FAIL at the end.
//////////////////////////////////////////////////////////////////////////////////

module tb_fsmcounter_check;

    reg        CountUP;
    reg        CLK;
    reg        RST;
    wire [3:0] CountValue;

    integer errors;

    FSMcounter dut (
        .CountUP    (CountUP),
        .CLK        (CLK),
        .RST        (RST),
        .CountValue (CountValue)
    );

    // 100 MHz clock
    initial CLK = 1'b0;
    always #5 CLK = ~CLK;

    // Jump the divider to just before its terminal count.
    task fast_forward;
        begin
            @(posedge CLK);
            #1 dut.count = 27'd49_999_990;
        end
    endtask

    // Advance the FSM by exactly one step (= one rising edge of slow_clock).
    // slow_clock toggles twice per period, so we wait for two toggles.
    task step;
        begin
            fast_forward;
            @(dut.slow_clock);
            fast_forward;
            @(dut.slow_clock);
            @(posedge CLK);
            #1;
        end
    endtask

    task check;
        input [3:0] expected;
        input [8*24-1:0] label;
        begin
            if (CountValue !== expected) begin
                $display("FAIL  %0s: expected %b, got %b", label, expected, CountValue);
                errors = errors + 1;
            end
            else
                $display("ok    %0s: CountValue = %b", label, CountValue);
        end
    endtask

    initial begin
        errors  = 0;
        CountUP = 1'b1;
        RST     = 1'b0;

        // Reset
        #12 RST = 1'b1;
        #30 RST = 1'b0;
        #20;
        check(4'b0000, "after reset");

        // Count UP: 0 -> 2 -> 4 -> 6 -> 0 -> 2
        step; check(4'b0010, "up   step 1");
        step; check(4'b0100, "up   step 2");
        step; check(4'b0110, "up   step 3");
        step; check(4'b0000, "up   step 4 (wrap)");
        step; check(4'b0010, "up   step 5");

        // Count DOWN: 2 -> 0 -> 6 -> 4 -> 2
        CountUP = 1'b0;
        step; check(4'b0000, "down step 1");
        step; check(4'b0110, "down step 2 (wrap)");
        step; check(4'b0100, "down step 3");
        step; check(4'b0010, "down step 4");

        // Reset in the middle of a count returns to 0
        #10 RST = 1'b1;
        #20 RST = 1'b0;
        #20;
        check(4'b0000, "reset mid-count");

        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAIL: %0d check(s) failed", errors);
        $finish;
    end

endmodule
