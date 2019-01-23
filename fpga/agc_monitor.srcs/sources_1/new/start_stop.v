`timescale 1ns / 1ps
`default_nettype none


module start_stop(
    input wire clk,
    input wire rst_n,
    input wire start_req,
    input wire proceed_req,
    input wire [10:0] stop_conds,
    output reg [10:0] stop_cause,
    input wire mt01,
    input wire mt12,
    input wire mgojam,
    input wire mnisq,
    output reg mstrt,
    output wire mstp,

    input wire [12:1] s,
    input wire [11:9] eb,
    input wire [15:11] fb,
    input wire [7:5] fext,

    input wire [12:1] s1_s,
    input wire [11:9] s1_eb,
    input wire [15:11] s1_fb,
    input wire [7:5] s1_fext,

    input wire [12:1] s1_s_ign,
    input wire [11:9] s1_eb_ign,
    input wire [15:11] s1_fb_ign,
    input wire [7:5] s1_fext_ign,

    input wire [12:1] s2_s,
    input wire [11:9] s2_eb,
    input wire [15:11] s2_fb,
    input wire [7:5] s2_fext,

    input wire [12:1] s2_s_ign,
    input wire [11:9] s2_eb_ign,
    input wire [15:11] s2_fb_ign,
    input wire [7:5] s2_fext_ign
);

`define STOP_T12  0
`define STOP_NISQ 1
`define STOP_S1   2
`define STOP_S2   3

wire s1_s_match;
wire s1_eb_match;
wire s1_fb_match;
wire s1_fext_match;
wire s1_match;
assign s1_s_match = ((s1_s ^ s) & ~s1_s_ign) == 12'b0;
assign s1_eb_match = ((s1_eb ^ eb) & ~s1_eb_ign) == 3'b0;
assign s1_fb_match = ((s1_fb ^ fb) & ~s1_fb_ign) == 5'b0;
assign s1_fext_match = ((s1_fext ^ fext) & ~s1_fext_ign) == 3'b0;
assign s1_match = s1_s_match & s1_eb_match & s1_fb_match & s1_fext_match;

wire s2_s_match;
wire s2_eb_match;
wire s2_fb_match;
wire s2_fext_match;
wire s2_match;
assign s2_s_match = ((s2_s ^ s) & ~s2_s_ign) == 12'b0;
assign s2_eb_match = ((s2_eb ^ eb) & ~s2_eb_ign) == 3'b0;
assign s2_fb_match = ((s2_fb ^ fb) & ~s2_fb_ign) == 5'b0;
assign s2_fext_match = ((s2_fext ^ fext) & ~s2_fext_ign) == 3'b0;
assign s2_match = s2_s_match & s2_eb_match & s2_fb_match & s2_fext_match;

assign mstp = (stop_cause != 11'b0);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mstrt <= 1'b0;
    end else begin
        if (start_req) begin
            mstrt <= 1'b1;
        end else if (mstrt & mgojam) begin
            mstrt <= 1'b0;
        end
    end
end

reg proceeding;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        stop_cause <= 11'b0;
        proceeding <= 1'b0;
    end else begin
        if (proceed_req) begin
            stop_cause <= 11'b0;
            proceeding <= 1'b1;
        end else if (proceeding) begin
            if (mt01) begin
                proceeding <= 1'b0;
            end
        end else begin
            if (stop_conds[`STOP_T12] & mt12) begin
                stop_cause[`STOP_T12] = 1'b1;
            end

            if (stop_conds[`STOP_NISQ] & mnisq) begin
                stop_cause[`STOP_NISQ] = 1'b1;
            end

            if (stop_conds[`STOP_S1] & s1_match) begin
                stop_cause[`STOP_S1] = 1'b1;
            end

            if (stop_conds[`STOP_S2] & s2_match) begin
                stop_cause[`STOP_S2] = 1'b1;
            end
        end
    end
end


endmodule
`default_nettype wire
