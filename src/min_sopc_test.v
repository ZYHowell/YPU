`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2019 07:05:39 PM
// Design Name: 
// Module Name: min_sopc_test
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


module min_sopc_test();
    reg CLOCK_50, rst;

//50MHz
initial begin 
    CLOCK_50 = 1'b0; 
    forever #10 CLOCK_50 = ~CLOCK_50; 
end

initial begin
    rst = `ResetEnable;
    #30 rst = `ResetDisable;
    #200 $stop;
end

min_sopc cpu(.clk(CLOCK_50), .rst(rst));

endmodule
