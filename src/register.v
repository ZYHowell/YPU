`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2019 04:52:34 PM
// Design Name: 
// Module Name: register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: supports 2 simultaneous read & 1 write
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module register(
    input wire clk,
    input wire rst,
    //write
    input wire write_enable,
    input wire [`RegAddrLen - 1 : 0] write_addr,
    input wire [`RegLen - 1 : 0] write_data,
    //read 1
    input wire read_enable1,   
    input wire [`RegAddrLen - 1 : 0] read_addr1,
    output reg [`RegLen - 1 : 0] read_data1,
    //read 2
    input wire read_enable2,   
    input wire [`RegAddrLen - 1 : 0] read_addr2,
    output reg [`RegLen - 1 : 0] read_data2
    );
    
    reg[`RegLen - 1 : 0] regs[`RegNum - 1 : 0];
    
//write 1
always @ (posedge clk) begin
    if (rst == `ResetDisable && write_enable == `WriteEnable) begin
        if (write_addr != `RegAddrLen'h0) //not zero register
            regs[write_addr] <= write_data;
    end
end

//read 1
always @ (*) begin
    if (rst == `ResetDisable && read_enable1 == `ReadEnable) begin
        if (read_addr1 == `RegAddrLen'h0)
            read_data1 = `ZERO_WORD;
        else if (read_addr1 == write_addr && write_enable == `WriteEnable)
            read_data1 = write_data;
        else
            read_data1 = regs[read_addr1];
    end
    else begin
        read_data1 = `ZERO_WORD;
    end
end

//read 2
always @ (*) begin
    if (rst == `ResetDisable && read_enable2 == `ReadEnable) begin
        if (read_addr2 == `RegAddrLen'h0)
            read_data2 = `ZERO_WORD;
        else if (read_addr2 == write_addr && write_enable == `WriteEnable)
            read_data2 = write_data;
        else
            read_data2 = regs[read_addr2];
    end
    else begin
        read_data2 = `ZERO_WORD;
    end
end

endmodule
