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
`define CTRL_REG_WRITE_W     16'hE
`define CTRL_REG_W_TIMES     16'hF
`define CTRL_REG_W_PULSES    16'h10
`define CTRL_REG_W_COMP_VAL  16'h11
`define CTRL_REG_W_COMP_IGN  16'h12
`define CTRL_REG_W_COMP_PAR  16'h13
`define CTRL_REG_NHALGA      16'h40

// Monitor AGC Register Mirrors
`define MON_REG_A      16'h00
`define MON_REG_L      16'h01
`define MON_REG_Q      16'h02
`define MON_REG_Z      16'h03
`define MON_REG_BB     16'h04
`define MON_REG_B      16'h05
`define MON_REG_S      16'h06
`define MON_REG_G      16'h07
`define MON_REG_Y      16'h08
`define MON_REG_U      16'h09
`define MON_REG_I      16'h0A
`define MON_REG_STATUS 16'h0B
`define MON_REG_PAR    16'h0C
`define MON_REG_W      16'h40

`define W_MODE_ALL 3'o0
`define W_MODE_S   3'o1
`define W_MODE_I   3'o2
`define W_MODE_S_I 3'o3
`define W_MODE_P   3'o4
`define W_MODE_P_I 3'o5
`define W_MODE_P_S 3'o6

`define W_PULSE_A   0
`define W_PULSE_L   1
`define W_PULSE_Q   2
`define W_PULSE_Z   3
`define W_PULSE_RCH 4
`define W_PULSE_WCH 5
`define W_PULSE_G   6
`define W_PULSE_B   7
`define W_PULSE_Y   8
`define W_PULSE_U   9
