module VGA_Controller (
  input clock,
  input rst,
  
  // Entradas de datos de la CPU
  input [31:0] cpu_pc,
  input [31:0] cpu_instruction,
  input [31:0] cpu_alu_result,
  input [31:0] cpu_data_memory,
  input [6:0] cpu_opcode,
  input [2:0] cpu_funct3,
  input [6:0] cpu_funct7,
  input [4:0] cpu_rs1,
  input [4:0] cpu_rs2,
  input [31:0] cpu_immediate,
  input [31:0] cpu_write_back,
  input cpu_branch,
  input [31:0] cpu_registers [0:31],
  
  // Salidas VGA
  output reg [7:0] vga_red,
  output reg [7:0] vga_green,
  output reg [7:0] vga_blue,
  output vga_hsync,
  output vga_vsync,
  output vga_clock
);

  wire [10:0] x;
  wire [9:0] y;
  wire videoOn;
  wire vgaclk;
  wire reset = rst;

  clock1280x800 vgaclock(
    .clock50(clock),
    .reset(reset),
    .vgaclk(vgaclk)
  );
  
  assign vga_clock = vgaclk;
  
  vga_controller_1280x800 pt(
    .clk(vgaclk), 
    .reset(reset), 
    .video_on(videoOn), 
    .hsync(vga_hsync), 
    .vsync(vga_vsync), 
    .hcount(x), 
    .vcount(y)
  );

  reg [7:0] font_array [0:4095];
  initial begin
    $readmemh("font.mem", font_array);
  end

  // Registros internos sincronizados con el clock VGA
  reg [31:0] instruction_reg;
  reg [31:0] pc_reg;
  reg [31:0] alu_result_reg;
  reg [31:0] data_memory_reg;
  reg [6:0] opcode_reg;
  reg [2:0] funct3_reg;
  reg [6:0] funct7_reg;
  reg [4:0] rs1_reg;
  reg [4:0] rs2_reg;
  reg [31:0] immediate_reg;
  reg [31:0] write_back_reg;
  reg branch_en;
  reg [31:0] registers [0:31];
  
  integer i;
  
  // Sincronizar datos de la CPU con el clock VGA
  always @(posedge vgaclk) begin
    if (reset) begin
      instruction_reg <= 32'h00000000;
      pc_reg <= 32'h00000000;
      alu_result_reg <= 32'h00000000;
      data_memory_reg <= 32'h00000000;
      opcode_reg <= 7'h00;
      funct3_reg <= 3'b000;
      funct7_reg <= 7'h00;
      rs1_reg <= 32'h00000000;
      rs2_reg <= 32'h00000000;
      immediate_reg <= 32'h00000000;
      write_back_reg <= 32'h00000000;
      branch_en <= 1'b0;
      for (i = 0; i <= 31; i = i + 1) begin
        registers[i] <= 32'h00000000;
      end
    end else begin
      instruction_reg <= cpu_instruction;
      pc_reg <= cpu_pc;
      alu_result_reg <= cpu_alu_result;
      data_memory_reg <= cpu_data_memory;
      opcode_reg <= cpu_opcode;
      funct3_reg <= cpu_funct3;
      funct7_reg <= cpu_funct7;
      rs1_reg <= cpu_rs1;
      rs2_reg <= cpu_rs2;
      immediate_reg <= cpu_immediate;
      write_back_reg <= cpu_write_back;
      branch_en <= cpu_branch;
      for (i = 0; i <= 31; i = i + 1) begin
        registers[i] <= cpu_registers[i];
      end
    end
  end

  function [7:0] nibble_to_hex;
    input [3:0] nibble;
    begin
      if (nibble < 10)
        nibble_to_hex = 8'h30 + nibble;
      else
        nibble_to_hex = 8'h41 + (nibble - 10);
    end
  endfunction
  
  function [7:0] digit_to_ascii;
    input [3:0] digit;
    begin
      digit_to_ascii = 8'h30 + digit;
    end
  endfunction

  localparam CHAR_W = 8;
  localparam CHAR_H = 16;

  reg [10:0] char_x_pos;
  reg [9:0] char_y_pos;
  reg [3:0] pix_row;
  reg [2:0] pix_col;
  reg [7:0] current_char;
  reg [7:0] font_data;
  wire pixel_on;
  
  reg [5:0] line_num;
  reg [6:0] col_num;
  reg [3:0] hex_digit_idx;
  reg [3:0] hex_value;
  reg [4:0] reg_index;
  reg is_title;
  
  always @* begin
    char_x_pos = x / CHAR_W;
    char_y_pos = y / CHAR_H;
    pix_row = y % CHAR_H;
    pix_col = x % CHAR_W;
    
    line_num = char_y_pos[5:0];
    col_num = char_x_pos[6:0];
    
    current_char = 8'h20;
    is_title = 0;
    
    // COLUMNA IZQUIERDA
    if (char_x_pos >= 20 && char_x_pos < 58) begin
      col_num = col_num - 20;
      case (line_num)
        0: begin
          is_title = 1;
          case (col_num)
            0: current_char = 8'h43; 1: current_char = 8'h75; 2: current_char = 8'h72;
            3: current_char = 8'h72; 4: current_char = 8'h65; 5: current_char = 8'h6E;
            6: current_char = 8'h74; 7: current_char = 8'h3A;
				default:;
          endcase
        end
        
        1: begin
          case (col_num)
            0: current_char = 8'h49; 1: current_char = 8'h6E; 2: current_char = 8'h73;
            3: current_char = 8'h74; 4: current_char = 8'h72; 5: current_char = 8'h75;
            6: current_char = 8'h63; 7: current_char = 8'h74; 8: current_char = 8'h69;
            9: current_char = 8'h6F; 10: current_char = 8'h6E; 11: current_char = 8'h3A;
            default:
              if (col_num >= 13 && col_num <= 20) begin
                hex_digit_idx = col_num - 13;
                hex_value = instruction_reg[31 - hex_digit_idx*4 -: 4];
                current_char = nibble_to_hex(hex_value);
              end
          endcase
        end
        
        2: begin
          case (col_num)
            0: current_char = 8'h50; 1: current_char = 8'h43; 2: current_char = 8'h3A;
            default:
              if (col_num >= 4 && col_num <= 11) begin
                hex_digit_idx = col_num - 4;
                hex_value = pc_reg[31 - hex_digit_idx*4 -: 4];
                current_char = nibble_to_hex(hex_value);
              end
          endcase
        end
        
        3: begin
          case (col_num)
            0: current_char = 8'h41; 1: current_char = 8'h6C; 2: current_char = 8'h75;
            3: current_char = 8'h20; 4: current_char = 8'h52; 5: current_char = 8'h65;
            6: current_char = 8'h73; 7: current_char = 8'h75; 8: current_char = 8'h6C;
            9: current_char = 8'h74; 10: current_char = 8'h3A;
            default:
              if (col_num >= 12 && col_num <= 19) begin
                hex_digit_idx = col_num - 12;
                hex_value = alu_result_reg[31 - hex_digit_idx*4 -: 4];
                current_char = nibble_to_hex(hex_value);
              end
          endcase
        end
        
        4: begin
          case (col_num)
            0: current_char = 8'h44; 1: current_char = 8'h61; 2: current_char = 8'h74;
            3: current_char = 8'h61; 4: current_char = 8'h20; 5: current_char = 8'h4D;
            6: current_char = 8'h65; 7: current_char = 8'h6D; 8: current_char = 8'h6F;
            9: current_char = 8'h72; 10: current_char = 8'h79; 11: current_char = 8'h3A;
            default:
              if (col_num >= 13 && col_num <= 20) begin
                hex_digit_idx = col_num - 13;
                hex_value = data_memory_reg[31 - hex_digit_idx*4 -: 4];
                current_char = nibble_to_hex(hex_value);
              end
          endcase
        end
        
        6: begin
          is_title = 1;
          case (col_num)
            0: current_char = 8'h45; 1: current_char = 8'h78; 2: current_char = 8'h74;
            3: current_char = 8'h72; 4: current_char = 8'h61; 5: current_char = 8'h20;
            6: current_char = 8'h69; 7: current_char = 8'h6E; 8: current_char = 8'h66;
            9: current_char = 8'h6F; 10: current_char = 8'h72; 11: current_char = 8'h6D;
            12: current_char = 8'h61; 13: current_char = 8'h74; 14: current_char = 8'h69;
            15: current_char = 8'h6F; 16: current_char = 8'h6E; 17: current_char = 8'h3A;
				default:;
          endcase
        end
        
        7: begin
          case (col_num)
            0: current_char = 8'h4F; 1: current_char = 8'h70; 2: current_char = 8'h63;
            3: current_char = 8'h6F; 4: current_char = 8'h64; 5: current_char = 8'h65;
            6: current_char = 8'h3A;
            8: current_char = nibble_to_hex(opcode_reg[6:3]);
            9: current_char = nibble_to_hex({1'b0, opcode_reg[2:0]});
				default:;
          endcase
        end
        
        8: begin
          case (col_num)
            0: current_char = 8'h46; 1: current_char = 8'h75; 2: current_char = 8'h6E;
            3: current_char = 8'h63; 4: current_char = 8'h74; 5: current_char = 8'h5F;
            6: current_char = 8'h33; 7: current_char = 8'h3A;
            9: current_char = digit_to_ascii({1'b0, funct3_reg[2]});
            10: current_char = digit_to_ascii({1'b0, funct3_reg[1]});
            11: current_char = digit_to_ascii({1'b0, funct3_reg[0]});
				default:;
          endcase
        end
        
        9: begin
          case (col_num)
            0: current_char = 8'h46; 1: current_char = 8'h75; 2: current_char = 8'h6E;
            3: current_char = 8'h63; 4: current_char = 8'h74; 5: current_char = 8'h5F;
            6: current_char = 8'h37; 7: current_char = 8'h3A;
            9: current_char = digit_to_ascii({1'b0, funct7_reg[6]});
            10: current_char = digit_to_ascii({1'b0, funct7_reg[5]});
            11: current_char = digit_to_ascii({1'b0, funct7_reg[4]});
            12: current_char = digit_to_ascii({1'b0, funct7_reg[3]});
            13: current_char = digit_to_ascii({1'b0, funct7_reg[2]});
				default:;
          endcase
        end
        
        10: begin
          case (col_num)
				0: current_char = 8'h52; 1: current_char = 8'h53; 2: current_char = 8'h31;
				3: current_char = 8'h3A; 4: current_char = 8'h20;
				5: current_char = nibble_to_hex({3'b0, rs1_reg[4]});    // bit 4 (MSB)
				6: current_char = nibble_to_hex(rs1_reg[3:0]);          // bits 3-0
				 default:;
          endcase
        end
        
        11: begin
          case (col_num)
            0: current_char = 8'h52; 1: current_char = 8'h53; 2: current_char = 8'h32;
				3: current_char = 8'h3A; 4: current_char = 8'h20;
				5: current_char = nibble_to_hex({3'b0, rs2_reg[4]});
				6: current_char = nibble_to_hex(rs2_reg[3:0]);
				default:;
          endcase
        end
        
        12: begin
          case (col_num)
            0: current_char = 8'h49; 1: current_char = 8'h6D; 2: current_char = 8'h6D;
            3: current_char = 8'h65; 4: current_char = 8'h64; 5: current_char = 8'h69;
            6: current_char = 8'h61; 7: current_char = 8'h74; 8: current_char = 8'h65;
            9: current_char = 8'h3A;
            default:
              if (col_num >= 11 && col_num <= 18) begin
                hex_digit_idx = col_num - 11;
                hex_value = immediate_reg[31 - hex_digit_idx*4 -: 4];
                current_char = nibble_to_hex(hex_value);
              end
          endcase
        end
        
        14: begin
          case (col_num)
            0: current_char = 8'h57; 1: current_char = 8'h72; 2: current_char = 8'h69;
            3: current_char = 8'h74; 4: current_char = 8'h65; 5: current_char = 8'h20;
            6: current_char = 8'h62; 7: current_char = 8'h61; 8: current_char = 8'h63;
            9: current_char = 8'h6B; 10: current_char = 8'h3A;
            default:
              if (col_num >= 12 && col_num <= 19) begin
                hex_digit_idx = col_num - 12;
                hex_value = write_back_reg[31 - hex_digit_idx*4 -: 4];
                current_char = nibble_to_hex(hex_value);
              end
          endcase
        end
        
        15: begin
          case (col_num)
            0: current_char = 8'h42; 1: current_char = 8'h72; 2: current_char = 8'h61;
            3: current_char = 8'h6E; 4: current_char = 8'h63; 5: current_char = 8'h68;
            6: current_char = 8'h3A; 7: current_char = 8'h20;
            8: current_char = branch_en ? 8'h31 : 8'h30;
				default:;
          endcase
        end
      endcase
    end
    
    // COLUMNA MEDIA - x0-x20
    else if (char_x_pos >= 58 && char_x_pos < 81) begin
      if (line_num == 0) begin
        is_title = 1;
        case (col_num - 58)
          0: current_char = 8'h52; 1: current_char = 8'h65; 2: current_char = 8'h67;
          3: current_char = 8'h69; 4: current_char = 8'h73; 5: current_char = 8'h74;
          6: current_char = 8'h65; 7: current_char = 8'h72; 8: current_char = 8'h73;
          9: current_char = 8'h3A;
			 default:;
        endcase
      end
      else if (line_num >= 1 && line_num <= 21) begin
        reg_index = line_num - 1;
        case (col_num)
          58: current_char = 8'h78;
          59: begin
            if (reg_index >= 20) current_char = 8'h32;
            else if (reg_index >= 10) current_char = 8'h31;
            else current_char = digit_to_ascii(reg_index[3:0]);
          end
          60: begin
            if (reg_index >= 10) current_char = digit_to_ascii(reg_index % 10);
            else current_char = 8'h3A;
          end
          61: begin
            if (reg_index >= 10) current_char = 8'h3A;
          end
          default:
            if (col_num >= 63 && col_num <= 70) begin
              hex_digit_idx = col_num - 63;
              hex_value = registers[reg_index][31 - hex_digit_idx*4 -: 4];
              current_char = nibble_to_hex(hex_value);
            end
        endcase
      end
    end
    
    // COLUMNA DERECHA - x21-x31
    else if (char_x_pos >= 81) begin
      if (line_num >= 1 && line_num <= 11) begin
        reg_index = 20 + line_num;
        case (col_num)
          81: current_char = 8'h78;
          82: begin
            if (reg_index >= 30) current_char = 8'h33;
            else current_char = 8'h32;
          end
          83: current_char = digit_to_ascii(reg_index % 10);
          84: current_char = 8'h3A;
          default:
            if (col_num >= 86 && col_num <= 93) begin
              hex_digit_idx = col_num - 86;
              if (reg_index <= 31)
                hex_value = registers[reg_index][31 - hex_digit_idx*4 -: 4];
              else
                hex_value = 4'h0;
              current_char = nibble_to_hex(hex_value);
            end
        endcase
      end
    end
    
    font_data = font_array[{current_char, pix_row}];
  end
  
  assign pixel_on = font_data[7 - pix_col];

  always @(posedge vgaclk) begin
  if (~videoOn) begin
    {vga_red, vga_green, vga_blue} <= 24'h000000;
  end else if (pixel_on) begin
    if (is_title) begin
      {vga_red, vga_green, vga_blue} <= 24'h00FF00;
    end else begin
      {vga_red, vga_green, vga_blue} <= 24'hFFFFFF;
    end
  end else begin
    {vga_red, vga_green, vga_blue} <= 24'h000000;
  end
end

endmodule


module clock1280x800(clock50, reset, vgaclk);
  input clock50;
  input reset;
  output vgaclk;
  logic reset_unused;
  vgaClock clk(
    .ref_clk_clk(clock50),
    .ref_reset_reset(reset),
    .reset_source_reset(reset_unused),
    .vga_clk_clk(vgaclk)
  );
endmodule


module vga_controller_1280x800 (
  input clk, reset,
  output wire hsync, vsync,
  output reg [10:0] hcount,
  output reg [9:0] vcount,
  output video_on
);
  parameter H_VISIBLE=1280, H_FP=48, H_SYNC=32, H_BP=80, H_TOTAL=1440;
  parameter V_VISIBLE=800, V_FP=3, V_SYNC=6, V_BP=22, V_TOTAL=831;
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      hcount <= 0; vcount <= 0;
    end else begin
      if (hcount == H_TOTAL - 1) begin
        hcount <= 0;
        vcount <= (vcount == V_TOTAL - 1) ? 0 : vcount + 1;
      end else hcount <= hcount + 1;
    end
  end
  
  assign hsync = (hcount >= H_VISIBLE + H_FP) && (hcount < H_VISIBLE + H_FP + H_SYNC);
  assign vsync = (vcount >= V_VISIBLE + V_FP) && (vcount < V_VISIBLE + V_FP + V_SYNC);
  assign video_on = (hcount < H_VISIBLE) && (vcount < V_VISIBLE);
endmodule