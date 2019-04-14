`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module unedit(
    input wire [12:1] s,
    input wire [16:1] mwl,
    output reg [16:1] unedited
);

always @(*) begin
    case (s)
    `CYR:    unedited = {mwl[14], mwl[14:1], mwl[16]};
    `SR:     unedited = {mwl[16], mwl[16], mwl[13:1], 1'b0};
    `CYL:    unedited = {mwl[1], mwl[1], mwl[16], mwl[14:2]};
    `EDOP:   unedited = {2'b0, mwl[7:1], 7'b0};
    default: unedited = mwl;
    endcase
end

endmodule
`default_nettype wire
