`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2026 20:50:28
// Design Name: 
// Module Name: test_fsmcounter
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


module test_fsmcounter(
    );
    
    wire [3:0] CountValue;
    reg  CountUP,CLK,RST;
    
    FSMcounter f1(CountUP,CLK,RST,CountValue);
    
    initial 
        begin
            CLK=0; 
            forever 
            #5 CLK=~CLK;
        end
        
    initial begin
        RST = 1;
        CountUP = 1;
        #20 RST = 0;
        #1000 CountUP = 0;
        #1000 $finish;
    end
    
endmodule
