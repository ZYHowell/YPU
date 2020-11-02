# YPU

Here we give an example of writing a CPU-like design, named YPU, in Verilog. 

YPU has only one instruction, `ori`, and is a 5-stage pipelined design. 

In YPU architecture, reading from memory is fast so it sends a WORD in a cycle. (notice that in our homework each time it sends a BYTE)

Our YPU has 3 inputs and 2 outputs: 

```verilog
module cpu(
	input  wire                 clk_in,				// system clock signal
	input  wire                 rst_in,				// reset signal
    input  wire [`RegLen - 1 : 0] rom_data_i,		// received data 
    output wire [`InstLen - 1 : 0] rom_addr_o,		// data address
    output wire rom_ce_o							// enable signal for rom
);
    ...
endmodule
```

Now let's begin: 

##### IF(pc_reg)

This part sends the PC value to rom and enable the whole chip. Since we do not have any jump instruction, we can simply add 4 each cycle if not reset. 

```Verilog
module pc_reg(
    input wire clk,
    input wire rst,
    output reg [`AddrLen - 1 : 0] pc,
    output reg chip_enable);

always @ (posedge clk) begin
    if (rst == `ResetEnable) chip_enable <= `ChipDisable;
    else chip_enable <= `ChipEnable;
end
always @ (posedge clk) begin
    if (rst == `ResetEnable)
        pc <= `ZERO_WORD;
    else pc <= pc + 4'h4;
end
endmodule
```

The two outputs are sent to rom through `rom_addr_o` and `rom_ce_o`. What does this mean? In `cpu.v`, you can see: 

```verilog
assign rom_addr_o = pc;
pc_reg pc_reg0(.clk(clk_in), .rst(rst_in), .pc(pc), .chip_enable(rom_ce_o));
```

*Remark*: How to handle a jump instruction? Just add one more 'if' as: 

```verilog
always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        pc <= `ZERO_WORD;
    end
    else begin
        if (jumpEnable) pc <= jumpAddress;
        else pc <= pc + 4'h4;
    end
end
```

Where `jumpEnable` and `jumpAddress` are two new input. Where do the two signals come from? this depends on where you calculate the instruction. See below for more detail. 

##### if_id

The goal of the module is to keep the value from `if` module and sends it to `id` module at the beginning of the next cycle. So it uses sequential circuit to send to ID: 

```verilog
module if_id(
    input wire clk, 
    input wire rst,
    input wire [`AddrLen - 1 : 0] if_pc,
    input wire [`InstLen - 1 : 0] if_inst,
    output reg [`AddrLen - 1 : 0] id_pc,
    output reg [`InstLen - 1 : 0] id_inst);
    
always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        id_pc <= `ZERO_WORD;
        id_inst <= `ZERO_WORD;
    end
    else begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end
endmodule
```

Where does the two input come from? ```if_pc``` is from the IF module, while ```if_inst``` is input from rom, so it is the ```rom_data_i``` in the CPU's input. 

The ```if_id``` is very close to ```id_ex```, ```ex_mem``` and ```mem_wb```, so we ignore it. 

##### ID

This module parses the instruction and sends requests to register file to read and write data. We divide the two function in two parts: 

```verilog
//part 1:parse process
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
    Imm = `ZeroWord;
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
```

Notice that, in the cycle, at the beginning(that is, the `posedge clk` signal) data is sent from `if_id`, so we cannot set `id` a sequential circuit. Otherwise it works in the next cycle. 

Also notice that, to avoid latch, we set all value be disable/zero at the beginning. So each value is set at all paths. 

The second part is to receive the parsed result from register file: 

```verilog
//Get rs1
always @ (*) begin
    if (rst == `ResetEnable) reg1 = `ZERO_WORD;
    else if (reg1_read_enable == `ReadDisable) reg1 = `ZERO_WORD;
    else reg1 = reg1_data_i;
end
//Get rs2
always @ (*) begin
    if (rst == `ResetEnable) 
        reg2 = `ZERO_WORD;
    else if (reg2_read_enable == `ReadDisable) begin
        if (useImmInstead == 1'b0) reg2 = `ZERO_WORD;
        else reg2 = Imm;
    end
    else begin
        reg2 = reg2_data_i;
    end
end
```

Notice that, the execution path in the cycle is: `if_id` sends at the rising time(`posedge`), then `id` notices it(`always @(*)`) and start executing the first part(parse the input instruction), then it sends `reg1_read_enable,reg1_addr_o`(and likewise those of `reg2`) to `register file`. The `register file` then outputs the result to `id` module and `id` executes the second part. Then all data to `id_ex` are ready. 

##### register file(part 1)

Now we write the register file. It records the value of each general purpose register, sends the value when required. So it also has two parts: one to handle read and the other to handle write. 

We consider the part to handle read first: 

```verilog
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
```

Reading the second register is almost the same, you only need to turn every 1 to 2. 

Notice that, in this version we do not consider the data dependency. 

How to handle it? You can maintain a mark of every register in the `register file`, and when reading the register, check if the mark is true. If so, there is an executing instruction which will write to the register. So you send back a signal to `id` module and it should try to handle it. (For example, halt part of the pipeline until the data is read successfully). 

You can also try to support data forward to alleviate the problem. Remember that you can have you own design. 

Part 2 of register file is in 'write back'

##### EX

Ex is a big `case`. However, since we handle `ori` instruction, it only has one branch. 

```verilog
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

```

Notice that, in CPU you should handle jump instructions here, conditional or not. So more outputs and judgements are required. Remember the `jumpEnable` and `jumpAddr` to `pc_reg`? 

##### mem

do nothing in YPU, but in CPU you should consider more. 

##### write back

the YPU fuses the write back with register file. So it is the second part of register file: 

```verilog
always @ (posedge clk) begin
    if (rst == `ResetDisable && write_enable == `WriteEnable) begin
        if (write_addr != `RegAddrLen'h0) //not zero register
            regs[write_addr] <= write_data;
    end
end

```

Now connect them together in `cpu.v` and your YPU is done. 

##### What's more? 

1. As mentioned in register file(part 1), the data dependency is not handled. 
2. You can make your YPU support all arithmetic instructions just like `ori`, but when you are working on the jump instruction, you should consider: 
   1. signal to `pc_reg`;
   2. clean what you've just read - they are not actually needed to be executed; 
3. When you are working on `l-type` instruction, what happens when both `mem` and `if` send requirement to the `rom`? You should implement a `mem_ctrl` module, which sends only one request to `rom` in a cycle and record the other one, handle it later. Also, `mem` and `if` should be able to handle the situation above: it should know the situation(the reading request is pending) and halt itself at the time. 
4. How to read a word when you can only read a byte in a cycle? Try finite state machine. 

##### I wanna try Tomasulo

Actually, the tutorial is also helpful for Tomasulo, since you also need `id`, `ex`, `register file`, `mem`. Tomasulo is just to add more judgement, to consider more. 