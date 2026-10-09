`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.09.2026 00:41:26
// Design Name: 
// Module Name: main
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


module main(
    input CLK,
    input RST,
    input PoutB,
    input PinB,
    output[4:0] carcount,
    output Full,
    output Error
    );
    
    wire slclock,deb_pout,deb_pin;
    
    clockdivider c1(CLK,RST,slclock);
    
    debouncer d1(slclock,RST,PoutB, deb_pout);
    debouncer d2(slclock,RST,PinB, deb_pin);
    
    parklot p1(deb_pout, deb_pin, slclock, RST, carcount, Full, Error);
    
    
endmodule
