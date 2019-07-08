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
    output reg write_done,
    output wire [15:0] data_out,
    output reg start_req,
    output reg proceed_req,
    output reg [10:0] stop_conds,
    output reg stop_s1_s2,
    input wire [10:0] stop_cause,
    output reg mnhrpt,
    output reg mnhnc,
    output reg nhalga,
    output reg nhstrt1,
    output reg nhstrt2,
    output reg doscal,
    output reg dbltst,

    output reg downrupt,
    output reg handrupt,

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
    output reg [11:0] w_pulses,

    output reg s_only,
    output reg adv_s,
    output reg periph_load,
    output reg periph_read,
    output reg periph_loadch,
    output reg periph_readch,
    output reg periph_tcsaj,
    output reg [12:1] periph_s,
    output reg [15:1] periph_bb,
    output reg [16:1] periph_data,
    input wire periph_complete,

    output reg [63:0] crs_bank_en,
    output reg [7:0] ems_bank_en
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

reg [4:0] ldrd_s1_s2;
wire [12:1] load_preset_s;
wire [12:1] load_chan_s;
wire [12:1] read_preset_s;
wire [12:1] read_chan_s;
wire [12:1] start_preset_s;
wire [15:1] read_preset_bb;
wire [15:1] load_preset_bb;

assign load_preset_s = ldrd_s1_s2[0] ? s2_s : s1_s;
assign load_preset_bb = ldrd_s1_s2[0] ? {s2_fb, 7'b0, s2_eb} : {s1_fb, 7'b0, s1_eb};
assign load_chan_s = ldrd_s1_s2[1] ? s2_s : s1_s;
assign read_preset_s = ldrd_s1_s2[2] ? s2_s : s1_s;
assign read_preset_bb = ldrd_s1_s2[2] ? {s2_fb, 7'b0, s2_eb} : {s1_fb, 7'b0, s1_eb};
assign read_chan_s = ldrd_s1_s2[3] ? s2_s : s1_s;
assign start_preset_s = ldrd_s1_s2[4] ? s2_s : s1_s;

reg [15:0] read_data;
reg read_done;

