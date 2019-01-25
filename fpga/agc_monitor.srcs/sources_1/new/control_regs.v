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
    output reg nhalga,

    input wire [12:1] s,
    input wire [11:9] eb,
    input wire [15:11] fb,
    input wire [7:5] fext,

    output wire s1_match,
    output wire s2_match,

    output reg [2:0] w_mode,
    output reg w_s1_s2,
    output reg [12:1] w_times,
    output reg [11:0] w_pulses
);

reg [12:1] s1_s;
reg [11:9] s1_eb;
reg [15:11] s1_fb;
reg [7:5] s1_fext;

reg [12:1] s1_s_ign;
reg [11:9] s1_eb_ign;
reg [15:11] s1_fb_ign;
reg [7:5] s1_fext_ign;

reg [12:1] s2_s;
reg [11:9] s2_eb;
reg [15:11] s2_fb;
reg [7:5] s2_fext;

reg [12:1] s2_s_ign;
reg [11:9] s2_eb_ign;
reg [15:11] s2_fb_ign;
reg [7:5] s2_fext_ign;

wire s1_s_match;
wire s1_eb_match;
wire s1_fb_match;
wire s1_fext_match;
assign s1_s_match = ((s1_s ^ s) & ~s1_s_ign) == 12'b0;
assign s1_eb_match = ((s1_eb ^ eb) & ~s1_eb_ign) == 3'b0;
assign s1_fb_match = ((s1_fb ^ fb) & ~s1_fb_ign) == 5'b0;
assign s1_fext_match = ((s1_fext ^ fext) & ~s1_fext_ign) == 3'b0;
assign s1_match = s1_s_match & s1_eb_match & s1_fb_match & s1_fext_match;

wire s2_s_match;
wire s2_eb_match;
wire s2_fb_match;
wire s2_fext_match;
assign s2_s_match = ((s2_s ^ s) & ~s2_s_ign) == 12'b0;
assign s2_eb_match = ((s2_eb ^ eb) & ~s2_eb_ign) == 3'b0;
assign s2_fb_match = ((s2_fb ^ fb) & ~s2_fb_ign) == 5'b0;
assign s2_fext_match = ((s2_fext ^ fext) & ~s2_fext_ign) == 3'b0;
assign s2_match = s2_s_match & s2_eb_match & s2_fb_match & s2_fext_match;

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

        s1_s <= 12'b0;
        s1_eb <= 3'b0;
        s1_fb <= 5'b0;
        s1_fext <= 3'b0;
        s1_s_ign <= 12'b0;
        s1_eb_ign <= 3'b0;
        s1_fb_ign <= 5'b0;
        s1_fext_ign <= 3'b0;
        s2_s <= 12'b0;
        s2_eb <= 3'b0;
        s2_fb <= 5'b0;
        s2_fext <= 3'b0;
        s2_s_ign <= 12'b0;
        s2_eb_ign <= 3'b0;
        s2_fb_ign <= 5'b0;
        s2_fext_ign <= 3'b0;

        w_mode <= `W_MODE_ALL;
        w_s1_s2 <= 1'b0;
        w_times <= 12'b0;
        w_pulses <= 12'b0;
    end else begin
        start_req <= 1'b0;
        proceed_req <= 1'b0;

        if (write_en) begin
            case (addr)
            `CTRL_REG_START:    start_req <= 1'b1;
            `CTRL_REG_STOP:     stop_conds <= data_in[10:0];
            `CTRL_REG_PROCEED:  proceed_req <= 1'b1;
            `CTRL_REG_MNHRPT:   mnhrpt <= data_in[0];
            `CTRL_REG_MNHNC:    mnhnc <= data_in[0];
            `CTRL_REG_NHALGA:   nhalga <= data_in[0];
            `CTRL_REG_S1_S:     s1_s <= data_in[11:0];
            `CTRL_REG_S1_BANK: begin
                s1_eb <= data_in[2:0];
                s1_fext <= data_in[6:4];
                s1_fb <= data_in[14:10];
            end
            `CTRL_REG_S1_S_IGN: s1_s_ign <= data_in[11:0];
            `CTRL_REG_S1_BANK_IGN: begin
                s1_eb_ign <= data_in[2:0];
                s1_fext_ign <= data_in[6:4];
                s1_fb_ign <= data_in[14:10];
            end
            `CTRL_REG_S2_S:     s2_s <= data_in[11:0];
            `CTRL_REG_S2_BANK: begin
                s2_eb <= data_in[2:0];
                s2_fext <= data_in[6:4];
                s2_fb <= data_in[14:10];
            end
            `CTRL_REG_S2_S_IGN: s2_s_ign <= data_in[11:0];
            `CTRL_REG_S2_BANK_IGN: begin
                s2_eb_ign <= data_in[2:0];
                s2_fext_ign <= data_in[6:4];
                s2_fb_ign <= data_in[14:10];
            end
            `CTRL_REG_WRITE_W: begin
                w_mode <= data_in[2:0];
                w_s1_s2 <= data_in[3];
            end
            `CTRL_REG_W_TIMES:  w_times <= data_in[11:0];
            `CTRL_REG_W_PULSES: w_pulses <= data_in[11:0];

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
        `CTRL_REG_STOP:         read_data <= {5'b0, stop_conds};
        `CTRL_REG_STOP_CAUSE:   read_data <= {5'b0, stop_cause};
        `CTRL_REG_MNHRPT:       read_data <= {15'b0, mnhrpt};
        `CTRL_REG_MNHNC:        read_data <= {15'b0, mnhnc};
        `CTRL_REG_NHALGA:       read_data <= {15'b0, nhalga};
        `CTRL_REG_S1_S:         read_data <= {4'b0, s1_s};
        `CTRL_REG_S1_BANK:      read_data <= {1'b0, s1_fb, 3'b0, s1_fext, 1'b0, s1_eb};
        `CTRL_REG_S1_S_IGN:     read_data <= {4'b0, s1_s_ign};
        `CTRL_REG_S1_BANK_IGN:  read_data <= {1'b0, s1_fb_ign, 3'b0, s1_fext_ign, 1'b0, s1_eb_ign};
        `CTRL_REG_S2_S:         read_data <= {4'b0, s2_s};
        `CTRL_REG_S2_BANK:      read_data <= {1'b0, s2_fb, 3'b0, s2_fext, 1'b0, s2_eb};
        `CTRL_REG_S2_S_IGN:     read_data <= {4'b0, s2_s_ign};
        `CTRL_REG_S2_BANK_IGN:  read_data <= {1'b0, s2_fb_ign, 3'b0, s2_fext_ign, 1'b0, s2_eb_ign};
        `CTRL_REG_WRITE_W:      read_data <= {12'b0, w_s1_s2, w_mode};
        `CTRL_REG_W_TIMES:      read_data <= {4'b0, w_times};
        `CTRL_REG_W_PULSES:     read_data <= {4'b0, w_pulses};
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
