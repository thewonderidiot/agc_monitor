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
    output wire [15:0] data_out,

    input wire [63:0] bank_en,
    input wire mnhsbf_dsky,

    input wire [7:5] fext,
    input wire [15:11] fb,
    input wire [12:1] s,

    input wire mt02,
    input wire mt04,
    input wire mt07,
    input wire mrsc,
    input wire mwg,

    output reg mnhsbf,
    output wire [16:1] mdt,
    output wire monpar,

    input wire mrgg,
    input wire [16:1] g,
    output wire mismatch,
    output reg [16:1] mismatch_faddr,
    output reg [16:1] mismatch_data
);

wire [16:1] faddr;
fixed_addr_decoder fixed_addr(
    .fext(fext),
    .fb(fb),
    .s(s),
    .faddr(faddr)
);

wire rope_mem_en;
assign rope_mem_en = read_en | write_en;
wire [15:0] rope_mem_data;
wire [16:1] fixed_data;

rope_sim_mem rope_mem(
    .clka(clk),
    .ena(rope_mem_en),
    .wea(write_en),
    .addra(addr),
    .dina(data_in),
    .douta(rope_mem_data),

    .clkb(clk),
    .web(1'b0),
    .addrb(faddr),
    .dinb(16'b0),
    .doutb(fixed_data)
);

wire wagc;
assign wagc = mnhsbf & mrsc & mwg;

reg [16:1] mon_word;
assign mdt = wagc ? {mon_word[16], mon_word[16:2]} : 16'b0;
assign monpar = wagc ? mon_word[1] : 1'b0;

wire [5:0] bank;
assign bank = faddr[16:11];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mnhsbf <= 1'b0;
        mon_word <= 16'b0;
    end else begin
        case (mnhsbf)
        1'b0: begin
            if (mt02 & (s >= `FIXED_BASE_ADDR) & bank_en[bank] & ~mnhsbf_dsky) begin
                mnhsbf <= 1'b1;
                mon_word <= fixed_data;
            end
        end

        1'b1: begin
            if (mt07) begin
                mnhsbf <= 1'b0;
            end
        end
        endcase
    end
end

reg [3:0] mismatch_timer;
assign mismatch = mismatch_timer != 0;
reg [16:1] shadow_word;
reg [16:1] shadow_addr;
reg shadow_active;
reg shadow_fixed;

reg mrgg_r;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mrgg_r <= 1'b0;
    end else begin
        mrgg_r <= mrgg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        shadow_fixed <= 1'b0;
        shadow_word <= 16'b0;
        shadow_addr <= 16'b0;
    end else begin
        if (mt02) begin
            if (s >= `FIXED_BASE_ADDR) begin
                shadow_fixed <= 1'b1;
                shadow_word <= fixed_data;
                shadow_addr <= faddr;
            end else begin
                shadow_fixed <= 1'b0;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        shadow_active <= 1'b0;
    end else begin
        if (mwg) begin
            shadow_active <= 1'b0;
        end else begin
            if (shadow_fixed) begin
                if (mt07) begin
                    shadow_active <= 1'b1;
                end
            end else begin
                if (mt04) begin
                    shadow_active <= 1'b0;
                end
            end
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mismatch_timer <= 4'b0;
        mismatch_faddr <= 16'b0;
        mismatch_data <= 16'b0;
    end else begin
        if (mismatch_timer > 4'b0) begin
            mismatch_timer <= mismatch_timer - 1;
        end

        if (shadow_active & mrgg_r & ~mrgg) begin
            if (g != {shadow_word[16],shadow_word[16:2]}) begin
                mismatch_timer <= 4'hF;
                mismatch_faddr <= shadow_addr;
                mismatch_data <= g;
            end
        end
    end
end


reg read_done;
assign data_out = read_done ? rope_mem_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_done <= 1'b0;
    end else begin
        read_done <= read_en;
    end
end

endmodule
`default_nettype wire
