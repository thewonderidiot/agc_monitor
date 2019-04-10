`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module core_rope_sim(
    input wire clk,
    input wire rst_n,

    input wire read_en,
    input wire write_en,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    output wire [15:0] data_out
);

wire rope_mem_en;
assign rope_mem_en = read_en | write_en;
wire [15:0] rope_data;

rope_sim_mem rope_mem(
    .clka(clk),
    .ena(rope_mem_en),
    .wea(write_en),
    .addra(addr),
    .dina(data_in),
    .douta(rope_data),

    .clkb(clk),
    .web(1'b0),
    .addrb(16'b0),
    .dinb(16'b0),
    .doutb()
);

reg read_done;
assign data_out = read_done ? rope_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_done <= 1'b0;
    end else begin
        read_done <= read_en;
    end
end


/* always @(posedge clk or negedge rst_n) begin */
/*     if (~rst_n) begin */
/*     end else begin */
/*     end */
/* end */

endmodule
`default_nettype wire
