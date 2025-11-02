module AluASrc(
	input [31:0] address,
	input [31:0] RU1,
	input ALUASrcEN,
	output wire [31:0] Term_A
);

assign Term_A = (ALUASrcEN) ? address : RU1;

endmodule