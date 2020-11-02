`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2019 06:19:09 PM
// Design Name: 
// Module Name: id
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


module id(
    input wire rst,
    input wire [`AddrLen - 1 : 0] pc,
    input wire [`InstLen - 1 : 0] inst,
    input wire [`RegLen - 1 : 0] reg1_data_i,
    input wire [`RegLen - 1 : 0] reg2_data_i,

    //To Register
    output reg [`RegAddrLen - 1 : 0] reg1_addr_o,
    output reg [`RegLen - 1 : 0] reg1_read_enable,
    output reg [`RegAddrLen - 1 : 0] reg2_addr_o,
    output reg [`RegLen - 1 : 0] reg2_read_enable,

    //To next stage
    output reg [`RegLen - 1 : 0] reg1,
    output reg [`RegLen - 1 : 0] reg2,
    output reg [`RegLen - 1 : 0] Imm,
    output reg [`RegLen - 1 : 0] rd,
    output reg rd_enable,
    output reg [`OpCodeLen - 1 : 0] aluop,
    output reg [`OpSelLen - 1 : 0] alusel
    );

    wire [`OpLen - 1 : 0] opcode = inst[`OpLen - 1 : 0];
    reg useImmInstead;
    
//Decode: Get opcode, imm, rd, and the addr of rs1&rs2
always @ (*) begin
    if (rst == `ResetEnable) begin
        reg1_addr_o = `ZeroReg;
        reg2_addr_o = `ZeroReg;
    end
    else begin
        reg1_addr_o = inst[19 : 15];
        reg2_addr_o = inst[24 : 20];
    end
end
always @(*) begin
    Imm = `ZERO_WORD;
    rd_enable = `WriteDisable;
    reg1_read_enable = `ReadDisable;
    reg2_read_enable = `ReadDisable;
    rd = `ZeroReg; 
    aluop = `NOP;
    alusel = `NOP_SEL;
    useImmInstead = 1'b0;
    case (opcode)
        `INTCOM_ORI: begin
            Imm = { {19{inst[31]}} ,inst[31:20] };
            rd_enable = `WriteEnable;
            reg1_read_enable = `ReadEnable;
            reg2_read_enable = `ReadDisable;
            rd = inst[11 : 7];            
            aluop = `EXE_OR;
            alusel = `LOGIC_OP;
            useImmInstead = 1'b1;
        end
        //todo: add more op here. 
    endcase
end

//Get rs1
always @ (*) begin
    if (rst == `ResetEnable) begin
        reg1 = `ZERO_WORD;
    end
    else if (reg1_read_enable == `ReadDisable) begin
        reg1 = `ZERO_WORD;
    end
    else begin
        reg1 = reg1_data_i;
    end
end

//Get rs2
always @ (*) begin
    if (rst == `ResetEnable) begin
        reg2 = `ZERO_WORD;
    end
    else if (reg2_read_enable == `ReadDisable) begin
        if (useImmInstead == 1'b0) reg2 = `ZERO_WORD;
        else reg2 = Imm;
    end
    else begin
        reg2 = reg2_data_i;
    end
end

endmodule
