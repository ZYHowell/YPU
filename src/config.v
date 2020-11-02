`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Gabriel
// 
// Create Date: 10/24/2019 11:41:47 PM
// Design Name: 
// Module Name: config
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

`define ZERO_WORD 32'h00000000

`define InstLen 32
`define AddrLen 32
`define RegAddrLen 5
`define RegLen 32
`define RegNum 32


`define ResetEnable 1'b1
`define ResetDisable 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0

`define RAM_SIZE 100
`define RAM_SIZELOG2 17

//OPCODE
`define OpLen 7
`define INTCOM_ORI 7'b0010011

//AluOP
`define OpCodeLen 4
`define EXE_OR 4'b0110

//AluSelect
`define OpSelLen 3
`define LOGIC_OP 3'b001