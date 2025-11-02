module Sum4 (
	input [31:0] address_in,
	output wire [31:0] address_out
);

assign address_out = address_in + 32'h4;

endmodule