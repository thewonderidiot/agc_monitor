`timescale 1ns / 1ps

// SLIP special characters
`define SLIP_END     8'hC0
`define SLIP_ESC     8'hDB
`define SLIP_ESC_END 8'hDC
`define SLIP_ESC_ESC 8'hDD

// Message format
`define MSG_READ_LENGTH  3'd3
`define MSG_WRITE_LENGTH 3'd5

// Groups
`define ADDR_GROUP_ERASABLE     7'h00
`define ADDR_GROUP_FIXED        7'h01
`define ADDR_GROUP_CHANNELS     7'h02
`define ADDR_GROUP_SIM_ERASABLE 7'h10
`define ADDR_GROUP_SIM_FIXED    7'h11
`define ADDR_GROUP_CONTROL      7'h20
`define ADDR_GROUP_MON_REGS     7'h21
`define ADDR_GROUP_MON_CHANNELS 7'h22

// Control Registers
`define CTRL_REG_START       16'h0
`define CTRL_REG_STOP        16'h1
`define CTRL_REG_STOP_CAUSE  16'h2
`define CTRL_REG_PROCEED     16'h3
`define CTRL_REG_MNHRPT      16'h4
`define CTRL_REG_MNHNC       16'h5
`define CTRL_REG_S1_S        16'h6
`define CTRL_REG_S1_BANK     16'h7
`define CTRL_REG_S1_S_IGN    16'h8
`define CTRL_REG_S1_BANK_IGN 16'h9
`define CTRL_REG_S2_S        16'hA
`define CTRL_REG_S2_BANK     16'hB
`define CTRL_REG_S2_S_IGN    16'hC
`define CTRL_REG_S2_BANK_IGN 16'hD
`define CTRL_REG_NHALGA      16'h40

// Monitor AGC Register Mirrors
`define MON_REG_A      16'o00
`define MON_REG_L      16'o01
`define MON_REG_Q      16'o02
`define MON_REG_Z      16'o03
`define MON_REG_BB     16'o04
`define MON_REG_B      16'o05
`define MON_REG_S      16'o06
`define MON_REG_G      16'o07
`define MON_REG_Y      16'o10
`define MON_REG_U      16'o11
`define MON_REG_I      16'o12
`define MON_REG_STATUS 16'o13
