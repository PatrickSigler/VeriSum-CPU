

module datapath (
  input clk, 
  input [INSTRUCTION_WIDTH-1:0] instruction,
  input [REGFILE_ADDR_BITS-1:0] read_addr1,
  input [REGFILE_ADDR_BITS-1:0] read_addr2,
  input [REGFILE_ADDR_BITS-1:0] write_addr,
  input write_enable,
  input data_control,
  input [ALU_CONTROL_SIZE-1:0] control,
  input [DATABUS_SIZE-1:0] load_data,
  output [3:0] alu_flags
);
  
  wire [DATABUS_SIZE-1:0] BusA;
  wire [DATABUS_SIZE-1:0] BusB;
  wire [DATABUS_SIZE-1:0] BusW;
  wire [DATABUS_SIZE-1:0] muxout;
  
  // Decoder connections
  wire [REGFILE_ADDR_BITS-1:0] decoded_r1;
  wire [REGFILE_ADDR_BITS-1:0] decoded_r2;
  wire [REGFILE_ADDR_BITS-1:0] decoded_rd;
  wire [IMMEDIATE_WIDTH-1:0] immediate;
  wire [OPCODE_SIZE-1:0] opcode;
  
  decode dec1 (.instruction(instruction),
               .Register_R1(decoded_r1),
               .Register_R2(decoded_r2),
               .Register_Rd(decoded_rd),
               .immediate(immediate),
               .opcode(opcode));
  
  mux2_to_1 mux1 (.input0(BusW), .input1(load_data), .out(muxout), .select(data_control));
                  
  regfile reg1 (.clk(clk),  
                .read_data1(BusA),
                .read_data2(BusB),
                .write_data(muxout),
                .read_addr1(decoded_r1),
				.read_addr2(decoded_r2),
				.write_addr(decoded_rd),
                .write_enable(write_enable));
  
  ALU alu1 (.input1(BusA),
            .input2(BusB), 
            .Z(BusW), 
            .control(control),
            .carry_in(1'b0),
            .flags(alu_flags));
  
endmodule