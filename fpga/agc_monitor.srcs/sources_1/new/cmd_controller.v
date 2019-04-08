`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module cmd_controller(
    input wire clk,
    input wire rst_n,

    // Incoming commands
    input wire [39:0] cmd,
    input wire cmd_ready,
    output reg cmd_read_en,

    // Active command address/data
    output wire [15:0] cmd_addr,
    output wire [15:0] cmd_data,

    // Read command resulting data
    input wire [15:0] read_data,

    // Completed read response
    output wire [39:0] read_msg,
    output wire read_msg_ready,

    // Control registers control signals
    output reg ctrl_read_en,
    output reg ctrl_write_en,
    input wire ctrl_write_done,

    // Status registers control signals
    output reg status_read_en,
    output reg status_write_en,

    // Monitor registers control signals
    output reg mon_reg_read_en,
    output reg mon_chan_read_en,

    // Fixed memory control signals
    output reg agc_fixed_read_en,
    input wire agc_fixed_read_done,

    // DSKY control signals
    output reg mon_dsky_read_en,
    output reg mon_dsky_write_en
);

/*******************************************************************************.
* FSM States                                                                    *
'*******************************************************************************/
localparam IDLE          = 0,
           ERASABLE      = 1,
           FIXED         = 2,
           CHANNELS      = 3,
           SIM_ERASABLE  = 4,
           SIM_FIXED     = 5,
           CONTROL       = 6,
           STATUS        = 7,
           MON_REGS      = 8,
           MON_CHANNELS  = 9,
           MON_DSKY      = 10,
           SEND_READ_MSG = 15;

reg [3:0] state;
reg [3:0] next_state;

/*******************************************************************************.
* FSM States                                                                    *
'*******************************************************************************/
// Address group of incoming command
wire [6:0] new_cmd_addr_group;
assign new_cmd_addr_group = cmd[38:32];

// Command currently being processed
reg [39:0] active_cmd;
reg [39:0] active_cmd_q;

// Active command components
wire cmd_write_flag;
wire [6:0] cmd_addr_group;
assign cmd_write_flag = active_cmd[39];
assign cmd_addr_group = active_cmd[38:32];
assign cmd_addr = active_cmd[31:16];
assign cmd_data = active_cmd[15:0];

// Read command response message
assign read_msg = {1'b1, cmd_addr_group, cmd_addr, read_data};
assign read_msg_ready = (state == SEND_READ_MSG);

/*******************************************************************************.
* Command Controller State Machine                                              *
'*******************************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
        active_cmd <= 40'b0;
    end else begin
        state <= next_state;
        active_cmd <= active_cmd_q;
    end
end

always @(*) begin
    next_state = state;
    active_cmd_q = active_cmd;
    cmd_read_en = 1'b0;
    ctrl_read_en = 1'b0;
    ctrl_write_en = 1'b0;
    status_read_en = 1'b0;
    status_write_en = 1'b0;
    mon_reg_read_en = 1'b0;
    mon_chan_read_en = 1'b0;
    agc_fixed_read_en = 1'b0;
    mon_dsky_read_en = 1'b0;
    mon_dsky_write_en = 1'b0;

    case (state)
    IDLE: begin
        if (cmd_ready) begin
            // A new command is read. Read it in, latch it, and move on to the
            // state associated with its target
            cmd_read_en = 1'b1;
            active_cmd_q = cmd;
            case (new_cmd_addr_group)
            `ADDR_GROUP_ERASABLE:     next_state = ERASABLE;
            `ADDR_GROUP_FIXED:        next_state = FIXED;
            `ADDR_GROUP_CHANNELS:     next_state = CHANNELS;
            `ADDR_GROUP_SIM_ERASABLE: next_state = SIM_ERASABLE;
            `ADDR_GROUP_SIM_FIXED:    next_state = SIM_FIXED;
            `ADDR_GROUP_CONTROL:      next_state = CONTROL;
            `ADDR_GROUP_STATUS:       next_state = STATUS;
            `ADDR_GROUP_MON_REGS:     next_state = MON_REGS;
            `ADDR_GROUP_MON_CHANNELS: next_state = MON_CHANNELS;
            `ADDR_GROUP_MON_DSKY:     next_state = MON_DSKY;
            default:                  next_state = IDLE;
            endcase
        end
    end

    ERASABLE: begin
        next_state = IDLE;
    end

    FIXED: begin
        if (~cmd_write_flag) begin
            if (agc_fixed_read_done) begin
                next_state = SEND_READ_MSG;
            end else begin
                agc_fixed_read_en = 1'b1;
            end
        end else begin
            next_state = IDLE;
        end
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
        // Control register actions are instant, so toggle the appropriate
        // signal and move on
        if (cmd_write_flag) begin
            if (ctrl_write_done) begin
                next_state = IDLE;
            end else begin
                ctrl_write_en = 1'b1;
            end
        end else begin
            ctrl_read_en = 1'b1;
            next_state = SEND_READ_MSG;
        end
    end

    STATUS: begin
        if (~cmd_write_flag) begin
            status_read_en = 1'b1;
            next_state = SEND_READ_MSG;
        end else begin
            status_write_en = 1'b1;
            next_state = IDLE;
        end
    end

    MON_REGS: begin
        if (~cmd_write_flag) begin
            mon_reg_read_en = 1'b1;
            next_state = SEND_READ_MSG;
        end else begin
            next_state = IDLE;
        end
    end

    MON_CHANNELS: begin
        if (~cmd_write_flag) begin
            mon_chan_read_en = 1'b1;
            next_state = SEND_READ_MSG;
        end else begin
            next_state = IDLE;
        end
    end

    MON_DSKY: begin
        if (~cmd_write_flag) begin
            mon_dsky_read_en = 1'b1;
            next_state = SEND_READ_MSG;
        end else begin
            mon_dsky_write_en = 1'b1;
            next_state = IDLE;
        end
    end

    SEND_READ_MSG: begin
        // The read response should now be constructed; proceed to IDLE
        next_state = IDLE;
    end

    default: begin
        next_state = IDLE;
    end

    endcase
end


endmodule
`default_nettype wire
