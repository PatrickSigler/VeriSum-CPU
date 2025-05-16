module data_memory(
    input clk,
    input mem_read,
    input mem_write,
  	input [ADDR_BUS_WIDTH-1:0] address,       // 13-bit address bus
  	input [DATABUS_SIZE-1:0] write_data,      // 24-bit data bus
  	output reg [DATABUS_SIZE-1:0] read_data   // 24-bit data bus
);
  
    // 8K memory locations (2^13), each storing a 24-bit data word
    reg [DATABUS_SIZE-1:0] memory [0:8191];
    
//     Initialize memory contents (I Hardcoded in DM for debugging purposes)
//     initial begin
//         memory[16] = 24'd20;  // A = 0x10 = 16 decimal
//         memory[32] = 24'd22;  // B = 0x20 = 32 decimal
//     end
    
    //Write operation (sequential)
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address] <= write_data;
            $display("DATA MEMORY: Writing data %d into memory address %d sequentially", write_data, address);
        end
    end

    //Read operation (combinational only — no posedge)
    always @(*) begin
        if (mem_read) begin
            read_data = memory[address];
            $display("DATA MEMORY: Reading data %d from memory address %d combinationally", read_data, address);
        end else begin
            read_data = 24'b0;
            $display("DATA MEMORY: (mem_read = 0) so 24'b0: %d combinationally", read_data);
        end
    end
endmodule
