`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Self-checking testbench for the parking-lot counter FSM (parklot).
//
// Sensors: pout = outside sensor, pin = inside sensor.
//   outside then inside  -> a car ENTERS  (count + 1)
//   inside then outside  -> a car EXITS   (count - 1)
//   both in the same clock -> invalid (error)
// The count stops at 25 (FULL). Entering when full, or exiting when empty, is an
// error. ERROR blinks while the error flag is set and clears on the next good
// entry or exit.
//
// Each sensor event is one clock cycle, which is what the debouncers deliver.
// Prints PASS or FAIL at the end.
//////////////////////////////////////////////////////////////////////////////////

module tb_parklot_check;

    reg        pout;
    reg        pin;
    reg        CLK;
    reg        RST;
    wire [4:0] CarCount;
    wire       FULL;
    wire       ERROR;

    integer errors;
    integer i;

    parklot dut (
        .pout     (pout),
        .pin      (pin),
        .CLK      (CLK),
        .RST      (RST),
        .CarCount (CarCount),
        .FULL     (FULL),
        .ERROR    (ERROR)
    );

    initial CLK = 1'b0;
    always #5 CLK = ~CLK;

    task idle;
        input integer n;
        begin
            repeat (n) @(negedge CLK);
        end
    endtask

    task pulse_pout;
        begin
            @(negedge CLK); pout = 1'b1;
            @(negedge CLK); pout = 1'b0;
        end
    endtask

    task pulse_pin;
        begin
            @(negedge CLK); pin = 1'b1;
            @(negedge CLK); pin = 1'b0;
        end
    endtask

    task car_in;                 // outside sensor, then inside sensor
        begin
            pulse_pout; idle(2);
            pulse_pin;  idle(3);
        end
    endtask

    task car_out;                // inside sensor, then outside sensor
        begin
            pulse_pin;  idle(2);
            pulse_pout; idle(3);
        end
    endtask

    task do_reset;
        begin
            @(negedge CLK);
            RST = 1'b1;
            #12;
            RST = 1'b0;
            idle(2);
        end
    endtask

    task check_count;
        input [4:0]      expected;
        input [8*40-1:0] label;
        begin
            if (CarCount !== expected || FULL !== (expected == 5'd25)) begin
                $display("FAIL  %0s: CarCount=%0d FULL=%b (expected %0d, FULL=%b)",
                         label, CarCount, FULL, expected, (expected == 5'd25));
                errors = errors + 1;
            end
            else
                $display("ok    %0s: CarCount=%0d FULL=%b", label, CarCount, FULL);
        end
    endtask

    // ERROR blinks while the error flag is set: watch two full blink periods.
    task expect_error;
        input [8*40-1:0] label;
        integer n;
        reg saw_hi, saw_lo;
        begin
            saw_hi = 1'b0; saw_lo = 1'b0;
            for (n = 0; n < 70; n = n + 1) begin
                @(negedge CLK);
                if (ERROR === 1'b1) saw_hi = 1'b1;
                if (ERROR === 1'b0) saw_lo = 1'b1;
            end
            if (saw_hi && saw_lo) $display("ok    %0s: ERROR blinks", label);
            else begin
                $display("FAIL  %0s: ERROR did not blink (high=%b low=%b)", label, saw_hi, saw_lo);
                errors = errors + 1;
            end
        end
    endtask

    task expect_no_error;
        input [8*40-1:0] label;
        integer n;
        reg saw_hi;
        begin
            saw_hi = 1'b0;
            for (n = 0; n < 70; n = n + 1) begin
                @(negedge CLK);
                if (ERROR !== 1'b0) saw_hi = 1'b1;
            end
            if (!saw_hi) $display("ok    %0s: no ERROR", label);
            else begin
                $display("FAIL  %0s: ERROR was not clear", label);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        pout = 1'b0; pin = 1'b0; RST = 1'b0;

        #12 RST = 1'b1;
        #30 RST = 1'b0;
        idle(2);
        check_count(5'd0, "after reset");
        expect_no_error("after reset");

        // ---- normal entries and exits ----
        car_in;  check_count(5'd1, "car enters");
        car_in;  check_count(5'd2, "second car enters");
        car_out; check_count(5'd1, "car exits");
        car_out; check_count(5'd0, "second car exits");
        expect_no_error("normal traffic");

        // ---- exit from an empty lot ----
        car_out; check_count(5'd0, "exit when empty: count stays 0");
        expect_error("exit when empty");
        car_in;  check_count(5'd1, "next good entry");
        expect_no_error("error cleared by good entry");

        // ---- one sensor alone changes nothing ----
        pulse_pout; idle(10);
        check_count(5'd1, "outside sensor alone");
        pulse_pin;  idle(3);
        check_count(5'd2, "inside sensor completes the entry");

        // ---- both sensors at once ----
        @(negedge CLK); pout = 1'b1; pin = 1'b1;
        @(negedge CLK); pout = 1'b0; pin = 1'b0;
        idle(3);
        check_count(5'd2, "both sensors: count unchanged");
        expect_error("both sensors at once");
        car_in;  check_count(5'd3, "entry after invalid");
        expect_no_error("invalid cleared by good entry");

        // ---- fill the lot ----
        for (i = 3; i < 25; i = i + 1) car_in;
        check_count(5'd25, "lot full");
        expect_no_error("filling to exactly 25 is not an error");
        car_in;  check_count(5'd25, "entry when full: count stays 25");
        expect_error("entry when full");
        car_out; check_count(5'd24, "exit from full lot");
        expect_no_error("error cleared by exit");

        // ---- reset in the middle ----
        do_reset;
        check_count(5'd0, "reset clears count");
        expect_no_error("reset clears error");

        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAIL: %0d check(s) failed", errors);
        $finish;
    end

endmodule
