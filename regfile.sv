// Code your design here



module regfile (clk, read_data1, read_data2, write_data, read_addr1, read_addr2, write_addr, write_enable);
  
  //defining inputs and outputs
  input clk;  // Added clock input
  output reg [DATABUS_SIZE-1:0] read_data1;
  output reg [DATABUS_SIZE-1:0] read_data2;
  input 	 [DATABUS_SIZE-1:0] write_data;
  input 	 [REGFILE_ADDR_BITS-1:0] read_addr1;
  input 	 [REGFILE_ADDR_BITS-1:0] read_addr2;
  input 	 [REGFILE_ADDR_BITS-1:0] write_addr;
  input write_enable;
  
  //creating the memory array
  reg [DATABUS_SIZE-1:0] regfile_mem [0:REGFILE_NUM_REGS-1];
  
  // Initialize register file with zeros
  integer i;
  initial begin
    for (i = 0; i < REGFILE_NUM_REGS; i = i + 1) begin
      regfile_mem[i] = 24'b0;
    end
  end
  
  // Register write - make synchronous with clock
  always @(posedge clk) begin
    if (write_enable && (write_addr != 0)) begin
    //if (write_enable) begin
      regfile_mem[write_addr] <= write_data;
      $display("REG WRITE: R%0d = %0d", write_addr, write_data);
    end
  end
 
  // Register read - combinational
  always @(*) begin
    read_data1 = (read_addr1 == 0) ? 24'b0 : regfile_mem[read_addr1];
	read_data2 = (read_addr2 == 0) ? 24'b0 : regfile_mem[read_addr2];
  end
  
endmodule