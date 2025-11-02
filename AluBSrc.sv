module AluBSrc(
	input [31:0] RU2,
	input [31:0] IMM,
	input ALUBSrcEN,
	output wire [31:0] Term_B
);

assign Term_B = (ALUBSrcEN) ? IMM : RU2;

endmodule