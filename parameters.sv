// Design parameters for the project

parameter DATABUS_SIZE = 24 ;
parameter DATABUS_MSB = DATABUS_SIZE - 1;
parameter ALU_CONTROL_SIZE = 5 ;
parameter REGFILE_ADDR_BITS = 4;
parameter REGFILE_NUM_REGS = (1 << REGFILE_ADDR_BITS);
parameter REGFILE_WIDTH = 24;
parameter ADDR_BUS_WIDTH = 13;

// ALU Control Parameters
parameter ADD   = 0;
parameter SUB   = 1;
parameter AND   = 2;
parameter OR    = 3;
parameter XOR   = 4;
parameter XNOR  = 5;
parameter NAND  = 6;
parameter NOR   = 7;
parameter SLT   = 8;
parameter SLL   = 9;
parameter SRL   = 10;
parameter SRA   = 11;

// Additional Embedded Systems Operations
parameter ADDC   = 12;
parameter SUBC   = 13;
parameter MUL    = 14;
parameter DIV    = 15;
parameter SLTU   = 16;
parameter ROTL   = 17;
parameter ROTR   = 18;
parameter SATADD = 19;
parameter SATSUB = 20;

// New Branch Comparison Operations
parameter BEQ     = 21; // Branch if Equal
parameter BNE     = 22; // Branch if Not Equal
parameter BLT     = 23; // Branch if Less Than

// Instruction Type Opcodes
parameter OPCODE_R_TYPE     = 6'b000000; // R-type base
parameter OPCODE_I_TYPE_MIN = 6'b000001; // I-type start range
parameter OPCODE_I_TYPE_MAX = 6'b011111; // I-type end range
parameter OPCODE_J_TYPE_MIN = 6'b100000; // J-type start range
parameter OPCODE_J_TYPE_MAX = 6'b111111; // J-type end range

//shifts
parameter R_TYPE_SHIFT = 12'b0;
parameter I_TYPE_SHIFT = 4'b0;
parameter J_TYPE_SHIFT = 8'b0;

//instructions for decode.sv
parameter INSTRUCTION_WIDTH = 34 ;
parameter IMMEDIATE_WIDTH = 16 ;
parameter OPCODE_SIZE = 6 ;

// Instruction opcodes 
parameter ADD_INSTR = 6'b000001;  
parameter SUB_INSTR = 6'b000110;
parameter LOAD_INSTR = 6'b000010;
parameter STORE_INSTR = 6'b000011;
parameter JUMP_INSTR = 6'b100000;
parameter BRANCH_INSTR = 6'b000100;
parameter BNE_INSTR = 6'b010110;  // BNE instruction opcode

// FSM states
parameter STATE_IF = 0 ;
parameter STATE_ID = 1 ;
parameter STATE_MAC = 2 ;
parameter STATE_EXEC = 3 ;
parameter STATE_BRANCH = 4 ;
parameter STATE_JUMP = 5 ;
parameter STATE_WB_ALU = 6;
parameter STATE_WB_MEM = 7;
