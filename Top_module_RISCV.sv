module Top_module_RISCV(
    input clk,
    input clk_dedicated,
    input rst,          // Reset físico (botón)
    input rst_dedicated,
    input sw1, 
    input sw2, 
    input sw3, 
    input sw4,
    
    // --- NUEVA ENTRADA: Recibe datos del Bluetooth ---
    input uart_rx,      // Conectar al PIN_AC18 (GPIO_0[0])

    output [6:0] hex0,
    output [6:0] hex1,
    output [6:0] hex2,
    output [6:0] hex3,
    output [6:0] hex4,
    output [6:0] hex5,
    output [7:0] vga_red,
    output [7:0] vga_green,
    output [7:0] vga_blue,
    output vga_hsync,
    output vga_vsync,
    output vga_clock
);

    // --- 1. CABLES DE INTERCONEXIÓN (NUEVOS) ---
    wire [31:0] prog_addr_wire;
    wire [31:0] prog_data_wire;
    wire        prog_we_wire;
    wire        cpu_reset_control; // Reset controlado por el programador
    
    // El reset del sistema será: O presionar el botón, O que el programador lo pida.
    // (cpu_reset_n es 0 cuando se está programando, deteniendo la CPU)
    wire system_reset;
    assign system_reset = rst && cpu_reset_control; 


    // --- 2. INSTANCIA DEL PROGRAMADOR (NUEVO) ---
    UART_Programmer #(
        .CLK_FREQ(50000000), // Frecuencia del reloj de tu FPGA (50MHz)
        .BAUD_RATE(115200)   // Velocidad del Bluetooth
    ) programmer_inst (
        .clk(clk),
        .rst_n(rst),        // Reset del propio programador
        .rx(uart_rx),       // Entrada de datos seriales
        .prog_addr(prog_addr_wire),
        .prog_data(prog_data_wire),
        .prog_we(prog_we_wire),
        .cpu_reset_n(cpu_reset_control) // Salida que controla al RISC-V
    );


    // --- 3. PROCESADOR RISC-V (MODIFICADO) ---
    // Cables de visualización (originales)
    wire [31:0] visualization;
    wire [31:0] PC;
    wire [31:0] Result;
    wire [31:0] Recover;
    wire [31:0] Inst_View;
    wire [6:0] opcode_view;
    wire [2:0] func3_view;
    wire [6:0] func7_view;
    wire [4:0] rs1_view;
    wire [4:0] rs2_view;
    wire [4:0] rd_view;
    wire [31:0] immediate_view;
    wire [31:0] WriteBack_view;
    wire Branch_view;
    wire [31:0] registers_view [31:0];

    RISCV RISCV(
        .clk(clk),
        .rst(system_reset), // ¡OJO! Aquí usamos el reset combinado
        .sw1(sw1),
        .sw2(sw2),
        .sw3(sw3),
        .sw4(sw4),
        
        // Conexiones de Programación (Nuevas)
        .prog_addr(prog_addr_wire),
        .prog_data(prog_data_wire),
        .prog_we(prog_we_wire),

        // Conexiones de Visualización (Originales)
        .visualization(visualization),
        .PC(PC),
        .Result(Result),
        .Recover(Recover),
        .Inst_View(Inst_View),
        .opcode_view(opcode_view),
        .func3_view(func3_view),
        .func7_view(func7_view),
        .rs1_view(rs1_view),
        .rs2_view(rs2_view),
        .rd_view(rd_view),
        .immediate_view(immediate_view),
        .WriteBack_view(WriteBack_view),
        .Branch_view(Branch_view),
        .registers_view(registers_view)
    );


    // --- 4. VGA CONTROLLER (ORIGINAL) ---
    VGA_Controller VGA_Controller (
        .clock(clk_dedicated),
        .rst(rst_dedicated),
        .cpu_pc(PC),
        .cpu_instruction(Inst_View),
        .cpu_alu_result(Result),
        .cpu_data_memory(Recover),
        .cpu_opcode(opcode_view),
        .cpu_funct3(func3_view),
        .cpu_funct7(func7_view),
        .cpu_rs1(rs1_view),
        .cpu_rs2(rs2_view),
        .cpu_immediate(immediate_view),
        .cpu_write_back(WriteBack_view),
        .cpu_branch(Branch_view),
        .cpu_registers(registers_view),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .vga_clock(vga_clock)
    );


    // --- 5. VISUALIZACIÓN 7 SEGMENTOS (ORIGINAL) ---
    wire [3:0] hex_d0;
    wire [3:0] hex_d1;
    wire [3:0] hex_d2;
    wire [3:0] hex_d3;
    wire [3:0] hex_d4;
    wire [3:0] hex_d5;

    assign hex_d0 = visualization[3:0];
    assign hex_d1 = visualization[7:4];
    assign hex_d2 = visualization[11:8];
    assign hex_d3 = visualization[15:12];
    assign hex_d4 = visualization[19:16];
    assign hex_d5 = visualization[23:20];

    hex7seg result5 (.hex_in(hex_d5), .segments(hex5));
    hex7seg result4 (.hex_in(hex_d4), .segments(hex4));
    hex7seg result3 (.hex_in(hex_d3), .segments(hex3));
    hex7seg result2 (.hex_in(hex_d2), .segments(hex2));
    hex7seg result1 (.hex_in(hex_d1), .segments(hex1));
    hex7seg result0 (.hex_in(hex_d0), .segments(hex0));

endmodule