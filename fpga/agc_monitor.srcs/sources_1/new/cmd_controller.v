`timescale 1ns / 1ps

`include "usb_interface_defines.v"

module cmd_controller(
    input wire clk,
    input wire rst_n,
    input wire [39:0] cmd,
    input wire cmd_ready,
    output reg cmd_read_en
);

localparam IDLE         = 0,
           ERASABLE     = 1,
           FIXED        = 2,
           CHANNELS     = 3,
           SIM_ERASABLE = 4,
           SIM_FIXED    = 5,
           CONTROL      = 6,
           MON_REGS     = 7;

reg [39:0] active_cmd;

wire cmd_write_flag;
wire [7:0] cmd_addr_group;
wire [15:0] cmd_addr;
wire [15:0] cmd_data;

assign cmd_addr_group = cmd[38:32];

assign cmd_write_flag = active_cmd[39];
assign cmd_addr = active_cmd[31:16];
assign cmd_data = active_cmd[15:0];

reg [2:0] state;
reg [2:0] next_state;

always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
        active_cmd <= 40'b0;
    end else begin
        state <= next_state;
        if ((state == IDLE) && cmd_read_en) begin
            active_cmd <= cmd;
        end
    end
end

always @(*) begin
    next_state = state;
    cmd_read_en = 1'b0;

    case (state)
    IDLE: begin
        if (cmd_ready) begin
            cmd_read_en = 1'b1;
            case (cmd_addr_group)
            `ADDR_GROUP_ERASABLE:     next_state = ERASABLE;
            `ADDR_GROUP_FIXED:        next_state = FIXED;
            `ADDR_GROUP_CHANNELS:     next_state = CHANNELS;
            `ADDR_GROUP_SIM_ERASABLE: next_state = SIM_ERASABLE;
            `ADDR_GROUP_SIM_FIXED:    next_state = SIM_FIXED;
            `ADDR_GROUP_CONTROL:      next_state = CONTROL;
            `ADDR_GROUP_MON_REGS:     next_state = MON_REGS;
            default:                  next_state = IDLE;
            endcase
        end
    end

    ERASABLE: begin
        next_state = IDLE;
    end

    FIXED: begin
        next_state = IDLE;
    end

    CHANNELS: begin
        next_state = IDLE;
    end

    SIM_ERASABLE: begin
        next_state = IDLE;
    end

    SIM_FIXED: begin
        next_state = IDLE;
    end

    CONTROL: begin
        next_state = IDLE;
    end

    MON_REGS: begin
        next_state = IDLE;
    end

    default: begin
        next_state = IDLE;
    end

    endcase
end


endmodule
