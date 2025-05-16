module cpu(
    input clk,
    input reset
);
    wire [ADDR_BUS_WIDTH-1:0] pc_out;
    reg [ADDR_BUS_WIDTH-1:0] pc_next;
    wire [INSTRUCTION_WIDTH-1:0] instruction;
    wire [DATABUS_SIZE-1:0] alu_result;
    wire [DATABUS_SIZE-1:0] read_data;
    wire [DATABUS_SIZE-1:0] write_data;
    wire [ADDR_BUS_WIDTH-1:0] mem_address;

    wire mem_read, mem_write, alu_src_a, i_or_d, ir_write;
    wire pc_write; 
    wire [1:0] pc_source;
    wire [1:0] alu_src_b;
    wire [OPCODE_SIZE-1:0] opcode;
    wire [ALU_CONTROL_SIZE-1:0] alu_op;
    wire reg_write;
    wire mem_to_reg;
    wire [3:0] alu_flags;
  	wire zero_flag = alu_flags[0];
  	wire writeback_alu_enable;

    reg [ADDR_BUS_WIDTH-1:0] pc;

    initial pc = 13'h1000;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 13'h1000;
        else if (pc_write)
            pc <= pc_next;
    end

    reg [ADDR_BUS_WIDTH-1:0] pc_at_decode;
    always @(posedge clk) begin
        if (ir_write)
            pc_at_decode <= pc;
    end

    wire signed [IMMEDIATE_WIDTH-1:0] imm_sext = ir[IMMEDIATE_WIDTH-1:0];
    wire signed [ADDR_BUS_WIDTH-1:0] branch_offset = $signed(imm_sext) <<< 2;
    wire [ADDR_BUS_WIDTH-1:0] branch_target = pc_at_decode + branch_offset;

    always @(*) begin
        case (pc_source)
            2'b00: pc_next = pc + 13'd4;
            2'b01: pc_next = branch_target;
            2'b10: pc_next = instruction[ADDR_BUS_WIDTH-1:0];
            default: pc_next = pc;
        endcase
      $display("Branch debug: pc_at_decode = %d, offset = %d, branch_target = %d", pc_at_decode, branch_offset, branch_target);
    end

    assign mem_address = i_or_d ? alu_result[ADDR_BUS_WIDTH-1:0] : pc;

    wire [DATABUS_SIZE-1:0] reg_data1;
    wire [DATABUS_SIZE-1:0] reg_data2;
    wire [DATABUS_SIZE-1:0] alu_in_a;
    reg  [DATABUS_SIZE-1:0] alu_in_b;

    reg [INSTRUCTION_WIDTH-1:0] ir;

    instruction_memory imem(
        .address(pc),
        .instruction(instruction)
    );

    always @(posedge clk) begin
        if (ir_write) begin
            ir <= instruction;
            $display("IR Updated with: %h, opcode: %b", instruction, instruction[INSTRUCTION_WIDTH-1:INSTRUCTION_WIDTH-OPCODE_SIZE]);
        end
    end

    assign opcode = ir[INSTRUCTION_WIDTH-1:INSTRUCTION_WIDTH-OPCODE_SIZE];

    fsm_control control_unit(
        .clk(clk),
        .reboot(reset),
        .opcode(opcode),
      	.zero_flag(zero_flag),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .ALUSrcA(alu_src_a),
        .IorD(i_or_d),
        .IRWrite(ir_write),
        .ALUSrcB(alu_src_b),
        .ALUOp(alu_op),
        .PCWrite(pc_write),
        .PCSource(pc_source),
        .RegWrite(reg_write),    
      	.MemtoReg(mem_to_reg),
      	.writeback_alu_enable(writeback_alu_enable)
    );

    assign alu_in_a = alu_src_a ? reg_data1 : {{(DATABUS_SIZE-ADDR_BUS_WIDTH){1'b0}}, pc};

    always @(*) begin
        case (alu_src_b)
            2'b00: alu_in_b = reg_data2;
            2'b01: alu_in_b = {{(DATABUS_SIZE-3){1'b0}}, 3'd4};
            2'b10: alu_in_b = {{(DATABUS_SIZE-IMMEDIATE_WIDTH){ir[IMMEDIATE_WIDTH-1]}}, ir[IMMEDIATE_WIDTH-1:0]};
            2'b11: alu_in_b = {DATABUS_SIZE{1'b0}};
        endcase
    end

    always @(posedge clk) begin
        $display("ALU INPUTS: A = %d, B = %d, Result = %d", alu_in_a, alu_in_b, alu_result);
    end

    ALU main_alu(
        .input1(alu_in_a),
        .input2(alu_in_b),
        .Z(alu_result),
        .control(alu_op),
        .carry_in(1'b0),
        .flags(alu_flags)
    );

    reg [DATABUS_SIZE-1:0] alu_result_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            alu_result_reg <= {DATABUS_SIZE{1'b0}};
        else
            alu_result_reg <= alu_result;
    end

    data_memory dmem(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(mem_address),
        .write_data(write_data),
        .read_data(read_data)
    );

    wire [REGFILE_ADDR_BITS-1:0] read_reg1, read_reg2, write_reg;
    wire [DATABUS_SIZE-1:0] write_data_reg;

    assign read_reg1 = ir[27:24];
    assign read_reg2 = ir[23:20];
    assign write_reg = ir[19:16];

    regfile regfile_inst(
        .clk(clk),
        .read_data1(reg_data1),
        .read_data2(reg_data2),
        .write_data(write_data_reg),
        .read_addr1(read_reg1),
        .read_addr2(read_reg2),
        .write_addr(write_reg),
        .write_enable(reg_write)
    );

    assign write_data = reg_data2;

    always @(posedge clk) begin
        $display("REGISTER FETCH: reg_data1 = %d, reg_data2 = %d", reg_data1, reg_data2);
    end

    reg [DATABUS_SIZE-1:0] mem_data_reg;


    // Memory data latch
    always @(posedge clk or posedge reset) begin
        if (reset)
            mem_data_reg <= {DATABUS_SIZE{1'b0}};
        else if (mem_read)
            mem_data_reg <= read_data;
    end

    assign write_data_reg = mem_to_reg ? mem_data_reg : alu_result_reg;
endmodule