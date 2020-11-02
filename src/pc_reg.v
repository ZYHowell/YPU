`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Gabriel
// 
// Create Date: 10/24/2019 11:39:52 PM
// Design Name: 
// Module Name: pc_reg
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


module pc_reg(
    input wire clk,
    input wire rst,
    output reg [`AddrLen - 1 : 0] pc,
    output reg chip_enable);

always @ (posedge clk) begin
    if (rst == `ResetEnable)
        chip_enable <= `ChipDisable;
    else
        chip_enable <= `ChipEnable;
end

always @ (posedge clk) begin
    if (chip_enable == `ChipDisable) begin
        pc <= `ZERO_WORD;
    end
    else begin
        pc <= pc + 4'h4;
    end
end

endmodule
