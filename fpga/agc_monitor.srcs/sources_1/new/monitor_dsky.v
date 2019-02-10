`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module monitor_dsky(
    input wire clk,
    input wire rst_n,
    input wire read_en,
    input wire write_en,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    output wire [15:0] data_out,

    input wire mgojam,
    input wire [12:1] mt,
    input wire [3:1] mst,
    input wire miip,
    input wire mrgg,
    input wire mrch,
    input wire mwbg,
    input wire mwsg,
    input wire [9:1] ch,
    input wire [16:1] mwl,

    input wire [15:1] out0,
    input wire [15:1] dsalmout,
    input wire [15:1] chan13,

    output reg mnhsbf,
    output reg [16:1] mdt,
    output reg monpar
);

`define RYWD_5MS_COUNT 19'd500000

wire [15:12] rywd;
assign rywd = out0[15:12];
reg [15:12] rywd_p;

reg [18:0] rywd_timer;

wire [11:1] ryb;
assign ryb = out0[11:1];

reg [9:0] prog;
reg [9:0] verb;
reg [9:0] noun;
reg [26:0] reg1;
reg [26:0] reg2;
reg [26:0] reg3;
reg prio_disp;
reg no_dap;
reg vel;
reg no_att;
reg alt;
reg gimbal_lock;
reg tracker;
reg prog_alarm;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        prog <= 10'b0;
        verb <= 10'b0;
        noun <= 10'b0;
        reg1 <= 27'b0;
        reg2 <= 27'b0;
        reg3 <= 27'b0;
        prio_disp <= 1'b0;
        no_dap <= 1'b0;
        vel <= 1'b0;
        no_att <= 1'b0;
        alt <= 1'b0;
        gimbal_lock <= 1'b0;
        tracker <= 1'b0;
        prog_alarm <= 1'b0;
        rywd_p <= 4'b0;
        rywd_timer <= `RYWD_5MS_COUNT;
    end else begin
        if (rywd == rywd_p) begin
            if (rywd_timer > 19'b0) begin
                rywd_timer <= rywd_timer - 19'b1;
            end else begin
                case (rywd)
                4'o01: begin
                    reg3[9:0] <= ryb[10:1];
                    reg3[25] <= ryb[11];
                end

                4'o02: begin
                    reg3[19:10] <= ryb[10:1];
                    reg3[26] <= ryb[11];
                end

                4'o03: begin
                    reg3[24:20] <= ryb[5:1];
                    reg2[4:0] <= ryb[10:6];
                end

                4'o04: begin
                    reg2[14:5] <= ryb[10:1];
                    reg2[25] <= ryb[11];
                end

                4'o05: begin
                    reg2[24:15] <= ryb[10:1];
                    reg2[26] <= ryb[11];
                end

                4'o06: begin
                    reg1[9:0] <= ryb[10:1];
                    reg1[25] <= ryb[11];
                end

                4'o07: begin
                    reg1[19:10] <= ryb[10:1];
                    reg1[26] <= ryb[11];
                end

                4'o10: begin
                    reg1[24:20] <= ryb[5:1];
                end

                4'o11: begin
                    noun[9:0] <= ryb[10:1];
                end

                4'o12: begin
                    verb[9:0] <= ryb[10:1];
                end

                4'o13: begin
                    prog[9:0] <= ryb[10:1];
                end

                4'o14: begin
                    prio_disp   <= ryb[1];
                    no_dap      <= ryb[2];
                    vel         <= ryb[3];
                    no_att      <= ryb[4];
                    alt         <= ryb[5];
                    gimbal_lock <= ryb[6];
                    tracker     <= ryb[8];
                    prog_alarm  <= ryb[9];
                end

                endcase
            end
        end else begin
            rywd_timer <= `RYWD_5MS_COUNT;
        end
        rywd_p <= rywd;
    end
end

