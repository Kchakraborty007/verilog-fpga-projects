`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 16:18:13
// Design Name: 
// Module Name: adder_8
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


module adder_8(
    input  [7:0] A,
    input  [7:0] B,
    input        Cin,
    output [7:0] Sum,
    output       Cout
);

    wire [7:0] w1;

    full_adder f0 (A[0], B[0], Cin,  Sum[0], w1[0]);
    full_adder f1 (A[1], B[1], w1[0], Sum[1], w1[1]);
    full_adder f2 (A[2], B[2], w1[1], Sum[2], w1[2]);
    full_adder f3 (A[3], B[3], w1[2], Sum[3], w1[3]);
    full_adder f4 (A[4], B[4], w1[3], Sum[4], w1[4]);
    full_adder f5 (A[5], B[5], w1[4], Sum[5], w1[5]);
    full_adder f6 (A[6], B[6], w1[5], Sum[6], w1[6]);
    full_adder f7 (A[7], B[7], w1[6], Sum[7], Cout);

endmodule

