`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module rupt_injector(
    input wire clk,
    input wire rst_n,

    input wire keyrupt1,
    input wire keyrupt2,
    input wire uprupt,
    input wire downrupt,
    input wire handrupt,

    input wire mgojam,
    input wire [12:1] mt,
    input wire [3:1] mst,
    input wire msqext,
    input wire [15:10] sq,
    input wire miip,
    input wire mrgg,
    input wire mwbg,
    input wire [16:1] mwl,

    output reg mnhsbf,
    output reg [16:1] mdt,
    output reg monpar
);

localparam IDLE = 0,
           WAIT_FOR_RSM = 1,
           BREAK_RSM = 2,
           WAIT_FOR_NDX1 = 3,
           FORCE_TCF = 4,
           COMPLETE = 5;

reg [2:0] state;
reg [2:0] next_state;

reg [4:0] pending_rupts;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pending_rupts <= 5'b0;
    end else begin
        if (keyrupt1) begin
            pending_rupts[0] <= 1'b1;
        end else if ((state == COMPLETE) && (tcf_rupt == `TCF_KEYRUPT1)) begin
            pending_rupts[0] <= 1'b0;
        end

        if (keyrupt2) begin
            pending_rupts[1] <= 1'b1;
        end else if ((state == COMPLETE) && (tcf_rupt == `TCF_KEYRUPT2)) begin
            pending_rupts[1] <= 1'b0;
        end

        if (uprupt) begin
            pending_rupts[2] <= 1'b1;
        end else if ((state == COMPLETE) && (tcf_rupt == `TCF_UPRUPT)) begin
            pending_rupts[2] <= 1'b0;
        end

        if (downrupt) begin
            pending_rupts[3] <= 1'b1;
        end else if ((state == COMPLETE) && (tcf_rupt == `TCF_DOWNRUPT)) begin
            pending_rupts[3] <= 1'b0;
        end

        if (handrupt) begin
            pending_rupts[4] <= 1'b1;
        end else if ((state == COMPLETE) && (tcf_rupt == `TCF_HANDRUPT)) begin
            pending_rupts[4] <= 1'b0;
        end
    end
end

reg [16:1] tcf_rupt;
reg tcf_monpar;
always @(*) begin
    if (pending_rupts[0]) begin
        tcf_rupt = `TCF_KEYRUPT1;
        tcf_monpar = 1'b1;
    end else if (pending_rupts[1]) begin
        tcf_rupt = `TCF_KEYRUPT2;
        tcf_monpar = 1'b1;
    end else if (pending_rupts[2]) begin
        tcf_rupt = `TCF_UPRUPT;
        tcf_monpar = 1'b0;
    end else if (pending_rupts[3]) begin
        tcf_rupt = `TCF_DOWNRUPT;
        tcf_monpar = 1'b0;
    end else if (pending_rupts[4]) begin
        tcf_rupt = `TCF_HANDRUPT;
        tcf_monpar = 1'b1;
    end else begin
        tcf_rupt = 16'b0;
        tcf_monpar = 1'b0;
    end
end

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
            mdt = tcf_rupt;
            monpar = tcf_monpar;
        end
        if (mt[5]) begin
            mdt = 16'o177777;
        end
    end
    endcase
end

always @(*) begin
    next_state = state;
    if (mgojam) begin
        next_state = IDLE;
    end else begin
        case (state)
        IDLE: begin
            if (pending_rupts != 5'b0) begin
                next_state = WAIT_FOR_RSM;
            end
        end

        WAIT_FOR_RSM: begin
            if (miip & mt[8] & mrgg & ~mwbg & (mwl == `RESUME)) begin
                next_state = BREAK_RSM;
            end
        end

        BREAK_RSM: begin
            if (~mt[8]) begin
                next_state = WAIT_FOR_NDX1;
            end
        end

        WAIT_FOR_NDX1: begin
            if (mst == 3'd1 & mt[1]) begin
                if (~msqext & (sq == 6'o50)) begin
                    next_state = FORCE_TCF;
                end else begin
                    next_state = WAIT_FOR_RSM;
                end
            end
        end

        FORCE_TCF: begin
            if (mt[10]) begin
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

endmodule
`default_nettype wire
