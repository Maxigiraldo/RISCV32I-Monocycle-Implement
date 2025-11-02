module Write_Back_Data(
	input [31:0] address_in,
	input [31:0] DataRd,
	input [31:0] Alu_result,
	input [1:0] RUDataWrSrc,
	output reg [31:0] WriteBack
);

always @(*)
	case (RUDataWrSrc)
		2'b00: WriteBack = Alu_result;
		2'b01: WriteBack = DataRd;
		2'b10: WriteBack = address_in;
		default: WriteBack = 32'h0;
	endcase
endmodule