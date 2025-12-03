module Instruction_Memory #(parameter MEM_DEPTH = 1024) (
    input logic clk,
    // Puerto A: Lectura (CPU RISC-V)
    input logic [31:0] address,
    output logic [31:0] instruction,
    
    // Puerto B: Escritura (Programador Bluetooth)
    input logic [31:0] prog_addr,
    input logic [31:0] prog_data,
    input logic        prog_we
);
    reg [31:0] mem [0:MEM_DEPTH-1];

    // Inicialización opcional (puedes dejar instructions.hex si quieres un programa por defecto)
    initial begin
        // $readmemh("instructions.hex", mem); 
    end

    // Lectura (CPU) - Divide por 4 porque address va en bytes
    assign instruction = mem[address[31:2]]; 

    // Escritura (Bluetooth)
    always_ff @(posedge clk) begin
        if (prog_we) begin
            mem[prog_addr] <= prog_data;
        end
    end
endmodule