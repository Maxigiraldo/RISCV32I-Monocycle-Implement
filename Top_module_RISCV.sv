module Top_module_RISCV(
	input clk,
	input clk_dedicated,
	input rst,
	input rst_dedicated,
	input sw1,
	input sw2,
	input sw3,
	input sw4,
	output [6:0] hex0,
	output [6:0] hex1,
	output [6:0] hex2,
	output [6:0] hex3,
	output [6:0] hex4,
	output [6:0] hex5,
	output [7:0] vga_red,
   output [7:0] vga_green,
   output [7:0] vga_blue,
   output vga_hsync,
   output vga_vsync,
   output vga_clock
);

wire [31:0] visualization;
wire [31:0] PC;
wire [31:0] Result;
wire [31:0] Recover;
wire [31:0] Inst_View;
wire [6:0] opcode_view;
wire [2:0] func3_view;
wire [6:0] func7_view;
wire [4:0] rs1_view;
wire [4:0] rs2_view;
wire [4:0] rd_view;
wire [31:0] immediate_view;
wire [31:0] WriteBack_view;
wire Branch_view;
wire [31:0] registers_view [31:0];

RISCV RISCV(
	.clk(clk),
	.rst(rst),
	.sw1(sw1),
	.sw2(sw2),
	.sw3(sw3),
	.sw4(sw4),
	.visualization(visualization),
	.PC(PC),
	.Result(Result),
	.Recover(Recover),
	.Inst_View(Inst_View),
	.opcode_view(opcode_view),
	.func3_view(func3_view),
	.func7_view(func7_view),
	.rs1_view(rs1_view),
	.rs2_view(rs2_view),
	.rd_view(rd_view),
	.immediate_view(immediate_view),
	.WriteBack_view(WriteBack_view),
	.Branch_view(Branch_view),
	.registers_view(registers_view)
); 

VGA_Controller VGA_Controller (
  .clock(clk_dedicated),
  .rst(rst_dedicated),
  
  // Entradas de datos de la CPU
  .cpu_pc(PC),
  .cpu_instruction(Inst_View),
  .cpu_alu_result(Result),
  .cpu_data_memory(Recover),
  .cpu_opcode(opcode_view),
  .cpu_funct3(func3_view),
  .cpu_funct7(func7_view),
  .cpu_rs1(rs1_view),
  .cpu_rs2(rs2_view),
  .cpu_immediate(immediate_view),
  .cpu_write_back(WriteBack_view),
  .cpu_branch(Branch_view),
  .cpu_registers(registers_view),
  
  // Salidas VGA
  .vga_red(vga_red),
  .vga_green(vga_green),
  .vga_blue(vga_blue),
  .vga_hsync(vga_hsync),
  .vga_vsync(vga_vsync),
  .vga_clock(vga_clock)
);

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