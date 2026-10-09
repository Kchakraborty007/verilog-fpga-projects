`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 16:28:30
// Design Name: 
// Module Name: test_adder_8
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


module test_adder_8;

    reg  [7:0] A;
    reg  [7:0] B;
    reg        Cin;
    
    wire [7:0] Sum;
    wire       Cout;
    
    adder_8 a1(A, B, Cin, Sum, Cout);
    
    initial begin
        A   = 8'd150;
        B   = 8'd110;
        Cin = 1'b0;
        
        #10;
        
        
        
        $finish;
    end

endmodule

