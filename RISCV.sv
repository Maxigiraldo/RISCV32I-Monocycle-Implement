module RISCV (
	input clk,
	input rst,
	input sw1,
	input sw2,
	input sw3,
	input sw4,
	output wire [31:0] visualization,
//	output wire [31:0] PC,
//	output wire [31:0] Result,
//	output wire [31:0] Recover,
//	output wire [31:0] Inst_View
	output [6:0] hex0,
	output [6:0] hex1,
	output [6:0] hex2,
	output [6:0] hex3,
	output [6:0] hex4,
	output [6:0] hex5
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

// Control
wire RUWr;
wire [2:0] IMMSrc;
wire ALUASrcEN;
wire ALUBSrcEN;
wire [3:0] Alu_OP;
wire [2:0] BrOP;
wire DMWR;
wire DMCtrl;
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
	.RU2(RU2)
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
// assign PC = address;
// assign Result = Alu_result;
// assign Recover = DataRead;
// assign Inst_View = instruction;

assign visualization = (!rst)    ? 32'b0 :
                       (sw1)     ? address :
                       (sw2)     ? Alu_result :
                       (sw3)     ? DataRead :
                       (sw4)     ? instruction :
                                   32'b0;

wire [3:0] hex_d0;
wire [3:0] hex_d1;
wire [3:0] hex_d2;
wire [3:0] hex_d3;
wire [3:0] hex_d4;
wire [3:0] hex_d5;

assign hex_d0 = visualization[3:0];
assign hex_d1 = visualization[7:4];
assign hex_d2 = visualization[11:8];
assign hex_d3 = visualization[15:12];
assign hex_d4 = visualization[19:16];
assign hex_d5 = visualization[23:20];


hex7seg result5 (
		.hex_in(hex_d5),
		.segments(hex5)
	);
	
hex7seg result4 (
	.hex_in(hex_d4),
	.segments(hex4)
);
hex7seg result3 (
	.hex_in(hex_d3),
	.segments(hex3)
);
hex7seg result2 (
	.hex_in(hex_d2),
	.segments(hex2)
);
hex7seg result1 (
	.hex_in(hex_d1),
	.segments(hex1)
);
hex7seg result0 (
	.hex_in(hex_d0),
	.segments(hex0)
);

endmodule