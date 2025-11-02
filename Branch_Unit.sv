module Branch_Unit(
	input [31:0] RU1,
	input [31:0] RU2,
	input [2:0] BrOP,
	output reg BrEN
);

always @(*)
	begin
		case (BrOP)
			3'b001: BrEN = (RU1 == RU2);           // BEQ
			3'b010: BrEN = (RU1 != RU2);           // BNE
			3'b011: BrEN = ($signed(RU1) < $signed(RU2));  // BLT
			3'b100: BrEN = ($signed(RU1) >= $signed(RU2)); // BGE
			3'b101: BrEN = (RU1 < RU2);            // BLTU
			3'b110: BrEN = (RU1 >= RU2);           // BGEU
			3'b111: BrEN = 1'b1; // Para los saltos con jal
			default: BrEN = 1'b0;
		endcase
	end
endmodule