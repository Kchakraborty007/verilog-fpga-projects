`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2026 19:45:04
// Design Name: 
// Module Name: FSMcounter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FSMcounter(
    input CountUP,
    input CLK,
    input RST,
    output reg [3:0] CountValue
);

    parameter S0 = 2'b00,
              S1 = 2'b01,
              S2 = 2'b10,
              S3 = 2'b11;

    reg [26:0] count;
    reg slow_clock;
    reg [1:0] next_state, present_state;

 
    always @(posedge CLK) begin
        if (RST) begin
            count <= 0;
            slow_clock <= 0;
        end
        else if (count == 49_999_999) begin
            count <= 0;
            slow_clock <= ~slow_clock;
        end
        else begin
            count <= count + 1;
        end
    end
    always @(*) begin
        case (present_state)

            S0: if (CountUP)
                    next_state = S1;
                else
                    next_state = S3;

            S1: if (CountUP)
                    next_state = S2;
                else
                    next_state = S0;

            S2: if (CountUP)
                    next_state = S3;
                else
                    next_state = S1;

            S3: if (CountUP)
                    next_state = S0;
                else
                    next_state = S2;

            default:
                next_state = S0;

        endcase
    end
    always @(posedge slow_clock or posedge RST) begin
        if (RST)
            present_state <= S0;
        else
            present_state <= next_state;
    end
    always @(*) begin
        case (present_state)
            S0: CountValue = 4'b0000;
            S1: CountValue = 4'b0010;
            S2: CountValue = 4'b0100;
            S3: CountValue = 4'b0110;

            default:
                CountValue = 4'b0000;
        endcase
    end

endmodule