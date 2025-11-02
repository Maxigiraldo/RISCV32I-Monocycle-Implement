`timescale 1ns/1ps

module TB_Riscv();

reg clk;
reg rst;
wire [31:0] PC;
wire [31:0] Result;
wire [31:0] Recover;
wire [31:0] Inst_View;

RISCV RISCV (
	.clk(clk),
	.rst(rst),
	.PC(PC),
	.Result(Result),
	.Recover(Recover),
	.Inst_View(Inst_View)
);

always #5 clk = ~clk;

initial begin
	$display("========== Iniciando Test RISCV ==========\n");
	
	// Monitor en cada ciclo
	$monitor("T=%0t | CLK=%b | RST=%b | PC=%h | Inst=%h | ALU=%h | WB=%h", 
		$time, clk, rst, PC, 
		Inst_View, Result, Recover);
	
	clk = 0;
	rst = 0;
	#20;
	rst = 1;
	#500;
	// Mostrar estado final
	$display("\n========== Estado Final (t=%0t) ==========", $time);
	$display("PC final = 0x%h", PC);
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