assign data_out = read_done ? read_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        write_done <= 1'b0;
        proceed_req <= 1'b0;
        start_req <= 1'b0;
        stop_conds <= 11'b0;
        stop_s1_s2 <= 1'b0;
        mnhrpt <= 1'b0;
        mnhnc <= 1'b0;
        nhalga <= 1'b0;
        nhstrt1 <= 1'b0;
        nhstrt2 <= 1'b0;
        doscal <= 1'b0;
        dbltst <= 1'b0;
        downrupt <= 1'b0;
        handrupt <= 1'b0;

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

        s_only <= 1'b0;
        adv_s <= 1'b0;
        ldrd_s1_s2 <= 5'b0;
        periph_load <= 1'b0;
        periph_loadch <= 1'b0;
        periph_read <= 1'b0;
        periph_readch <= 1'b0;
        periph_tcsaj <= 1'b0;
        periph_s <= 12'b0;
        periph_bb <= 15'b0;
        periph_data <= 16'b0;

        crs_bank_en <= 64'b0;
        ems_bank_en <= 8'b0;
    end else begin
        write_done <= 1'b0;
        start_req <= 1'b0;
        adv_s <= 1'b0;
        proceed_req <= 1'b0;
        periph_load <= 1'b0;
        periph_loadch <= 1'b0;
        periph_read <= 1'b0;
        periph_readch <= 1'b0;
        periph_tcsaj <= 1'b0;
        periph_s <= 12'b0;
        periph_bb <= 15'b0;
        periph_data <= 16'b0;
        downrupt <= 1'b0;
        handrupt <= 1'b0;

        if (write_en) begin
            if (addr < `CTRL_REG_LOAD_S) begin
                write_done <= 1'b1;
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
                `CTRL_REG_NHSTRT1:  nhstrt1 <= data_in[0];
                `CTRL_REG_NHSTRT2:  nhstrt2 <= data_in[0];
                `CTRL_REG_DOSCAL:   doscal <= data_in[0];
                `CTRL_REG_DBLTST:   dbltst <= data_in[0];
                `CTRL_REG_LDRD_S1_S2: ldrd_s1_s2 <= data_in[4:0];
                `CTRL_REG_BANK_S: s_only <= data_in[0];
                `CTRL_REG_ADVANCE_S: adv_s <= 1'b1;
                `CTRL_REG_CRS_BANK_EN0: crs_bank_en[15:0] <= data_in;
                `CTRL_REG_CRS_BANK_EN1: crs_bank_en[31:16] <= data_in;
                `CTRL_REG_CRS_BANK_EN2: crs_bank_en[47:32] <= data_in;
                `CTRL_REG_CRS_BANK_EN3: crs_bank_en[63:48] <= data_in;
                `CTRL_REG_EMS_BANK_EN: ems_bank_en <= data_in[7:0];
                `CTRL_REG_DOWNRUPT: downrupt <= 1'b1;
                `CTRL_REG_HANDRUPT: handrupt <= 1'b1;
                endcase
            end else begin
                if (periph_complete) begin
                    write_done <= 1'b1;
                end else begin
                    case (addr)
                    `CTRL_REG_LOAD_S: begin
                        periph_load <= 1'b1;
                        periph_bb <= {fb, 7'b0, eb};
                        periph_s <= s;
                        periph_data <= w;
                    end
                    `CTRL_REG_LOAD_PRESET: begin
                        periph_load <= 1'b1;
                        periph_bb <= load_preset_bb;
                        periph_s <= load_preset_s;
                        periph_data <= w_comp_val;
                    end
                    `CTRL_REG_LOAD_CHAN: begin
                        periph_loadch <= 1'b1;
                        periph_s <= load_chan_s;
                        periph_data <= w_comp_val;
                    end
                    `CTRL_REG_READ_S: begin
                        periph_read <= 1'b1;
                        periph_bb <= {fb, 7'b0, eb};
                        periph_s <= s;
                    end
                    `CTRL_REG_READ_PRESET: begin
                        periph_read <= 1'b1;
                        periph_bb <= read_preset_bb;
                        periph_s <= read_preset_s;
                        periph_data <= w;
                    end
                    `CTRL_REG_READ_CHAN: begin
                        periph_readch <= 1'b1;
                        periph_s <= read_chan_s;
                        periph_data <= w;
                    end
                    `CTRL_REG_START_S: begin
                        periph_tcsaj <= 1'b1;
                        periph_s <= s;
                    end
                    `CTRL_REG_START_PRESET: begin
                        periph_tcsaj <= 1'b1;
                        periph_s <= start_preset_s;
                    end
                    endcase
                end
            end
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
        `CTRL_REG_NHSTRT1:      read_data <= {15'b0, nhstrt1};
        `CTRL_REG_NHSTRT2:      read_data <= {15'b0, nhstrt2};
        `CTRL_REG_DOSCAL:       read_data <= {15'b0, doscal};
        `CTRL_REG_DBLTST:       read_data <= {15'b0, dbltst};
        `CTRL_REG_LDRD_S1_S2:   read_data <= {11'b0, ldrd_s1_s2};
        `CTRL_REG_BANK_S:       read_data <= {15'b0, s_only};
        `CTRL_REG_CRS_BANK_EN0: read_data <= crs_bank_en[15:0];
        `CTRL_REG_CRS_BANK_EN1: read_data <= crs_bank_en[31:16];
        `CTRL_REG_CRS_BANK_EN2: read_data <= crs_bank_en[47:32];
        `CTRL_REG_CRS_BANK_EN3: read_data <= crs_bank_en[63:48];
        `CTRL_REG_EMS_BANK_EN:  read_data <= {8'b0, ems_bank_en};
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
