module fsm_control(
    input clk,
    input reboot,
    input [OPCODE_SIZE-1:0] opcode,
  	input zero_flag,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrcA,
    output reg IorD,
    output reg IRWrite,
    output reg [1:0] ALUSrcB,
    output reg [4:0] ALUOp,
    output reg PCWrite,
    output reg [1:0] PCSource,
    output reg RegWrite,
    output reg MemtoReg,
  	output reg writeback_alu_enable
);

    reg [3:0] present_state;
    reg [3:0] next_state;

    // Initialization
    initial begin
        present_state = STATE_IF;
    end

    // State update
    always @(posedge clk or posedge reboot) begin
        if (reboot)
            present_state <= STATE_IF;
        else
            present_state <= next_state;
    end

    // Debug output
    always @(present_state) begin
        $display("FSM STATE: %0d", present_state);
    end

    // Control logic
    always @(*) begin
        // Default signals
        MemRead   = 0;
        MemWrite  = 0;
        ALUSrcA   = 0;
        IorD      = 0;
        IRWrite   = 0;
        ALUSrcB   = 2'b00;
        ALUOp     = 4'b0000;
        PCWrite   = 0;
        PCSource  = 2'b00;
        RegWrite  = 0;
        MemtoReg  = 0;
        next_state = present_state;
      	writeback_alu_enable = 0;

        case (present_state)

            // FETCH
            STATE_IF: begin
                MemRead   = 1;
                IorD      = 0;
                IRWrite   = 1;
                ALUSrcA   = 0;
                ALUSrcB   = 2'b01;
                ALUOp     = ADD;
                PCWrite   = 1;
                PCSource  = 2'b00;
                next_state = STATE_ID;
            end

            // DECODE
            STATE_ID: begin
                $display("DECODE - OPCODE: %b", opcode);
                case (opcode)
                    ADD_INSTR, SUB_INSTR:
                        next_state = STATE_EXEC;
                    LOAD_INSTR, STORE_INSTR:
                        next_state = STATE_MAC;
                    JUMP_INSTR:
                        next_state = STATE_JUMP;
                    BRANCH_INSTR, BNE_INSTR:
                        next_state = STATE_BRANCH;
                    default: begin
                        $display("Unknown opcode: %b, returning to fetch", opcode);
                        next_state = STATE_IF;
                    end
                endcase
            end

            // ALU execution
            STATE_EXEC: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                ALUOp   = (opcode == ADD_INSTR) ? ADD :
                          (opcode == SUB_INSTR) ? SUB : 4'b0000;
                $display("EXEC: %s operation", (opcode == ADD_INSTR) ? "ADD" : "SUB");
                next_state = STATE_WB_ALU;
            end

            // Write ALU result
            STATE_WB_ALU: begin
                RegWrite = 1;
                MemtoReg = 0;
              	writeback_alu_enable = 1;
                $display("WRITEBACK_ALU: Writing ALU result to register");
                next_state = STATE_IF;
            end

            // Address calculation
            STATE_MAC: begin
                ALUSrcA = 1;
                ALUSrcB = 2'b10;
                ALUOp   = ADD;
                IorD    = 1;

                if (opcode == LOAD_INSTR) begin
                    MemRead = 1;
                    $display("MAC: LOAD operation");
                    next_state = STATE_WB_MEM;
                end else if (opcode == STORE_INSTR) begin
                    MemWrite = 1;
                    $display("MAC: STORE operation");
                    next_state = STATE_IF;
                end
            end

            // Write memory result
            STATE_WB_MEM: begin
                RegWrite = 1;
                MemtoReg = 1;
                $display("WRITEBACK_MEM: Writing memory data to register");
                next_state = STATE_IF;
            end

            // Branching
            STATE_BRANCH: begin
    			ALUSrcA  = 1;
    			ALUSrcB  = 2'b00;
    			ALUOp    = SUB;
    			PCSource = 2'b01;

    			if (opcode == BRANCH_INSTR) begin
        			if (zero_flag) begin
            			PCWrite = 1;
            			$display("BRANCH: BEQ condition met, branching");
        			end else begin
            			PCWrite = 0;
            			$display("BRANCH: BEQ condition not met, skipping");
        			end
    			end else if (opcode == BNE_INSTR) begin
        			if (!zero_flag) begin
            			PCWrite = 1;
            			$display("BRANCH: BNE condition met, branching");
        			end else begin
            			PCWrite = 0;
            			$display("BRANCH: BNE condition not met, skipping");
        			end
    			end

    			next_state = STATE_IF;
			end
          
            // Jumping
            STATE_JUMP: begin
                PCWrite  = 1;
                PCSource = 2'b10;
                $display("JUMP: Jumping to target address");
                next_state = STATE_IF;
            end

            default: begin
                next_state = STATE_IF;
                $display("Unknown state, returning to fetch");
            end
        endcase
    end

endmodule
