module testbench1;
  
    // Clock and reset signals
    reg clk;
    reg reset;
    
    // Instantiate CPU
    cpu cpu_inst(
        .clk(clk),
        .reset(reset)
    );
    
    // Program 1: C ← A + B
    // A = 0x10, B = 0x20, C = 0x30
    // Memory[A] = 20, Memory[B] = 22, result should be 42 at Memory[C]
    
    initial begin
      
      	// Initialize data memory (already done in the memory module)
        cpu_inst.dmem.memory[16] = 20;  // Memory[A] = 20
        cpu_inst.dmem.memory[32] = 22;  // Memory[B] = 22
      
      	// Initialize instruction memory with the program
      
      	// LW $t1, 0($zero+0x10)    # Load from A (memory address 0x10) into $t1
      	cpu_inst.imem.memory[4096] = 34'b000010_0000_0001_0001_0000000000010000;
      	$display("\nInstruction stored in memory[4096]: %b", cpu_inst.imem.memory[4096]);

      	// LW $t2, 0($zero+0x20)    # Load from B (memory address 0x20) into $t2
      	cpu_inst.imem.memory[4100] = 34'b000010_0000_0010_0010_0000000000100000;
       	$display("Instruction stored in memory[4100]: %b", cpu_inst.imem.memory[4100]);


        // ADD $t3, $t1, $t2        # Add values: $t3 = $t1 + $t2
       	cpu_inst.imem.memory[4104] = 34'b000001_0001_0010_0011_0000000000000000;
       	$display("Instruction stored in memory[4104]: %b", cpu_inst.imem.memory[4104]);


        // SW $t3, 0($zero+0x30)    # Store result to C (memory address 0x30)
      	cpu_inst.imem.memory[4108] = 34'b000011_0000_0011_0011_0000000000110000;
       	$display("Instruction stored in memory[4108]: %b", cpu_inst.imem.memory[4108]);     
      

        
        // Start simulation
        reset = 1;
        #10 reset = 0;

        // Run for enough cycles to complete the program
        #155;
        
        // Check result
        if (cpu_inst.dmem.memory[48] == 42) begin
          $display("\n\nTest 1 PASSED: C = %g + %g = %g", 
                   cpu_inst.dmem.memory[16],
                   cpu_inst.dmem.memory[32],
                   cpu_inst.dmem.memory[48]);
          $display("\nRegister values:");
            $display("R0: %d", cpu_inst.regfile_inst.regfile_mem[0]);
            $display("R1: %d", cpu_inst.regfile_inst.regfile_mem[1]);
            $display("R2: %d", cpu_inst.regfile_inst.regfile_mem[2]);
          	$display("R3: %d \n", cpu_inst.regfile_inst.regfile_mem[3]);
        end else begin
          $display("\n\nTest 1 FAILED: Expected C = 42, got C =  %g + %g = %g", 
                   cpu_inst.dmem.memory[16],
                   cpu_inst.dmem.memory[32],
                   cpu_inst.dmem.memory[48]);
          $display("\nRegister values:");
            $display("R0: %d", cpu_inst.regfile_inst.regfile_mem[0]);
            $display("R1: %d", cpu_inst.regfile_inst.regfile_mem[1]);
            $display("R2: %d", cpu_inst.regfile_inst.regfile_mem[2]);
          	$display("R3: %d \n", cpu_inst.regfile_inst.regfile_mem[3]);
        end

        $finish;
    end
    
    // Clock generation
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end
    
    // Monitor important signals
    initial begin
      			$monitor("Time: %0t, PC: %0h, IR: %0h, FSM State: %0d, ALU_op: %0h, RegWrite: %0b, MemRead: %0b, MemWrite: %0b, A(0x10): %0d, B(0x20): %0d, C(0x30): %0d",
                $time, cpu_inst.pc, cpu_inst.ir, 
                cpu_inst.control_unit.present_state,
                cpu_inst.alu_op,
                cpu_inst.reg_write,
                cpu_inst.mem_read,
                cpu_inst.mem_write,
                cpu_inst.dmem.memory[16], cpu_inst.dmem.memory[32], cpu_inst.dmem.memory[48]);
    end
    
endmodule
