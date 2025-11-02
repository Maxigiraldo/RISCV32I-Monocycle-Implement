module Imm_Generator(
    input [31:0] instruction,  // Instrucción completa
    input [2:0] IMMSrc,        // Selector de tipo
    output reg [31:0] Imm      // Inmediato extendido a 32 bits
);

always @(*) begin
    case(IMMSrc)
        3'b000: begin  // Tipo I
            Imm = {{20{instruction[31]}}, instruction[31:20]};
        end
        
        3'b001: begin  // Tipo S
            Imm = {{20{instruction[31]}}, 
                   instruction[31:25], instruction[11:7]};
        end
        
        3'b010: begin  // Tipo B
            Imm = {{19{instruction[31]}}, 
                   instruction[31], instruction[7], 
                   instruction[30:25], instruction[11:8], 1'b0};
        end
        
        3'b011: begin  // Tipo U
            Imm = {instruction[31:12], 12'b0};
        end
        
        3'b100: begin  // Tipo J
            Imm = {{11{instruction[31]}}, 
                   instruction[31], instruction[19:12], 
                   instruction[20], instruction[30:21], 1'b0};
        end
        
        default: Imm = 32'b0;
    endcase
end

endmodule