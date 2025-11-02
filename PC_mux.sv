module PC_mux(
	input [31:0] Alu_result,
	input [31:0] address_in,
	input BrOpEN,
	output wire [31:0] address_out
);

assign address_out = (BrOpEN) ? Alu_result : address_in;

endmodule