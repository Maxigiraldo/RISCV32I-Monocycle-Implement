module Data_Memory(
	input clk,
	input rst,
	input [31:0] address,
	input [31:0] DataWR,
	input DMWR,
	input DMCtrl,
	output wire [31:0] DataRead
);

reg [31:0] DataMem [0:1023];
integer i;

assign DataRead = (DMCtrl)? DataMem[address[11:2]] : 32'h0;

always @ (posedge clk)
	begin
		if (!rst)
			begin
				for (i = 0; i < 1024; i++)
					DataMem[i] <= 32'h0;
			end
		else
			if (DMWR)
				DataMem[address[11:2]] <= DataWR;
	end

endmodule