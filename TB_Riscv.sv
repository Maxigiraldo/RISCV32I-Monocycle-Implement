`timescale 1ns/1ps

module TB_Riscv();

reg clk, clk_dedicated;
reg rst, rst_dedicated;
reg sw1, sw2, sw3, sw4;

wire [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
wire [7:0] vga_red, vga_green, vga_blue;
wire vga_hsync, vga_vsync, vgaclock;


Top_module_RISCV Top_module_RISCV (
	.clk(clk),
	.clk_dedicated(clk_dedicated),
	.rst(rst),
	.sw1(sw1),
	.sw2(sw2),
	.sw3(sw3),
	.sw4(sw4),
	.hex0(hex0),
	.hex1(hex1),
	.hex2(hex2),
	.hex3(hex3),
	.hex4(hex4),
	.hex5(hex5),
	.vga_red(vga_red),
   .vga_green(vga_green),
   .vga_blue(vga_blue),
   .vga_hsync(vga_hsync),
   .vga_vsync(vga_vsync),
   .vga_clock(vgaclock)
);

always #6 clk_dedicated = ~clk_dedicated; // Aproximadamente 83 MHz para VGA

always #20 clk = ~clk;

initial begin
	$display("========== Iniciando Test RISCV ==========\n");
	
	// Monitor en cada ciclo
	$monitor("T=%0t | CLK=%b | FPGA_CLK=%h | RST=%b | hex5=%h | hex4=%h | hex3=%h | hex2=%h | hex1=%h | hex0=%h | red=%h | green=%h | blue=%h | hsync=%h | vsync=%h | vgaclock=%h", 
		$time, clk, clk_dedicated, rst, hex5, hex4, hex3, hex2, hex1, hex0, vga_red, vga_green, vga_blue, vga_hsync, vga_vsync, vga_clock);
	
	clk = 0;
	clk_dedicated = 0;
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