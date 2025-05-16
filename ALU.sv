

module ALU ( input1, input2, Z, control, carry_in, flags ) ;

  
  input 	 [DATABUS_SIZE-1:0] input1 ;
  input 	 [DATABUS_SIZE-1:0] input2 ;
  output reg [DATABUS_SIZE-1:0] Z ;
  input 	 [ALU_CONTROL_SIZE-1:0] control ;
  input carry_in;
  output reg [3:0] flags ;

  // Flag bit positions
  localparam ZERO_FLAG     = 0;
  localparam CARRY_FLAG    = 1;
  localparam OVERFLOW_FLAG = 2;
  localparam SIGN_FLAG     = 3;

  // Temporary wider result for overflow detection
  reg [DATABUS_SIZE:0] temp_result;
  reg [2*DATABUS_SIZE-1:0] mul_result;

  always @(*) begin
    // Reset flags and result
    flags = 4'b0000;
    Z = {DATABUS_SIZE{1'b0}};

    case (control)
      ADD: begin
        temp_result = {1'b0, input1} + {1'b0, input2};
        Z = temp_result[DATABUS_SIZE-1:0];
        flags[CARRY_FLAG] = temp_result[DATABUS_SIZE];
        flags[OVERFLOW_FLAG] = (input1[DATABUS_SIZE-1] == input2[DATABUS_SIZE-1]) && 
        (input1[DATABUS_SIZE-1] != Z[DATABUS_SIZE-1]);
        $display("ALU [%0d] ADD: %d + %d = %d", control, input1, input2, Z);
      end

      SUB: begin
        temp_result = {1'b0, input1} - {1'b0, input2};
        Z = temp_result[DATABUS_SIZE-1:0];
        flags[CARRY_FLAG] = !temp_result[DATABUS_SIZE];
        flags[OVERFLOW_FLAG] = (input1[DATABUS_SIZE-1] != input2[DATABUS_SIZE-1]) && 
        (input1[DATABUS_SIZE-1] != Z[DATABUS_SIZE-1]);
      end

      ADDC: begin
        temp_result = {1'b0, input1} + {1'b0, input2} + {{(DATABUS_SIZE){1'b0}}, carry_in};
        Z = temp_result[DATABUS_SIZE-1:0];
        flags[CARRY_FLAG] = temp_result[DATABUS_SIZE];
      end

      SUBC: begin
        temp_result = {1'b0, input1} - {1'b0, input2} - {{(DATABUS_SIZE){1'b0}}, carry_in};
        Z = temp_result[DATABUS_SIZE-1:0];
        flags[CARRY_FLAG] = !temp_result[DATABUS_SIZE];
      end

      MUL: begin
        mul_result = input1 * input2;
        Z = mul_result[DATABUS_SIZE-1:0];
        flags[OVERFLOW_FLAG] = |mul_result[2*DATABUS_SIZE-1:DATABUS_SIZE];
      end

      DIV: begin
        if (input2 != 0) begin
          Z = input1 / input2;
        end else begin
          // Division by zero handling
          Z = {DATABUS_SIZE{1'b1}}; // All 1's
        end
      end

      AND:  Z = input1 & input2;
      OR:   Z = input1 | input2;
      XOR:  Z = input1 ^ input2;
      NOR:  Z = ~(input1 | input2);
      NAND: Z = ~(input1 & input2);
      XNOR: Z = ~(input1 ^ input2);

      SLT: begin
        Z = ($signed(input1) < $signed(input2)) ? 
        {{(DATABUS_SIZE-1){1'b0}}, 1'b1} : 
        {DATABUS_SIZE{1'b0}};
      end

      SLTU: begin
        Z = (input1 < input2) ? 
        {{(DATABUS_SIZE-1){1'b0}}, 1'b1} : 
        {DATABUS_SIZE{1'b0}};
      end

      SLL: Z = input1 << input2;
      SRL: Z = input1 >> input2;
      SRA: Z = $signed(input1) >>> input2;

      ROTL: Z = {input1[DATABUS_SIZE-1:1], input1[0]};
      ROTR: Z = {input1[DATABUS_SIZE-1], input1[DATABUS_SIZE-2:0]};

      SATADD: begin
        temp_result = {1'b0, input1} + {1'b0, input2};
        if (temp_result[DATABUS_SIZE]) begin
          // Overflow - saturate to maximum positive value
          Z = {1'b0, {(DATABUS_SIZE-1){1'b1}}};
        end else begin
          Z = temp_result[DATABUS_SIZE-1:0];
        end
      end

      SATSUB: begin
        temp_result = {1'b0, input1} - {1'b0, input2};
        if (temp_result[DATABUS_SIZE]) begin
          // Underflow - saturate to minimum value
          Z = {1'b1, {(DATABUS_SIZE-1){1'b0}}};
        end else begin
          Z = temp_result[DATABUS_SIZE-1:0];
        end
      end

      BEQ: begin
        // Compare inputs, set Z to 1 if equal, 0 otherwise
        Z = (input1 == input2) ? 
        {{(DATABUS_SIZE-1){1'b0}}, 1'b1} : 
        {DATABUS_SIZE{1'b0}};
      end
      
      BNE: begin
        // Compare inputs, set Z to 1 if not equal, 0 otherwise
        Z = (input1 != input2) ? 
        {{(DATABUS_SIZE-1){1'b0}}, 1'b1} : 
        {DATABUS_SIZE{1'b0}};
      end
      
      BLT: begin
        // Signed less than comparison
        Z = ($signed(input1) < $signed(input2)) ? 
        {{(DATABUS_SIZE-1){1'b0}}, 1'b1} : 
        {DATABUS_SIZE{1'b0}};
      end

      default: Z = {DATABUS_SIZE{1'b0}};
    endcase

    // Zero flag
    flags[ZERO_FLAG] = (Z == {DATABUS_SIZE{1'b0}});

    // Sign flag (most significant bit)
    flags[SIGN_FLAG] = Z[DATABUS_SIZE-1];
  end
endmodule