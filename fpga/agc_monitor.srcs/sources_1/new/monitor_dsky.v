`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module monitor_dsky(
    input wire clk,
    input wire rst_n,
    input wire [15:0] addr,
    input wire read_en,
    output wire [15:0] data_out,

    input wire [15:1] out0
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

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        prog <= 10'b0;
        verb <= 10'b0;
        noun <= 10'b0;
        reg1 <= 27'b0;
        reg2 <= 27'b0;
        reg3 <= 27'b0;
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

                endcase
            end
        end else begin
            rywd_timer <= `RYWD_5MS_COUNT;
        end
        rywd_p <= rywd;
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
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
