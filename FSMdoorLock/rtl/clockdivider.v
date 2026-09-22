`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 21:55:38
// Design Name: 
// Module Name: clockdivider
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


module clockdivider(
    input CLK,
    input RST,
    output SLCLOCK
);

reg [18:0] count;

always @(posedge CLK, posedge RST) begin
    if (RST)
        count <= 19'd0;
    else
        count <= count + 1'b1;
end

assign SLCLOCK = count[18];

endmodule