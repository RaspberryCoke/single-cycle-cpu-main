`define IMMI 3'b000
`define IMMU 3'b001
`define IMMS 3'b010
`define IMMB 3'b011
`define IMMJ 3'b100
`define IMM_NONE 3'b101
`define IMM_ERR 3'b111

//EXECUTE OPERATION
`define ADD 4'b0000
`define SUB 4'b1000
`define AND 4'b0111
`define OR  4'b0110
`define XOR 4'b0100
`define COPY 4'b0011
`define LEFT_SHIFT 4'b0001
`define RIGHT_SHIFT_UNSIGNED 4'b0101
`define RIGHT_SHIFT_SIGNED 4'b1101
`define SET_LESS_SIGNED 4'b0010
`define SET_LESS_UNSIGNED 4'b1010
`define UNDEFINEED_EXECUTE_OPERATION 4'b1111

//EXECUTE BRANCH
`define NO_JUMP 3'b000
`define ALWAYS_JUMP_PC_ADD_IMM 3'b001
`define ALWAYS_JUMP_REG_ADD_IMM 3'b010
`define TEST_EQUAL_JUMP 3'b100
`define TEST_NOT_EQUAL_JUMP 3'b101
`define TEST_LESS_THAN_JUMP 3'b110
`define TEST_LARGER_OR_EQUAL_JUMP 3'b111