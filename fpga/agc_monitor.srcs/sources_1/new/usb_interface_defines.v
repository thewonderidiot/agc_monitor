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
