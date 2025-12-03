module UART_Programmer #(
    parameter CLK_FREQ = 50000000, // Frecuencia de tu FPGA (50MHz)
    parameter BAUD_RATE = 115200   // Velocidad del Bluetooth
)(
    input  logic clk,
    input  logic rst_n,       // Reset del sistema
    input  logic rx,          // Pin RX que viene del XIAO (Bluetooth)
    
    // Interfaz hacia la Instruction Memory
    output logic [31:0] prog_addr,
    output logic [31:0] prog_data,
    output logic        prog_we,
    
    // Control del sistema
    output logic        cpu_reset_n // Reset controlado para el RISC-V
);

    // --- 1. Receptor UART Básico ---
    logic [7:0] rx_byte;
    logic       rx_done;
    
    // Cálculo de ticks para baud rate
    localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    int bit_timer = 0;
    int bit_index = 0;
    
    typedef enum {IDLE_RX, START_BIT, DATA_BITS, STOP_BIT} rx_state_t;
    rx_state_t rx_state = IDLE_RX;

    always_ff @(posedge clk) begin
        rx_done <= 0;
        if (rx_state == IDLE_RX) begin
            bit_timer <= 0;
            if (rx == 0) begin // Start bit detectado
                rx_state <= START_BIT;
            end
        end else begin
            if (bit_timer < CLK_PER_BIT - 1) begin
                bit_timer <= bit_timer + 1;
            end else begin
                bit_timer <= 0;
                case (rx_state)
                    START_BIT: begin
                        bit_index <= 0;
                        rx_state <= DATA_BITS;
                    end
                    DATA_BITS: begin
                        rx_byte[bit_index] <= rx;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else rx_state <= STOP_BIT;
                    end
                    STOP_BIT: begin
                        rx_done <= 1; // Byte recibido correctamente
                        rx_state <= IDLE_RX;
                    end
                    default: rx_state <= IDLE_RX;
                endcase
            end
        end
    end

    // --- 2. Máquina de Estados del Programador ---
    typedef enum {WAITING, BYTE0, BYTE1, BYTE2, BYTE3, WRITE_MEM} prog_state_t;
    prog_state_t state = WAITING;
    
    logic [31:0] temp_instruction;
    logic [31:0] address_counter;
    logic [31:0] timeout_counter;
    
    // Timeout para salir del modo programación si no llegan más datos
    localparam TIMEOUT_LIMIT = CLK_FREQ; // 1 segundo aprox

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= WAITING;
            address_counter <= 0;
            prog_we <= 0;
            cpu_reset_n <= 1; // CPU activa por defecto
            timeout_counter <= 0;
            temp_instruction <= 0;
        end else begin
            prog_we <= 0; // Pulso de escritura es solo 1 ciclo
            
            case (state)
                WAITING: begin
                    if (rx_done) begin
                        state <= BYTE0; 
                        cpu_reset_n <= 0; // APAGAR CPU
                        address_counter <= 0; 
                        temp_instruction[7:0] <= rx_byte; 
                        timeout_counter <= 0;
                    end
                end

                BYTE0: begin
                   if (rx_done) begin
                       temp_instruction[15:8] <= rx_byte;
                       state <= BYTE1;
                   end
                end

                BYTE1: begin
                   if (rx_done) begin
                       temp_instruction[23:16] <= rx_byte;
                       state <= BYTE2;
                   end
                end
                
                BYTE2: begin
                   if (rx_done) begin
                       temp_instruction[31:24] <= rx_byte;
                       state <= WRITE_MEM;
                   end
                end

                WRITE_MEM: begin
                    prog_addr <= address_counter;
                    prog_data <= temp_instruction;
                    prog_we   <= 1; // ¡Escribir en RAM!
                    
                    address_counter <= address_counter + 1; 
                    state <= BYTE0; 
                end
            endcase
            
            // --- Lógica del Timeout (CORREGIDA) ---
            if (state != WAITING) begin
                 // Si no llega nada, incrementamos el contador
                 if (timeout_counter < TIMEOUT_LIMIT) 
                    timeout_counter <= timeout_counter + 1; // <--- AQUÍ ESTABA EL ERROR (antes ++)
                 else begin 
                    // Si se vence el tiempo, salimos
                    state <= WAITING; 
                    cpu_reset_n <= 1; // ENCENDER CPU
                 end
                 
                 // Si llega un dato válido, reseteamos el timeout
                 if (rx_done) timeout_counter <= 0; 
            end
        end
    end

endmodule