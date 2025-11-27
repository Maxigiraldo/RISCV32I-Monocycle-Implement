module Control_Unit (
	input [6:0] opcode,
	input [2:0] func3,
	input [6:0] func7,
	output reg RUWr,
	output reg [2:0] IMMSrc,
	output reg ALUASrcEN,
	output reg ALUBSrcEN,
	output reg [3:0] Alu_OP,
	output reg [2:0] BrOP,
	output reg DMWR,
	output reg [2:0] DMCtrl,
	output reg [1:0] RUDataWrSrc
);

always@(*)
	begin
		RUWr = 1'b0;
		IMMSrc = 3'h0;
		ALUASrcEN = 1'b0;
		ALUBSrcEN = 1'b0;
		Alu_OP = 4'h0;
		BrOP = 3'h0;
		DMWR = 1'b0;
		DMCtrl = 3'b0;
		RUDataWrSrc = 2'h0;
		case (opcode)
			7'b0110011: // Tipo R
				begin
					RUWr = 1'b1;
					RUDataWrSrc = 2'h0;
					ALUASrcEN = 1'b0;
					ALUBSrcEN = 1'b0;
					
					case(func3)
						3'b000: Alu_OP = (func7[5]) ? 4'b0001 : 4'b0000; // sub : add
						3'b111: Alu_OP = 4'b0010; // and
						3'b110: Alu_OP = 4'b0011; // or
						3'b100: Alu_OP = 4'b0100; // xor
						3'b010: Alu_OP = 4'b1000; // slt
						3'b011: Alu_OP = 4'b1001; // sltu
						3'b001: Alu_OP = 4'b0101; // sll
						3'b101: Alu_OP = (func7[5]) ? 4'b0111 : 4'b0110; // sra : srl
						default: Alu_OP = 4'b0000;
					endcase
				end
			7'b0010011: // Tipo I
				begin
					RUWr = 1'b1;
					IMMSrc = 3'b000;
					ALUASrcEN = 1'b0;
					ALUBSrcEN = 1'b1;
					RUDataWrSrc = 2'h0;
					
					case(func3)
						 3'b000: Alu_OP = 4'b0000; // addi
						 3'b111: Alu_OP = 4'b0010; // andi
						 3'b110: Alu_OP = 4'b0011; // ori
						 3'b100: Alu_OP = 4'b0100; // xori
						 3'b010: Alu_OP = 4'b1000; // slti
						 3'b011: Alu_OP = 4'b1001; // sltiu
						 3'b001: Alu_OP = 4'b0101; // slli
						 3'b101: Alu_OP = (func7[5]) ? 4'b0111 : 4'b0110; // srai : srli
						 default: Alu_OP = 4'b0000;
					endcase
				end
			7'b0000011: // I de carga
				begin  // lw, lh, lb, lhu, lbu
					RUWr = 1'b1;
					IMMSrc = 3'b000; //Tipo I
					RUDataWrSrc = 2'b01;  // Escribir dato de memoria
					ALUASrcEN = 1'b0;
					ALUBSrcEN = 1'b1;     // ALU suma base + offset
					Alu_OP = 4'b0000;    // ADD
					DMWR = 1'b0;
					DMCtrl = func3;      
				end
			7'b0100011: // Tipo S
				begin  // sw, sh, sb
					RUWr = 1'b0;         // No escribir en registro
					ALUASrcEN = 1'b0;
					ALUBSrcEN = 1'b1;     // ALU suma base + offset
					Alu_OP = 4'b0000;    // ADD
					IMMSrc = 3'b001;      // Tipo S
					DMWR = 1'b1;             // Escribir en memoria
					DMCtrl = func3;
				 end
			 7'b1100011: // Tipo B
				begin  // beq, bne, blt, bge, bltu, bgeu
					RUWr = 1'b0;
					ALUASrcEN = 1'b1;
					ALUBSrcEN = 1'b1;           // Comparar rs1 con rs2
					Alu_OP = 4'b0000;
					IMMSrc = 3'b010;      // Tipo B
					
					case(func3)
						 3'b000: BrOP = 3'b001; // beq (sub para comparar)
						 3'b001: BrOP = 3'b010; // bne (sub para comparar)
						 3'b100: BrOP = 3'b011; // blt (slt)
						 3'b101: BrOP = 3'b100; // bge (slt)
						 3'b110: BrOP = 3'b101; // bltu (sltu)
						 3'b111: BrOP = 3'b110; // bgeu (sltu)
						 default: BrOP = 3'b000;
					endcase
					// rd no se usa
				end
			7'b0110111: // Tipo U
				begin  // lui
					RUWr = 1'b1;
					RUDataWrSrc = 2'b00;  // Escribir resultado de ALU
					ALUASrcEN = 1'b0;
					ALUBSrcEN = 1'b1;           // ALU usa inmediato
					Alu_OP = 4'b1010;    // Pasar B (inmediato)
					IMMSrc = 3'b011;      // Tipo U
					// func3, rs1, rs2, func7 no se usan
				end
			7'b0010111: // Tipo U
				begin  // auipc
					RUWr = 1;
					RUDataWrSrc = 2'b00;
					ALUASrcEN = 1'b1;
					ALUBSrcEN = 1'b1;          // Suma PC + inmediato (necesitas pasar PC a ALU)
					Alu_OP = 4'b0000;    // ADD
					IMMSrc = 3'b011;      // Tipo U
				end
			7'b1101111: // Tipo J
				begin  // jal
					RUWr = 1;
					RUDataWrSrc = 2'b10;  // Escribir PC+4
					ALUASrcEN = 1'b1;
					ALUBSrcEN = 1'b1;
					Alu_OP = 4'b0000;
					IMMSrc = 3'b100;      // Tipo J
					BrOP = 3'b111; // Para que de el salto
					// func3, rs1, rs2, func7 no se usan
			  end
        
        7'b1100111: // Caso jalr
			  begin  // jalr
					RUWr = 1;
					RUDataWrSrc = 2'b10;  // Escribir PC+4
					BrOP = 3'b111; // Para que de el salto
					ALUASrcEN = 1'b0;
					ALUBSrcEN = 1'b1;           // ALU suma rs1 + inmediato
					Alu_OP = 4'b0000;    // ADD
					IMMSrc = 3'b000;      // Tipo I
					// func7, rs2 no se usan
			  end
			default: ;
		endcase
	end

endmodule