# Custom Multi-Cycle CPU in SystemVerilog

## Overview

This project implements a custom 34-bit multi-cycle CPU using SystemVerilog. The CPU supports a simple instruction set architecture (ISA) and simulates the execution of a loop summation program (`sum = 0; for(i = 0; i < 10; i++) sum += i;`).

## Features

- ✅ Custom 34-bit ISA with:
  - R-type arithmetic instructions (ADD)
  - I-type memory access (LW, SW)
  - Branch instructions (BNE)
- ✅ Multi-cycle architecture with FSM control
- ✅ Register file with 32 general-purpose registers
- ✅ Memory-mapped instruction and data memory
- ✅ SystemVerilog testbench for loop summation verification
- ✅ Debug monitors for program counter, memory, ALU state, and FSM state

## Architecture

- **ALU**: Performs basic arithmetic and logic operations
- **Control Unit**: Finite State Machine handles the instruction lifecycle
- **Datapath**: Wires together memory, ALU, and registers
- **Memory**:
  - Instruction memory: 4KB
  - Data memory: 4KB

## Test Program: Loop Summation

This CPU runs a program that sums numbers from 0 to 9 and stores the result (55) in memory.

### Register Usage

| Register | Purpose        |
|----------|----------------|
| R1       | Loop counter i |
| R2       | Accumulator (sum) |
| R3       | Constant 1     |
| R4       | Loop limit (10 or 11 depending on approach) |

## Simulation

The simulation outputs key information:
- Current PC
- FSM state
- ALU operation
- Register contents
- Final memory output

Run using ModelSim or any SystemVerilog-compatible simulator.

## Screenshots
![image](https://github.com/user-attachments/assets/fce7ee76-4ba5-4e79-94d1-12bc2c49ce3f)
![image](https://github.com/user-attachments/assets/3c68ccb7-d2dd-4a8b-99ad-be7d10bc1fce)
![image](https://github.com/user-attachments/assets/1e4deb68-96f0-4a2b-8d31-c4a8dd13d26a)

![image](https://github.com/user-attachments/assets/4045c451-34e7-4faa-9dab-09493c373cbf)


## How to Run

1. Compile the `design.sv` and `testbench2.sv` files
2. Run the simulation:
   ```bash
   vsim -c -do "vsim +access+r; run -all; exit"
