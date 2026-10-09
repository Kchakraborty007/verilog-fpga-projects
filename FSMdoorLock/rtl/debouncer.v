`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 22:17:31
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input SLCLOCK,
    input RST,
    input din,
    output dout
);

reg A, B, C;

always @(posedge SLCLOCK, posedge RST) begin
    if (RST) begin
        A <= 1'b0;
        B <= 1'b0;
        C <= 1'b0;
    end
    else begin
        A <= din;
        B <= A;
        C <= B;
    end
end

assign dout = A & B & ~C;

endmodule