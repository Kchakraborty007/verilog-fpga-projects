`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 23:35:48
// Design Name: 
// Module Name: mainblock
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


module mainblock(
    input CLK,
    input RST,
    input PB0,
    input PB1,
    input PB2,
    input PB3,
    output UNLOCK,
    output ERROR
);

wire SLCLOCK;
wire p0, p1, p2, p3;
wire press;
reg [1:0] Bout;

clockdivider u_div (CLK, RST, SLCLOCK);

debouncer u_db0 (SLCLOCK, RST, PB0, p0);
debouncer u_db1 (SLCLOCK, RST, PB1, p1);
debouncer u_db2 (SLCLOCK, RST, PB2, p2);
debouncer u_db3 (SLCLOCK, RST, PB3, p3);

assign press = p0 | p1 | p2 | p3;

always @(*) begin
    if (p0)
        Bout = 2'b00;
    else if (p1)
        Bout = 2'b01;
    else if (p2)
        Bout = 2'b10;
    else
        Bout = 2'b11;
end

dlock u_lock (
    .CLK(CLK),
    .RST(RST),
    .Bout(Bout),
    .EN(press),
    .UNLOCK(UNLOCK),
    .ERROR(ERROR)
);

endmodule