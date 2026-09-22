`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 010.09.2026 16:210:46
// Design Name: 
// Module Name: test_door
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


module test_door(


    );

reg CLK;
reg RST;
reg [1:0] Bout;
reg EN;

wire UNLOCK;
wire ERROR;

dlock dut (
    .CLK(CLK),
    .RST(RST),
    .Bout(Bout),
    .EN(EN),
    .UNLOCK(UNLOCK),
    .ERROR(ERROR)
);

initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
end

initial begin

    RST = 1;
    EN = 0;
    Bout = 2'bzz;

    #20;
    RST = 0;
    #20;

    press_Bout(2'b01);
    press_Bout(2'b00);
    press_Bout(2'b10);
    press_Bout(2'b00);

    #50;

    RST = 1;
    #20;
    RST = 0;
    #20;

    press_Bout(2'b01);
    press_Bout(2'b00);
    press_Bout(2'b00);
    press_Bout(2'b10);

    #50;

    $finish;

end

task press_Bout;
input [1:0] value;
begin
    @(negedge CLK);
    Bout = value;
    EN = 1;
    @(negedge CLK);
    EN = 0;
    Bout = 2'bzz;
    #20;
end
endtask

endmodule