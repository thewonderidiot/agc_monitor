`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module edit(
    input wire clk,
    input wire rst_n,
    input wire mt02,
    input wire [12:1] s,
    input wire [16:1] mwl,
    output reg [16:1] mwl_edited
);

reg [12:1] s_mct;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        s_mct <= 12'b0;
    end else if (mt02) begin
        s_mct <= s;
    end
end

always @(*) begin
    case (s_mct)
    `CYR:    mwl_edited = {mwl[1], mwl[1], mwl[16], mwl[14:2]};
    `SR:     mwl_edited = {mwl[16], mwl[16], mwl[16], mwl[14:2]};
    `CYL:    mwl_edited = {mwl[14], mwl[14:1], mwl[16]};
    `EDOP:   mwl_edited = {9'o0, mwl[14:8]};
    default: mwl_edited = mwl;
    endcase
end

endmodule
`default_nettype wire
