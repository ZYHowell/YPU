// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
  input  wire [`RegLen - 1 : 0] rom_data_i,
  output wire [`InstLen - 1 : 0] rom_addr_o,
  output wire rom_ce_o
);
//PC -> IF/ID
wire [`AddrLen - 1 : 0] pc;

//IF/ID -> ID
wire [`AddrLen - 1 : 0] id_pc_i;
wire [`InstLen - 1 : 0] id_inst_i;

//Register -> ID
wire [`RegLen - 1 : 0] reg1_data;
wire [`RegLen - 1 : 0] reg2_data;

//ID -> Register
wire [`RegAddrLen - 1 : 0] reg1_addr;
wire [`RegLen - 1 : 0] reg1_read_enable;
wire [`RegAddrLen - 1 : 0] reg2_addr;
wire [`RegLen - 1 : 0] reg2_read_enable;

//ID -> ID/EX
wire [`OpCodeLen - 1 : 0] id_aluop;
wire [`OpSelLen - 1 : 0] id_alusel;
wire [`RegLen - 1 : 0] id_reg1, id_reg2, id_Imm, id_rd;
wire id_rd_enable;

//ID/EX -> EX
wire [`OpCodeLen - 1 : 0] ex_aluop;
wire [`OpSelLen - 1 : 0] ex_alusel;
wire [`RegLen - 1 : 0] ex_reg1, ex_reg2, ex_Imm, ex_rd;
wire ex_rd_enable_i;

//EX -> EX/MEM
wire [`RegLen - 1 : 0] ex_rd_data;
wire [`RegAddrLen - 1 : 0] ex_rd_addr;
wire ex_rd_enable_o;

//EX/MEM -> MEM
wire [`RegLen - 1 : 0] mem_rd_data_i;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_i;
wire mem_rd_enable_i;

//MEM -> MEM/WB
wire [`RegLen - 1 : 0] mem_rd_data_o;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_o;
wire mem_rd_enable_o;

//MEM/WB -> Register
wire write_enable;
wire [`RegAddrLen - 1 : 0] write_addr;
wire [`RegLen - 1 : 0] write_data;

assign rom_addr_o = pc;

//Instantiation
pc_reg pc_reg0(.clk(clk_in), .rst(rst_in), .pc(pc), .chip_enable(rom_ce_o));

if_id if_id0(.clk(clk_in), .rst(rst_in), .if_pc(pc), .if_inst(rom_data_i), .id_pc(id_pc_i), .id_inst(id_inst_i));

id id0(.rst(rst_in), .pc(id_pc_i), .inst(id_inst_i), .reg1_data_i(reg1_data), .reg2_data_i(reg2_data), 
      .reg1_addr_o(reg1_addr), .reg1_read_enable(reg1_read_enable), .reg2_addr_o(reg2_addr), .reg2_read_enable(reg2_read_enable),
      .reg1(id_reg1), .reg2(id_reg2), .Imm(id_Imm), .rd(id_rd), .rd_enable(id_rd_enable), .aluop(id_aluop), .alusel(id_alusel));
      
register register0(.clk(clk_in), .rst(rst_in), 
                  .write_enable(write_enable), .write_addr(write_addr), .write_data(write_data),
                  .read_enable1(reg1_read_enable), .read_addr1(reg1_addr), .read_data1(reg1_data),
                  .read_enable2(reg2_read_enable), .read_addr2(reg2_addr), .read_data2(reg2_data));
id_ex id_ex0(.clk(clk_in), .rst(rst_in),
            .id_reg1(id_reg1), .id_reg2(id_reg2), .id_Imm(id_Imm), .id_rd(id_rd), .id_rd_enable(id_rd_enable), .id_aluop(id_aluop), .id_alusel(id_alusel),
            .ex_reg1(ex_reg1), .ex_reg2(ex_reg2), .ex_Imm(ex_Imm), .ex_rd(ex_rd), .ex_rd_enable(ex_rd_enable_i), .ex_aluop(ex_aluop), .ex_alusel(ex_alusel));

ex ex0(.rst(rst_in),
      .reg1(ex_reg1), .reg2(ex_reg2), .Imm(ex_Imm), .rd(ex_rd), .rd_enable(ex_rd_enable_i), .aluop(ex_aluop), .alusel(ex_alusel),
      .rd_data_o(ex_rd_data), .rd_addr(ex_rd_addr), .rd_enable_o(ex_rd_enable_o));
      
ex_mem ex_mem0(.clk(clk_in), .rst(rst_in),
              .ex_rd_data(ex_rd_data), .ex_rd_addr(ex_rd_addr), .ex_rd_enable(ex_rd_enable_o),
              .mem_rd_data(mem_rd_data_i), .mem_rd_addr(mem_rd_addr_i), .mem_rd_enable(mem_rd_enable_i));
              
mem mem0(.rst(rst_in),
        .rd_data_i(mem_rd_data_i), .rd_addr_i(mem_rd_addr_i), .rd_enable_i(mem_rd_enable_i),
        .rd_data_o(mem_rd_data_o), .rd_addr_o(mem_rd_addr_o), .rd_enable_o(mem_rd_enable_o));
        
mem_wb mem_wb0(.clk(clk_in), .rst(rst_in),
              .mem_rd_data(mem_rd_data_o), .mem_rd_addr(mem_rd_addr_o), .mem_rd_enable(mem_rd_enable_o),
              .wb_rd_data(write_data), .wb_rd_addr(write_addr), .wb_rd_enable(write_enable));

endmodule