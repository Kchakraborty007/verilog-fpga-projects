`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Self-checking testbench for the door-lock FSM (dlock).
//
// Password (Bout codes): 01, 00, 00, 10   ->  PB1, PB0, PB0, PB2 on the board.
//
// Each "press" is one clock cycle of EN with the button code on Bout, which is
// what the FSM sees from one debounced button press.
//
// Checks:
//   1. Reset state is locked, no error.
//   2. Correct code unlocks, and stays unlocked on further presses.
//   3. A wrong digit at any of the 4 positions gives ERROR after exactly 4 presses
//      (never earlier), UNLOCK stays 0, and one more press clears the error.
//   4. After an error, the correct code unlocks again.
//   5. EN = 0 holds the state (no press, no progress).
//   6. Reset clears both UNLOCK and ERROR.
//
// Prints PASS or FAIL at the end.
//////////////////////////////////////////////////////////////////////////////////

module tb_dlock_check;

    reg        CLK;
    reg        RST;
    reg        EN;
    reg  [1:0] Bout;
    wire       UNLOCK;
    wire       ERROR;

    integer errors;
    integer pos;
    reg [1:0] d1, d2, d3, d4;     // the password digits

    dlock dut (
        .CLK    (CLK),
        .RST    (RST),
        .Bout   (Bout),
        .EN     (EN),
        .UNLOCK (UNLOCK),
        .ERROR  (ERROR)
    );

    initial CLK = 1'b0;
    always #5 CLK = ~CLK;

    // One button press = EN high for exactly one rising clock edge.
    task press;
        input [1:0] code;
        begin
            @(negedge CLK);
            Bout = code;
            EN   = 1'b1;
            @(negedge CLK);
            EN   = 1'b0;
            #1;
        end
    endtask

    task do_reset;
        begin
            @(negedge CLK);
            RST = 1'b1;
            #12;
            RST = 1'b0;
            @(negedge CLK);
            #1;
        end
    endtask

    task check;
        input            exp_unlock;
        input            exp_error;
        input [8*32-1:0] label;
        begin
            if (UNLOCK !== exp_unlock || ERROR !== exp_error) begin
                $display("FAIL  %0s: UNLOCK=%b ERROR=%b (expected %b %b)",
                         label, UNLOCK, ERROR, exp_unlock, exp_error);
                errors = errors + 1;
            end
            else
                $display("ok    %0s", label);
        end
    endtask

    // Enter the 4-digit code, with digit number 'bad' (1..4) replaced by a wrong
    // digit. bad = 0 means the correct code.
    task enter_code;
        input integer bad;
        begin
            press((bad == 1) ? ~d1 : d1);
            press((bad == 2) ? ~d2 : d2);
            press((bad == 3) ? ~d3 : d3);
            press((bad == 4) ? ~d4 : d4);
        end
    endtask

    initial begin
        errors = 0;
        EN = 1'b0;
        Bout = 2'b00;
        RST = 1'b0;
        d1 = 2'b01; d2 = 2'b00; d3 = 2'b00; d4 = 2'b10;

        #12 RST = 1'b1;
        #30 RST = 1'b0;
        @(negedge CLK); #1;
        check(0, 0, "reset state");

        // ---- correct code ----
        press(d1); check(0, 0, "correct: after digit 1");
        press(d2); check(0, 0, "correct: after digit 2");
        press(d3); check(0, 0, "correct: after digit 3");
        press(d4); check(1, 0, "correct: UNLOCK after digit 4");
        press(2'b11); check(1, 0, "stays unlocked on extra press");

        do_reset;  check(0, 0, "reset clears UNLOCK");

        // ---- wrong digit at each position ----
        for (pos = 1; pos <= 4; pos = pos + 1) begin
            do_reset;
            enter_code(pos);
            $display("-- wrong digit at position %0d --", pos);
            check(0, 1, "ERROR after exactly 4 presses");
            press(2'b00); check(0, 0, "one more press clears ERROR");
        end

        // ---- error must not show early, whichever digit was wrong ----
        for (pos = 1; pos <= 3; pos = pos + 1) begin
            do_reset;
            press((pos == 1) ? ~d1 : d1);
            press((pos == 2) ? ~d2 : d2);
            press((pos == 3) ? ~d3 : d3);
            check(0, 0, "no ERROR before 4th press");
        end

        // ---- correct code works again after an error ----
        do_reset;
        enter_code(2);                    // wrong 2nd digit -> ERROR
        press(2'b11);                     // clears ERROR (back to start)
        enter_code(0);
        check(1, 0, "unlock after earlier error");

        // ---- EN = 0 holds state ----
        do_reset;
        Bout = d1;
        repeat (6) @(negedge CLK);        // button code present but no EN
        enter_code(0);
        check(1, 0, "EN=0 did not advance state");

        // ---- reset from the error state ----
        do_reset;
        enter_code(1);
        check(0, 1, "setup: ERROR shown");
        do_reset;  check(0, 0, "reset clears ERROR");

        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAIL: %0d check(s) failed", errors);
        $finish;
    end

endmodule
