`timescale 1ns/1ps

module TB_Riscv();

reg clk;
reg rst;
reg sw1, sw2, sw3, sw4;

// wire [31:0] PC;
// wire [31:0] Result;
// wire [31:0] Recover;
// wire [31:0] Inst_View;
wire [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
wire [31:0] visualization;

RISCV RISCV (
	.clk(clk),
	.rst(rst),
	.sw1(sw1),
	.sw2(sw2),
	.sw3(sw3),
	.sw4(sw4),
//	.PC(PC),
//	.Result(Result),
//	.Recover(Recover),
//	.Inst_View(Inst_View),
	.visualization(visualization),
	.hex0(hex0),
	.hex1(hex1),
	.hex2(hex2),
	.hex3(hex3),
	.hex4(hex4),
	.hex5(hex5)
);

always #20 clk = ~clk;

initial begin
	$display("========== Iniciando Test RISCV ==========\n");
	
	// Monitor en cada ciclo
	$monitor("T=%0t | CLK=%b | RST=%b | Visualization=%h | hex5=%h | hex4=%h | hex3=%h | hex2=%h | hex1=%h | hex0=%h", 
		$time, clk, rst, visualization, hex5, hex4, hex3, hex2, hex1, hex0);
	
	clk = 0;
	rst = 0;
	sw1 = 1;
	#25;
	rst = 1;
	sw1 = 0;
	sw2 = 1;
	#5;
	sw2 = 0;
	sw3 = 1;
	#5;
	sw3 = 0;
	sw4 = 1;
	#5;
	sw1 = 1;
	sw4 = 0;
	#5;
	sw1 = 0;
	sw2 = 1;
	#5;
	sw2 = 0;
	sw3 = 1;
	#5;
	sw3 = 0;
	sw4 = 1;
	#5;
	sw1 = 1;
	sw4 = 0;
	#5;
	sw1 = 0;
	sw2 = 1;
	#5;
	sw2 = 0;
	sw3 = 1;
	#5;
	sw3 = 0;
	sw4 = 1;
	#5;
	sw1 = 1;
	sw4 = 0;
	#5;
	
	#500;
	// Mostrar estado final
	$display("\n========== Estado Final (t=%0t) ==========", $time);
	$display("\n--- Registros ---");
	$display("x1 = 0x%h", RISCV.Registers_Unit.registers_mem[1]);
	$display("x2 = 0x%h", RISCV.Registers_Unit.registers_mem[2]);
	$display("x3 = 0x%h", RISCV.Registers_Unit.registers_mem[3]);
	$display("x4 = 0x%h", RISCV.Registers_Unit.registers_mem[4]);
	
	$display("\n--- Data Memory ---");
	$display("mem[0] = 0x%h", RISCV.Data_Memory.DataMem[0]);
	$display("mem[1] = 0x%h", RISCV.Data_Memory.DataMem[1]);
	
	$display("\n========== Test Finalizado ==========");
	$finish;
end

initial begin
	$dumpfile("riscv_tb.vcd");
	$dumpvars(0, TB_Riscv);
end

endmodule