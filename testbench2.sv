module testbench2;

    // Clock and reset signals
    reg clk;
    reg reset;

    // Instantiate CPU
    cpu cpu_inst(
        .clk(clk),
        .reset(reset)
    );
	
  	integer loop_limit = 10;
  
    // Initialize the program (sum = 0; for(i = 0; i < 10; i++) sum += i)
    initial begin
      
        // Preload data memory
        cpu_inst.dmem.memory[0] = 0;    	// sum
        cpu_inst.dmem.memory[4] = 0;    	// i
        cpu_inst.dmem.memory[8] = 1;    	// constant 1
      
      	// Preload loop limit into data memory (I added 1 to # of loops because branch is after increment, 
      	//so reg's will end at 11 but will loop the sum to 10)
      	cpu_inst.dmem.memory[12] = loop_limit + 1;

        // Instruction Memory Initialization

        // LW R2, 0(R0+0x00)   ; Load sum into R2
        cpu_inst.imem.memory[4096] = 34'b000010_0000_0010_0010_0000000000000000;

        // LW R1, 0(R0+0x04)   ; Load i into R1
        cpu_inst.imem.memory[4100] = 34'b000010_0000_0001_0001_0000000000000100;

        // LW R3, 0(R0+0x08)   ; Load constant 1 into R3
        cpu_inst.imem.memory[4104] = 34'b000010_0000_0011_0011_0000000000001000;

        // LW R4, 0(R0+0x0C)   ; Load loop limit (10) into R4
        cpu_inst.imem.memory[4108] = 34'b000010_0000_0100_0100_0000000000001100;

        // ADD R2, R2, R1      ; sum += i
        cpu_inst.imem.memory[4112] = 34'b000001_0010_0001_0010_0000000000000000;

        // ADD R1, R1, R3      ; i++
        cpu_inst.imem.memory[4116] = 34'b000001_0001_0011_0001_0000000000000000;

        // BNE R1, R4, -3      ; if (i != 10) loop back
        cpu_inst.imem.memory[4120] = 34'b010110_0001_0100_0000_1111111111111101;

        // SW R2, 0(R0+0x00)   ; store final sum to memory
        cpu_inst.imem.memory[4124] = 34'b000011_0000_0010_0010_0000000000000000;

        $display("\nInstructions for loop summation stored in instruction memory.\n");

        // Start simulation
        reset = 1;
        #10 reset = 0;

        // Run simulation for long enough to finish loop
        #2000;

        // Check result in memory address 0
        if (cpu_inst.dmem.memory[0] == 55) begin
            $display("\n\nTest 2 PASSED: Sum = %0d", cpu_inst.dmem.memory[0]);
        end else begin
            $display("\n\nTest 2 FAILED: Expected sum = 55, got %0d", cpu_inst.dmem.memory[0]);
        end

        // Dump key register values
        $display("\nRegister values:");
		$display("R1 (increment):       %d", cpu_inst.regfile_inst.regfile_mem[1]);
		$display("R2 (sum):             %d", cpu_inst.regfile_inst.regfile_mem[2]);
        $display("R3 (1_Constant):      %d", cpu_inst.regfile_inst.regfile_mem[3]);
      	$display("R4 (loop_limit+1):    %d\n", cpu_inst.regfile_inst.regfile_mem[4]);
      
      $display("register 1 and 4 outputs say 11 because I incremented before branching, so it still just loops from 0 to 10 even though the registers say 11\n");

        $finish;
    end

    // Clock generation
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // Monitor key events
    initial begin
        $monitor("Time: %0t | PC: %0h | IR: %0h | FSM State: %0d | ALU_op: %0h | RegWrite: %0b | MemRead: %0b | MemWrite: %0b | sum: %0d | i: %0d",
            $time, cpu_inst.pc, cpu_inst.ir,
            cpu_inst.control_unit.present_state,
            cpu_inst.alu_op,
            cpu_inst.reg_write,
            cpu_inst.mem_read,
            cpu_inst.mem_write,
            cpu_inst.dmem.memory[0],
            cpu_inst.dmem.memory[4]
        );
    end

endmodule
