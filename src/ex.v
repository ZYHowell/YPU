`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2019 06:12:53 PM
// Design Name: 
// Module Name: ex
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


module ex(
    input wire rst,

    input wire [`RegLen - 1 : 0] reg1,
    input wire [`RegLen - 1 : 0] reg2,
    input wire [`RegLen - 1 : 0] Imm,
    input wire [`RegLen - 1 : 0] rd,
    input wire rd_enable,
    input wire [`OpCodeLen - 1 : 0] aluop,
    input wire [`OpSelLen - 1 : 0] alusel,

    output reg [`RegLen - 1 : 0] rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr,
    output reg rd_enable_o
    );

    reg [`RegLen - 1 : 0] res;

    //Do the calculation
    always @ (*) begin
        if (rst == `ResetEnable) begin
            res = `ZERO_WORD;
        end
        else begin
            case (aluop)
                `EXE_OR:
                    res = reg1 | reg2; 
                default: 
                    res = `ZERO_WORD;
            endcase
        end
    end
    //Determine the output
    always @ (*) begin
        if (rst == `ResetEnable) begin
            rd_enable_o = `WriteDisable;
        end
        else begin 
            rd_addr = rd;
            rd_enable_o = rd_enable;
            case (alusel)
                `LOGIC_OP:
                    rd_data_o = res; 
                default: 
                    rd_data_o = `ZERO_WORD;
            endcase
        end
    end
endmodule
