module RISCV (
	input clk,
	input rst,
	input sw1,
	input sw2,
	input sw3,
	input sw4,
	output wire [31:0] visualization,
	output wire [31:0] PC,
	output wire [31:0] Result,
	output wire [31:0] Recover,
	output wire [31:0] Inst_View,
	output wire [6:0] opcode_view,
	output wire [2:0] func3_view,
	output wire [6:0] func7_view,
	output wire [4:0] rs1_view,
	output wire [4:0] rs2_view,
	output wire [4:0] rd_view,
	output wire [31:0] immediate_view,
	output wire [31:0] WriteBack_view,
	output wire Branch_view,
	output wire [31:0] registers_view [31:0]
	
); 

// Address
wire [31:0] address;
wire [31:0] address_next;
wire [31:0] address_in;

// Instructions
wire [31:0] instruction;
wire [6:0] opcode;
wire [2:0] func3;
wire [6:0] func7;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [31:0] immediate;

// Extract info for the instructions
assign opcode = instruction[6:0];
assign func3 = instruction[14:12];
assign func7 = instruction[31:25];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd = instruction[11:7];

// Register
wire [31:0] RU1;
wire [31:0] RU2;
wire [31:0] regs_view [0:31];


// Control
wire RUWr;
wire [2:0] IMMSrc;
wire ALUASrcEN;
wire ALUBSrcEN;
wire [3:0] Alu_OP;
wire [2:0] BrOP;
wire DMWR;
wire [2:0] DMCtrl;
wire [1:0] RUDataWrSrc;

// ALU
wire [31:0] Alu_result;
wire [31:0] Term_A;
wire [31:0] Term_B;

// Branch
wire BrEN;

// Memory
wire [31:0] DataRead;

// Write back
wire [31:0] WriteBack;

/*
======================= CONTROL UNIT =========================
*/
Control_Unit Control_unit(
	.opcode(opcode),
	.func3(func3),
	.func7(func7),
	.RUWr(RUWr),
	.IMMSrc(IMMSrc),
	.ALUASrcEN(ALUASrcEN),
	.ALUBSrcEN(ALUBSrcEN),
	.Alu_OP(Alu_OP),
	.BrOP(BrOP),
	.DMWR(DMWR),
	.DMCtrl(DMCtrl),
	.RUDataWrSrc(RUDataWrSrc)
);

/*
===================== FETCH ===========================
*/

Program_Counter Program_Counter (
	.clk(clk),
	.rst(rst),
	.address_next(address_next),
	.address(address)
);

Sum4 Sum4 (
	.address_in(address),
	.address_out(address_in)
);

PC_mux PC_mux (
	.Alu_result(Alu_result),
	.address_in(address_in),
	.BrOpEN(BrEN),
	.address_out(address_next)
);

Instruction_Memory Instruction_Memory (
	.address(address),
	.instruction(instruction)
);


/*
===================== DECODE ============================
*/

Registers_Unit Registers_Unit (
	.clk(clk),
	.rst(rst),
	.rs1(rs1),
	.rs2(rs2),
	.rd(rd),
	.DataWr(WriteBack),
	.RUWr(RUWr),
	.RU1(RU1),
	.RU2(RU2),
	.registers_out(regs_view)
);

Imm_Generator IMM_Generator (
    .instruction(instruction),  
    .IMMSrc(IMMSrc),        
    .Imm(immediate)      
);

/*
=========================== EXECUTE ============================
*/
AluASrc Alu_A (
	.address(address),
	.RU1(RU1),
	.ALUASrcEN(ALUASrcEN),
	.Term_A(Term_A)
);

AluBSrc Alu_B (
	.RU2(RU2),
	.IMM(immediate),
	.ALUBSrcEN(ALUBSrcEN),
	.Term_B(Term_B)
);

ALU_Module ALU_Module (
	.Term_A(Term_A),
	.Term_B(Term_B),
	.Alu_OP(Alu_OP),
	.Alu_result(Alu_result)
);

Branch_Unit Branch_Unit (
	.RU1(RU1),
	.RU2(RU2),
	.BrOP(BrOP),
	.BrEN(BrEN)
);

/*
============================== MEMORY ====================================
*/

Data_Memory Data_Memory (
	.clk(clk),
	.rst(rst),
	.address(Alu_result),
	.DataWR(RU2),
	.DMWR(DMWR),
	.DMCtrl(DMCtrl),
	.DataRead(DataRead)
);

/*
=============================== Write Back ==============================
*/

Write_Back_Data Write_Back_Data (
	.address_in(address_in),
	.DataRd(DataRead),
	.Alu_result(Alu_result),
	.RUDataWrSrc(RUDataWrSrc),
	.WriteBack(WriteBack)
);


// Visualizacion
assign PC = address;
assign Result = Alu_result;
assign Recover = DataRead;
assign Inst_View = instruction;
assign opcode_view = opcode;
assign func3_view = func3;
assign func7_view = func7;
assign rs1_view = rs1;
assign rs2_view = rs2;
assign rd_view = rd;
assign immediate_view = immediate;
assign WriteBack_view = WriteBack;
assign Branch_view = BrEN;
assign registers_view = regs_view;

assign visualization = (!rst)    ? 32'b0 :
                       (sw1)     ? address :
                       (sw2)     ? Alu_result :
                       (sw3)     ? DataRead :
                       (sw4)     ? instruction :
                                   32'b0;
endmodule