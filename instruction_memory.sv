

module instruction_memory(
  	input [ADDR_BUS_WIDTH-1:0] address,           	 // 13-bit address bus
  	output reg [INSTRUCTION_WIDTH-1:0] instruction   // 34-bit instruction width
	);
  
    // 8K memory locations (2^13), each storing a 34-bit instruction
  	reg [INSTRUCTION_WIDTH-1:0] memory [8191:0];     
    
    // Read instruction from memory (combinational read)
    always @(*) begin
        instruction = memory[address];
      $display("\n\nADDRESS IN INSTRUCTION MEMORY: %0d", address);
      $display("INSTRUCTION IN INSTRUCTION MEMORY: %34b", instruction);
    end
  
  
endmodule