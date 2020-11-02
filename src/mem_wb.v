`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2019 12:03:13 AM
// Design Name: 
// Module Name: mem_wb
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


module mem_wb(
    input clk,
    input rst,
    input wire [`RegLen - 1 : 0] mem_rd_data,
    input wire [`RegAddrLen - 1 : 0] mem_rd_addr,
    input wire mem_rd_enable,

    output reg [`RegLen - 1 : 0] wb_rd_data,
    output reg [`RegAddrLen - 1 : 0] wb_rd_addr,
    output reg wb_rd_enable
    );

always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        wb_rd_data <= `ZERO_WORD;
        wb_rd_addr <= `RegAddrLen'h0;
        wb_rd_enable <= `WriteDisable;
    end
    else begin
        wb_rd_data <= mem_rd_data;
        wb_rd_addr <= mem_rd_addr;
        wb_rd_enable <= mem_rd_enable;
    end
end
endmodule
