`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module control_regs(
    input wire clk,
    input wire rst_n,
    input wire [15:0] addr,
    input wire [15:0] data_in,

    input wire bplssw_p,
    input wire bplssw_n,
    input wire p4sw_p,
    input wire p4sw_n,
    input wire mtemp_p,
    input wire mtemp_n,

    input wire read_en,
    input wire write_en,
    output wire [15:0] data_out,
    output reg start_req,
    output reg proceed_req,
    output reg [10:0] stop_conds,
    output reg stop_s1_s2,
    input wire [10:0] stop_cause,
    output reg mnhrpt,
    output reg mnhnc,
    output reg nhalga,

    input wire [12:1] s,
    input wire [11:9] eb,
    input wire [15:11] fb,
    input wire [7:5] fext,
    input wire minkl,
    input wire minhl,
    input wire miip,

    input wire [16:1] w,
    input wire [1:0] wp,
    input wire [12:1] i,

    output wire s1_match,
    output wire s2_match,
    output wire w_match,
    output wire i_match,

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

reg [16:1] w_comp_val;
reg [16:1] w_comp_val_ign;
reg [1:0] w_comp_par;
reg [1:0] w_comp_par_ign;

wire w_val_match;
wire w_par_match;
assign w_val_match = ((w ^ w_comp_val) & ~w_comp_val_ign) == 16'b0;
assign w_par_match = ((wp ^ w_comp_par) & ~w_comp_par_ign) == 2'b0;
assign w_match = w_val_match & w_par_match;

reg [12:1] i_comp_val;
reg [12:1] i_comp_val_ign;
reg [6:0] i_comp_stat;
reg [6:0] i_comp_stat_ign;

wire [6:0] stat;
assign stat = {1'b0, 1'b0, 1'b0, 1'b0, minkl, minhl, miip}; // FIXME: Add LD/RD status bits

wire i_val_match;
wire i_stat_match;
assign i_val_match = ((i ^ i_comp_val) & ~i_comp_val_ign) == 12'b0;
assign i_stat_match = ((stat ^ i_comp_stat) & ~i_comp_stat_ign) == 7'b0;
assign i_match = i_val_match & i_stat_match;


wire [4:0] adc_channel;
wire [6:0] adc_daddr;
assign adc_daddr = {2'b0, adc_channel};
wire adc_eoc;
wire [15:0] adc_do;
wire adc_drdy;

mon_adc adc(
    .daddr_in(adc_daddr),
    .dclk_in(clk),
    .den_in(adc_eoc),
    .di_in(16'b0),
    .dwe_in(1'b0),
    .reset_in(~rst_n),
    .vauxp7(p4sw_p),
    .vauxn7(p4sw_n),
    .vauxp14(mtemp_p),
    .vauxn14(mtemp_n),
    .vauxp15(bplssw_p),
    .vauxn15(bplssw_n),
    .busy_out(),
    .channel_out(adc_channel),
    .do_out(adc_do),
    .drdy_out(adc_drdy),
    .eoc_out(adc_eoc),
    .eos_out(),
    .alarm_out(),
    .vp_in(1'b0),
    .vn_in(1'b0)
);

reg [15:0] adc_temp;
reg [15:0] adc_vccint;
reg [15:0] adc_vccaux;
reg [15:0] adc_bplssw;
reg [15:0] adc_p4sw;
reg [15:0] adc_mtemp;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        adc_temp <= 16'b0;
        adc_vccint <= 16'b0;
        adc_vccaux <= 16'b0;
        adc_bplssw <= 16'b0;
        adc_p4sw <= 16'b0;
        adc_mtemp <= 16'b0;
    end else if (adc_drdy) begin
        case (adc_channel)
        `ADC_CHAN_TEMP:   adc_temp <= adc_do;
        `ADC_CHAN_VCCINT: adc_vccint <= adc_do;
        `ADC_CHAN_VCCAUX: adc_vccaux <= adc_do;
        `ADC_CHAN_VAUX7:  adc_p4sw <= adc_do;
        `ADC_CHAN_VAUX14: adc_mtemp <= adc_do;
        `ADC_CHAN_VAUX15: adc_bplssw <= adc_do;
        endcase
    end
end

reg [15:0] read_data;
reg read_done;

assign data_out = read_done ? read_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        proceed_req <= 1'b0;
        start_req <= 1'b0;
        stop_conds <= 11'b0;
        stop_s1_s2 <= 1'b0;
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

        w_comp_val <= 16'b0;
        w_comp_val_ign <= 16'b0;
        w_comp_par <= 2'b0;
        w_comp_par_ign <= 2'b0;

        i_comp_val <= 12'b0;
        i_comp_val_ign <= 12'b0;
        i_comp_stat <= 7'b0;
        i_comp_stat_ign <= 7'b0;

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
            `CTRL_REG_STOP: begin
                stop_conds <= data_in[10:0];
                stop_s1_s2 <= data_in[11];
            end
            `CTRL_REG_PROCEED:  proceed_req <= 1'b1;
            `CTRL_REG_MNHRPT:   mnhrpt <= data_in[0];
            `CTRL_REG_MNHNC:    mnhnc <= data_in[0];
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
            `CTRL_REG_W_COMP_VAL: w_comp_val <= data_in;
            `CTRL_REG_W_COMP_IGN:  w_comp_val_ign <= data_in;
            `CTRL_REG_W_COMP_PAR: begin
                w_comp_par <= data_in[1:0];
                w_comp_par_ign <= data_in[3:2];
            end
            `CTRL_REG_I_COMP_VAL: i_comp_val <= data_in[11:0];
            `CTRL_REG_I_COMP_IGN: i_comp_val_ign <= data_in[11:0];
            `CTRL_REG_I_COMP_STAT: begin
                i_comp_stat <= data_in[6:0];
                i_comp_stat_ign <= data_in[13:7];
            end
            `CTRL_REG_NHALGA:   nhalga <= data_in[0];

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
        `CTRL_REG_STOP:         read_data <= {4'b0, stop_s1_s2, stop_conds};
        `CTRL_REG_STOP_CAUSE:   read_data <= {5'b0, stop_cause};
        `CTRL_REG_MNHRPT:       read_data <= {15'b0, mnhrpt};
        `CTRL_REG_MNHNC:        read_data <= {15'b0, mnhnc};
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
        `CTRL_REG_W_COMP_VAL:   read_data <= w_comp_val;
        `CTRL_REG_W_COMP_IGN:   read_data <= w_comp_val_ign;
        `CTRL_REG_W_COMP_PAR:   read_data <= {12'b0, w_comp_par_ign, w_comp_par};
        `CTRL_REG_I_COMP_VAL:   read_data <= {4'b0, i_comp_val};
        `CTRL_REG_I_COMP_IGN:   read_data <= {4'b0, i_comp_val_ign};
        `CTRL_REG_I_COMP_STAT:  read_data <= {2'b0, i_comp_stat_ign, i_comp_stat};
        `CTRL_REG_NHALGA:       read_data <= {15'b0, nhalga};
        `CTRL_REG_MON_TEMP:     read_data <= adc_temp;
        `CTRL_REG_MON_VCCINT:   read_data <= adc_vccint;
        `CTRL_REG_MON_VCCAUX:   read_data <= adc_vccaux;
        `CTRL_REG_AGC_BPLSSW:   read_data <= adc_bplssw;
        `CTRL_REG_AGC_P4SW:     read_data <= adc_p4sw;
        `CTRL_REG_AGC_MTEMP:    read_data <= adc_mtemp;
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
