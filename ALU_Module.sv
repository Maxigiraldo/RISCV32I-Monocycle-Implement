module ALU_Module (
	input [31:0] Term_A,
	input [31:0] Term_B,
	input [3:0] Alu_OP,
	output reg [31:0] Alu_result
);

always @(*) begin
	case (Alu_OP)
			4'b0000: Alu_result = Term_A + Term_B;      // ADD
			4'b0001: Alu_result = Term_A - Term_B;      // SUB
			4'b0010: Alu_result = Term_A & Term_B;      // AND
			4'b0011: Alu_result = Term_A | Term_B;      // OR
			4'b0100: Alu_result = Term_A ^ Term_B;      // XOR
			4'b0101: Alu_result = Term_A << Term_B[4:0]; // SLL
			4'b0110: Alu_result = Term_A >> Term_B[4:0]; // SRL
			4'b0111: Alu_result = $signed(Term_A) >>> Term_B[4:0]; // SRA
			4'b1000: Alu_result = ($signed(Term_A) < $signed(Term_B)) ? 1 : 0; // SLT
			4'b1001: Alu_result = (Term_A < Term_B) ? 1 : 0; // SLTU
			4'b1010: Alu_result = Term_B; //Pass b (LUI)
			default: Alu_result = 32'b0;
	endcase
	end

endmodule