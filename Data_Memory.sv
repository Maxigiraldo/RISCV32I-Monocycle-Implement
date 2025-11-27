module Data_Memory(
    input clk,
    input rst,
    input [31:0] address,     // Dirección de memoria
    input [31:0] DataWR,      // Dato a escribir
    input DMWR,               // Señal de escritura (1: escribir, 0: leer)
    input [2:0] DMCtrl,       // Control del tipo de operación
    output reg [31:0] DataRead // Dato leído
);

    reg [31:0] DataMem [0:100]; // Memoria de datos (100 palabras de 32 bits)
    integer i;

    // ==========================
    // LECTURA DE DATOS (LOAD)
    // ==========================
    always @(*) begin
        if (!DMWR) begin
            case (DMCtrl)
                // LW: Load Word (32 bits)
                3'b010: DataRead = DataMem[address[11:2]];

                // LH: Load Halfword (16 bits con extensión de signo)
                3'b001: DataRead = {{16{DataMem[address[11:2]][15]}}, DataMem[address[11:2]][15:0]};

                // LHU: Load Halfword Unsigned (16 bits con extensión de cero)
                3'b101: DataRead = {16'b0, DataMem[address[11:2]][15:0]};

                // LB: Load Byte (8 bits con extensión de signo)
                3'b000: DataRead = {{24{DataMem[address[11:2]][7]}}, DataMem[address[11:2]][7:0]};

                // LBU: Load Byte Unsigned (8 bits con extensión de cero)
                3'b100: DataRead = {24'b0, DataMem[address[11:2]][7:0]};

                default: DataRead = 32'b0;
            endcase
        end
    end

    // ==========================
    // ESCRITURA DE DATOS (STORE)
    // ==========================
    always @(posedge clk) begin
        if (!rst) begin
            for (i = 0; i < 100; i = i + 1)
                DataMem[i] <= 32'h0;
        end 
        else if (DMWR) begin
            case (DMCtrl)
                // SW: Store Word (32 bits)
                3'b010: DataMem[address[11:2]] <= DataWR;

                // SH: Store Halfword (16 bits menos significativos)
                3'b001: DataMem[address[11:2]][15:0] <= DataWR[15:0];

                // SB: Store Byte (8 bits menos significativos)
                3'b000: DataMem[address[11:2]][7:0] <= DataWR[7:0];

                default: ; // No hacer nada
            endcase
        end
    end
endmodule
