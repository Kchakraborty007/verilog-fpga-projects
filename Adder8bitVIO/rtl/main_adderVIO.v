`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 17:22:28
// Design Name: 
// Module Name: main_adderVIO
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


module main_adderVIO(
input CLK, output [7:0] Sum1
    );
    
    wire  [7:0] A;
    wire  [7:0] B;
    wire        Cin;
    wire [7:0] Sum;
    wire       Cout;
    
    adder_8 b1( A,B,Cin,Sum,Cout);
    
    vio_0 (
CLK,
Sum,Cout,
A,B,Cin
);

assign Sum1=Sum;
endmodule

