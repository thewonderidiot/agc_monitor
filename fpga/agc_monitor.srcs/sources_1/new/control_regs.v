`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module control_regs(
    input wire clk,
    input wire rst_n,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    input wire read_en,
    input wire write_en,
    output wire [15:0] data_out,
    output reg start_req,
    output reg proceed_req,
    output reg [10:0] stop_conds,
    input wire [10:0] stop_cause,
    output reg mnhrpt,
    output reg mnhnc,
    output reg nhalga
);

reg [15:0] read_data;
reg read_done;

assign data_out = read_done ? read_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        proceed_req <= 1'b0;
        start_req <= 1'b0;
        stop_conds <= 11'b0;
        mnhrpt <= 1'b0;
        mnhnc <= 1'b0;
        nhalga <= 1'b0;
    end else begin
        start_req <= 1'b0;
        proceed_req <= 1'b0;

        if (write_en) begin
            case (addr)
            `CTRL_REG_START:   start_req <= 1'b1;
            `CTRL_REG_STOP:    stop_conds <= data_in[10:0];
            `CTRL_REG_PROCEED: proceed_req <= 1'b1;
            `CTRL_REG_MNHRPT:  mnhrpt <= data_in[0];
            `CTRL_REG_MNHNC:   mnhnc <= data_in[0];
            `CTRL_REG_NHALGA:  nhalga <= data_in[0];
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_data <= 16'b0;
        read_done <= 1'b0;
    end else if (read_en) begin
        read_done <= 1'b1;
        case (addr)
        `CTRL_REG_STOP:       read_data <= {5'b0, stop_conds};
        `CTRL_REG_STOP_CAUSE: read_data <= {5'b0, stop_cause};
        `CTRL_REG_MNHRPT:     read_data <= {15'b0, mnhrpt};
        `CTRL_REG_MNHNC:      read_data <= {15'b0, mnhnc};
        `CTRL_REG_NHALGA:     read_data <= {15'b0, nhalga};
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