reg restart_ff;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        restart_ff <= 1'b0;
    end else begin
        if (mgojam) begin
            restart_ff <= 1'b1;
        end else if (keycode == 5'b10010) begin
            restart_ff <= 1'b0;
        end
    end
end

wire restart;
assign restart = restart_ff | chan13[10];

wire upl_act;
assign upl_act = dsalmout[3];

wire stby;
assign stby = chan13[10];

wire key_rel;
assign key_rel = dsalmout[5];

wire opr_err;
assign opr_err = dsalmout[7];

wire temp;
assign temp = dsalmout[4];

wire com_act;
assign com_act = dsalmout[2];

wire vnflash;
assign vnflash = dsalmout[6];

localparam IDLE = 0,
           WAIT_FOR_RSM = 1,
           BREAK_RSM = 2,
           WAIT_FOR_NDX1 = 3,
           FORCE_TCF = 4,
           INJECT_KEY = 5,
           COMPLETE = 6;

reg [2:0] state;
reg [2:0] next_state;

wire ch15_read;
assign ch15_read = (mrch & (ch == 9'o15));

reg [1:0] ch15_read_sr;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ch15_read_sr <= 2'b0;
    end else begin
        ch15_read_sr <= {ch15_read_sr[0], ch15_read};
    end
end

reg [4:0] keycode;

always @(*) begin
    mdt = 16'o0;
    monpar = 1'b0;
    mnhsbf = 1'b0;
    case (state)
    BREAK_RSM: begin
        mdt = 16'o20;
    end

    FORCE_TCF: begin
        mnhsbf = 1'b1;
        if (mt[2]) begin
            mdt = `TCF_KEYRUPT1;
            monpar = 1'b1;
        end
        if (mt[5]) begin
            mdt = 16'o177777;
        end
    end

    INJECT_KEY: begin
        if (ch15_read) begin
            mdt = {11'b0, keycode};
        end
    end

    endcase
end

always @(*) begin
    next_state = state;
    if (mgojam | (write_en & (addr == `DSKY_REG_BUTTON))) begin
        next_state = IDLE;
    end else begin
        case (state)
        IDLE: begin
            if (keycode != 5'b0) begin
                next_state = WAIT_FOR_RSM;
            end
        end

        WAIT_FOR_RSM: begin
            if (miip & mt[8] & mrgg & mwbg & mwsg & (mwl == 16'o150017)) begin
                next_state = BREAK_RSM;
            end
        end

        BREAK_RSM: begin
            if (~mt[8]) begin
                next_state = WAIT_FOR_NDX1;
            end
        end

        WAIT_FOR_NDX1: begin
            if (mst == 3'd1) begin
                next_state = FORCE_TCF;
            end
        end

        FORCE_TCF: begin
            if (mt[10]) begin
                next_state = INJECT_KEY;
            end
        end

        INJECT_KEY: begin
            if (ch15_read_sr == 2'b10) begin
                next_state = COMPLETE;
            end
        end

        COMPLETE: begin
            next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        keycode <= 5'b0;
    end else begin
        if (state == COMPLETE) begin
            keycode <= 5'b0;
        end
        if (write_en) begin
            case (addr)
            `DSKY_REG_BUTTON: begin
                keycode <= data_in[4:0];
            end
            endcase
        end
    end
end

reg [15:0] read_data;
reg read_done;

assign data_out = read_done ? read_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_data <= 16'b0;
        read_done <= 1'b0;
    end else if (read_en) begin
        read_done <= 1'b1;
        case (addr)
        `DSKY_REG_PROG:   read_data <= {6'b0, prog};
        `DSKY_REG_VERB:   read_data <= {4'b0, verb};
        `DSKY_REG_NOUN:   read_data <= {1'b0, noun};
        `DSKY_REG_REG1_L: read_data <= {1'b0, reg1[14:0]};
        `DSKY_REG_REG1_H: read_data <= {4'b0, reg1[26:15]};
        `DSKY_REG_REG2_L: read_data <= {1'b0, reg2[14:0]};
        `DSKY_REG_REG2_H: read_data <= {4'b0, reg2[26:15]};
        `DSKY_REG_REG3_L: read_data <= {1'b0, reg3[14:0]};
        `DSKY_REG_REG3_H: read_data <= {4'b0, reg3[26:15]};
        `DSKY_REG_STATUS: read_data <= {vnflash, com_act, upl_act, no_att, stby, key_rel, opr_err, no_dap, prio_disp,
                                        temp, gimbal_lock, prog_alarm, restart, tracker, alt, vel};
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
