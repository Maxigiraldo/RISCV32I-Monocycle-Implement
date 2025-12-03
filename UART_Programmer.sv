module UART_Programmer #(
    parameter CLK_FREQ = 50000000, // Frecuencia de tu FPGA (50MHz)
    parameter BAUD_RATE = 115200   // Velocidad del Bluetooth
)(
    input  logic clk,
    input  logic rst_n,       // Reset del sistema (activo bajo)
    input  logic rx,          // Pin RX que viene del Bluetooth
    
    // --- NUEVOS PUERTOS AGREGADOS ---
    output logic tx,          // Pin TX para devolver el dato (Eco)
    output logic busy_led,    // LED que se enciende con actividad
    
    // Interfaz hacia la Instruction Memory
    output logic [31:0] prog_addr,
    output logic [31:0] prog_data,
    output logic        prog_we,
    
    // Control del sistema
    output logic        cpu_reset_n // Reset controlado para el RISC-V
);

    // ==========================================
    // 1. RECEPTOR UART (RX)
    // ==========================================
    logic [7:0] rx_byte;
    logic       rx_done;
    
    localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    int rx_timer = 0;
    int rx_bit_index = 0;
    
    typedef enum {IDLE_RX, START_RX, DATA_RX, STOP_RX} rx_state_t;
    rx_state_t rx_state = IDLE_RX;

    always_ff @(posedge clk) begin
        rx_done <= 0;
        if (rx_state == IDLE_RX) begin
            rx_timer <= 0;
            if (rx == 0) rx_state <= START_RX; // Start bit detectado
        end else begin
            if (rx_timer < CLK_PER_BIT - 1) begin
                rx_timer <= rx_timer + 1;
            end else begin
                rx_timer <= 0;
                case (rx_state)
                    START_RX: begin
                        rx_bit_index <= 0;
                        rx_state <= DATA_RX;
                    end
                    DATA_RX: begin
                        rx_byte[rx_bit_index] <= rx;
                        if (rx_bit_index < 7) rx_bit_index <= rx_bit_index + 1;
                        else rx_state <= STOP_RX;
                    end
                    STOP_RX: begin
                        rx_done <= 1; // Byte recibido correctamente
                        rx_state <= IDLE_RX;
                    end
                    default: rx_state <= IDLE_RX;
                endcase
            end
        end
    end

    // ==========================================
    // 2. TRANSMISOR UART (TX) - ¡NUEVO!
    // ==========================================
    typedef enum {IDLE_TX, START_TX, DATA_TX, STOP_TX} tx_state_t;
    tx_state_t tx_state = IDLE_TX;
    
    int tx_timer = 0;
    int tx_bit_index = 0;
    logic [7:0] tx_data_buffer;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            tx <= 1; // Línea en reposo (alto)
            tx_state <= IDLE_TX;
        end else begin
            if (tx_state == IDLE_TX) begin
                tx <= 1;
                tx_timer <= 0;
                // Si recibimos un byte (rx_done), lo capturamos para enviarlo (Eco)
                if (rx_done) begin
                    tx_data_buffer <= rx_byte;
                    tx_state <= START_TX;
                end
            end else begin
                if (tx_timer < CLK_PER_BIT - 1) begin
                    tx_timer <= tx_timer + 1;
                end else begin
                    tx_timer <= 0;
                    case (tx_state)
                        START_TX: begin
                            tx <= 0; // Bit de inicio
                            tx_bit_index <= 0;
                            tx_state <= DATA_TX;
                        end
                        DATA_TX: begin
                            tx <= tx_data_buffer[tx_bit_index];
                            if (tx_bit_index < 7) tx_bit_index <= tx_bit_index + 1;
                            else tx_state <= STOP_TX;
                        end
                        STOP_TX: begin
                            tx <= 1; // Bit de parada
                            tx_state <= IDLE_TX;
                        end
                    endcase
                end
            end
        end
    end

    // ==========================================
    // 3. INDICADOR DE ACTIVIDAD (LED)
    // ==========================================
    // El LED se enciende si RX o TX están trabajando
    assign busy_led = (rx_state != IDLE_RX) || (tx_state != IDLE_TX);

    // ==========================================
    // 4. MÁQUINA DE ESTADOS DEL PROGRAMADOR
    // ==========================================
    
    // Definición de estados (Esta era la parte que faltaba)
    typedef enum {WAITING, BYTE0, BYTE1, BYTE2, WRITE_MEM} prog_state_t;
    prog_state_t state = WAITING;
    
    logic [31:0] temp_instruction;
    logic [31:0] address_counter;
    logic [31:0] timeout_counter;
    
    // Timeout de aprox 1 segundo
    localparam TIMEOUT_LIMIT = CLK_FREQ;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= WAITING;
            address_counter <= 0;
            prog_we <= 0;
            cpu_reset_n <= 1; // CPU activa por defecto
            timeout_counter <= 0;
            temp_instruction <= 0;
        end else begin
            prog_we <= 0; // Pulso de escritura es solo 1 ciclo por defecto
            
            case (state)
                WAITING: begin
                    if (rx_done) begin
                        state <= BYTE0;
                        cpu_reset_n <= 0; // Apagar CPU (Reset activo)
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
                    state <= BYTE0; // Volver a esperar el siguiente byte 0
                end
            endcase
            
            // --- Lógica del Timeout ---
            if (state != WAITING) begin
                 // Si no llega nada, incrementamos el contador
                 if (timeout_counter < TIMEOUT_LIMIT) 
                    timeout_counter <= timeout_counter + 1;
                 else begin 
                    // Si se vence el tiempo, salimos del modo programación
                    state <= WAITING;
                    cpu_reset_n <= 1; // Encender CPU
                 end
                 
                 // Si llega un dato válido, reseteamos el timeout
                 if (rx_done) timeout_counter <= 0;
            end
        end
    end

endmodule