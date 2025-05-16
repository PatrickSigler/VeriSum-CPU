
// 2-to-1 Multiplexer
module mux2_to_1( input0, input1, out, select ) ;
  input [DATABUS_SIZE-1:0] input0 ;
  input [DATABUS_SIZE-1:0] input1 ; 
  output reg [DATABUS_SIZE-1:0] out ;
  input select ; 
  
  always @ (*) 
    if ( select )
      out <= input1 ;
    else 
      out <= input0 ;
  
endmodule

// 3-to-1 Multiplexer
module mux3_to_1(
  input [DATABUS_SIZE-1:0] input0,
  input [DATABUS_SIZE-1:0] input1,
  input [DATABUS_SIZE-1:0] input2,
  output reg [DATABUS_SIZE-1:0] out,
  input [1:0] select
);
  
  always @(*) begin
    case (select)
      2'b00: out = input0;
      2'b01: out = input1;
      2'b10: out = input2;
      default: out = input0;
    endcase
  end
  
endmodule

// 4-to-1 Multiplexer 
module mux4_to_1(
  input [DATABUS_SIZE-1:0] input0,
  input [DATABUS_SIZE-1:0] input1,
  input [DATABUS_SIZE-1:0] input2,
  input [DATABUS_SIZE-1:0] input3,
  output reg [DATABUS_SIZE-1:0] out,
  input [1:0] select
);
  
  always @(*) begin
    case (select)
      2'b00: out = input0;
      2'b01: out = input1;
      2'b10: out = input2;
      2'b11: out = input3;
      default: out = input0; 
    endcase
  end
  
endmodule

// Address Multiplexer
module mux_addr(
  input [ADDR_BUS_WIDTH-1:0] input0,
  input [ADDR_BUS_WIDTH-1:0] input1,
  output reg [ADDR_BUS_WIDTH-1:0] out,
  input select
);
  
  always @(*) begin
    if (select)
      out = input1;
    else 
      out = input0;
  end
  
endmodule