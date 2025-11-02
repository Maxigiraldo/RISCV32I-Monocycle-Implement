module Instruction_Memory( 
	input [31:0] address, 
	output wire [31:0] instruction 
); 
reg [31:0] mem [0:1023];

initial 
	begin 
		$readmemh("instructions.hex", mem); 
	end 
	
assign instruction = mem[address[11:2]]; 

endmodule