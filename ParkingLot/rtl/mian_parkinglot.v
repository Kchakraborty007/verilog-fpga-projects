`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.09.2026 01:42:55
// Design Name: 
// Module Name: mian_parkinglot
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


module mian_parkinglot(
    input CLK_F,
    input RST_F,
    input POUT_BT,
    input PIN_BT,
    output FULL_F,
    output ERROR_F
    );
    wire [4:0] countofcars;
    
    main m1(CLK_F,RST_F,POUT_BT,PIN_BT,countofcars,FULL_F,ERROR_F);
    
    vio_0 v1(
CLK_F,
countofcars

);
endmodule
