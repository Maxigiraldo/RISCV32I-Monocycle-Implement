module Program_Counter(
	input clk,
	input rst,
	input [31:0] address_next,
	output reg [31:0] address
);

always @ (posedge clk)
	begin
		if (!rst)
			address <= 32'b0;
		else
			address <= address_next;
	end
endmodule
	