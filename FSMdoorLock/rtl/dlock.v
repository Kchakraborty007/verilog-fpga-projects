`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 22:49:10
// Design Name: 
// Module Name: dlock
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


module dlock(
    input CLK,
    input RST,
    input [1:0] Bout,
    input EN,
    output reg UNLOCK,
    output reg ERROR
);

reg [3:0] present_state, next_state;

parameter S1 = 4'd0,
          S2 = 4'd1,
          S3 = 4'd2,
          S4 = 4'd3,
          S5 = 4'd4,
          E1 = 4'd5,
          E2 = 4'd6,
          E3 = 4'd7,
          E4 = 4'd8;

always @(*) begin
    next_state = S1;
    case (present_state)
       S1: begin
    if (Bout == 2'b01)
        next_state = S2;
    else
        next_state = E1;
end

S2: begin
    if (Bout == 2'b00)
        next_state = S3;
    else
        next_state = E2;
end

S3: begin
    if (Bout == 2'b00)
        next_state = S4;
    else
        next_state = E3;
end

S4: begin
    if (Bout == 2'b10)
        next_state = S5;
    else
        next_state = E4;
end
        S5: next_state = S5;
        E1: next_state = E2;
        E2: next_state = E3;
        E3: next_state = E4;
        E4: next_state = S1;
        default: next_state = S1;
    endcase
end

always @(posedge CLK, posedge RST) begin
    if (RST)
        present_state <= S1;
    else if (EN)
        present_state <= next_state;
end

always @(*) begin
    if (present_state == S5) begin
        UNLOCK = 1'b1;
        ERROR  = 1'b0;
    end
    else if (present_state == E4) begin
        UNLOCK = 1'b0;
        ERROR  = 1'b1;
    end
    else begin
        UNLOCK = 1'b0;
        ERROR  = 1'b0;
    end
end

endmodule
