`timescale 1ns/1ps
`default_nettype none

`define FIXED_BASE_ADDR 12'o2000

module crs(
    input wire clk,
    input wire rst_n,

    input wire read_en,
    input wire write_en,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    output wire [15:0] data_out,

    input wire force_uprupt,
    input wire [16:1] t3rupt_rsm_faddr,
    input wire [16:1] t4rupt_rsm_faddr,
    input wire enable,

    input wire [12:1] mt,
    input wire [12:1] s,
    input wire [16:1] faddr,
    input wire mrsc,
    input wire mwg,

    output wire mnhsbf,
    output wire [16:1] mdt,
    output wire monpar
);

// Fixed memory simulation
localparam IDLE = 1'd0,
           ACTIVE = 1'd1;

reg state;
reg next_state;


reg [16:1] fixed_word;
reg [16:1] fixed_word_q;

assign mnhsbf = (state != IDLE);

wire write_data;
assign write_data = (mnhsbf & mrsc & mwg);

assign mdt = (write_data) ?  {fixed_word[16], fixed_word[16], fixed_word[14:1]} : 16'o0;
assign monpar = (write_data) ?  fixed_word[15] : 16'o0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
        fixed_word <= 16'b0;
    end else begin
        state <= next_state;
        fixed_word <= fixed_word_q;
    end else begin
    end
end

always @(*)
    next_state = mt[7] ? IDLE : state;
    if (force_uprupt & ((faddr == t3rupt_rsm_faddr) | (faddr == t4rupt_rsm_faddr))) begin
        fixed_word_q = `TCF_UPRUPT;
        next_state = ACTIVE;
    end else if (enable && (mt[2] && (s >= `FIXED_BASE_ADDR)) begin
        fixed_word_q = data;
        next_state = ACTIVE;
    end
end

endmodule
`default_nettype wire
