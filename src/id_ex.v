`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2019 06:06:10 PM
// Design Name: 
// Module Name: id_ex
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Pass the variables from stage ID to EX
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module id_ex(
    input wire clk,
    input wire rst,
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_Imm,
    input wire [`RegLen - 1 : 0] id_rd,
    input wire id_rd_enable,
    input wire [`OpCodeLen - 1 : 0] id_aluop,
    input wire [`OpSelLen - 1 : 0] id_alusel,

    output reg [`RegLen - 1 : 0] ex_reg1,
    output reg [`RegLen - 1 : 0] ex_reg2,
    output reg [`RegLen - 1 : 0] ex_Imm,
    output reg [`RegLen - 1 : 0] ex_rd,
    output reg ex_rd_enable,
    output reg [`OpCodeLen - 1 : 0] ex_aluop,
    output reg [`OpSelLen - 1 : 0] ex_alusel
    );

always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        //TODO: ASSIGN ALL OUTPUT WITH NULL EQUIVALENT
    end
    else begin
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_Imm <= id_Imm;
        ex_rd <= id_rd;
        ex_rd_enable <= id_rd_enable;
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
    end
end

endmodule
