

module decode(
    input 	   [INSTRUCTION_WIDTH-1:0] instruction,
    output reg [REGFILE_ADDR_BITS-1:0] Register_R1,
    output reg [REGFILE_ADDR_BITS-1:0] Register_R2,
    output reg [REGFILE_ADDR_BITS-1:0] Register_Rd,
  	output reg [IMMEDIATE_WIDTH-1:0]   immediate,
  	output 	   [OPCODE_SIZE-1:0]       opcode
);
  
  	// Extract opcode
    assign opcode = instruction[INSTRUCTION_WIDTH-1:28];
  	// Extract raw instruction fields
    wire [REGFILE_ADDR_BITS-1:0] raw_R1 = instruction[27:24];
    wire [REGFILE_ADDR_BITS-1:0] raw_R2 = instruction[23:20];
    wire [REGFILE_ADDR_BITS-1:0] raw_Rd = instruction[19:16];
  	wire [IMMEDIATE_WIDTH-1:0] 	 raw_imm = instruction[15:0];
    
    // Determine instruction type and map fields accordingly
    always @(*) begin
        case (opcode)
            // R-type instructions (ADD, SUB, etc.)
            ADD_INSTR: begin  // ADD
                Register_R1 = raw_R1;  // First source register
                Register_R2 = raw_R2;  // Second source register
                Register_Rd = raw_Rd;  // Destination register
                immediate = raw_imm;   // Not used for R-type
            end
            
            // I-type load instructions
            LOAD_INSTR: begin  // LW
                Register_R1 = 4'b0000; //raw_R1;  // Base register
                Register_R2 = raw_R2; // Not used for loads
              	Register_Rd = raw_R2;  // Destination register (use Rd field as destination)
                immediate = raw_imm;   // Offset
            end
            
            // I-type store instructions
            STORE_INSTR: begin  // SW
                Register_R1 = 4'b0000;  // Base register
                Register_R2 = raw_R2;  // Source register for data to store
                Register_Rd = raw_R2; // No destination register for stores
                immediate = raw_imm;   // Offset
            end
            
            // Add more instruction types as needed (J-type, branches, etc.)
            
          	// Branch instructions
			BNE: begin  // Branch if Not Equal
    			Register_R1 = raw_R1;  // Compare register 1
    			Register_R2 = raw_R2;  // Compare register 2
    			Register_Rd = 4'b0000; // Not used
    			immediate = raw_imm;   // Branch offset (signed)
			end
          
            default: begin
                // Default behavior for unknown instructions
                Register_R1 = raw_R1;
                Register_R2 = raw_R2;
                Register_Rd = raw_Rd;
                immediate = raw_imm;
            end
        endcase
    end
endmodule