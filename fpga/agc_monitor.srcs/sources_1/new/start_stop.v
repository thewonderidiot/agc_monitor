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
    output wire mstp
);

`define STOP_T12  0
`define STOP_NISQ 1

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
        end
    end
end


endmodule
`default_nettype wire
