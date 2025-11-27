module Registers_Unit( 
	input clk, 
	input rst, 
	input [4:0] rs1, 
	input [4:0] rs2, 
	input [4:0] rd, 
	input [31:0] DataWr, 
	input RUWr, 
	output wire [31:0] RU1, 
	output wire [31:0] RU2,
	output wire [31:0] registers_out [0:31]
); 

reg [31:0] registers_mem [0:31]; 

integer i; 

assign RU1 = (rs1 == 0) ? 32'h0 : registers_mem[rs1];
assign RU2 = (rs2 == 0) ? 32'h0 : registers_mem[rs2]; 

genvar gi;
  generate
    for (gi = 0; gi < 32; gi = gi + 1) begin : REG_OUT_GEN
      assign registers_out[gi] = registers_mem[gi];
    end
  endgenerate

always @(posedge clk) 
	begin 
		if (!rst) 
			begin 
				for (i = 0; i<32; i++) 
					registers_mem[i] <= 32'b0; 
			end 
		else if (RUWr && rd != 0)  // No escribir en x0
			registers_mem[rd] <= DataWr;
	end
endmodule