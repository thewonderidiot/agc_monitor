`timescale 1ns / 1ps
`default_nettype none

module agc_monitor(
    input wire clk,
    input wire rst_n,

    // FT232 FIFO interface
    input wire clkout,
    inout wire [7:0] data,
    input wire rxf_n,
    input wire txe_n,
    output wire rd_n,
    output wire wr_n,
    output wire oe_n,
    output wire siwu,

    // AGC signals
    input wire bplssw_p,
    input wire bplssw_n,
    input wire p4sw_p,
    input wire p4sw_n,
    input wire mtemp_p,
    input wire mtemp_n,

    input wire mgojam,
    input wire mstpit_n,
    input wire monwt,
    input wire [12:1] mt,
    input wire [16:1] mwl,

    input wire miip,
    input wire minhl,
    input wire minkl,

    input wire msqext,
    input wire [15:10] msq,
    input wire [3:1] mst,
    input wire [2:1] mbr,

    input wire mwag,
    input wire mwlg,
    input wire mwqg,
    input wire mwebg,
    input wire mwfbg,
    input wire mwbbeg,
    input wire mwzg,
    input wire mwbg,
    input wire mwsg,
    input wire mwg,
    input wire mwyg,
    input wire mrulog,
    input wire mrgg,
    input wire mrch,
    input wire mwch,
    input wire mnisq,
    input wire msp,
    input wire mgp_n,

    input wire mpal_n,
    input wire mtcal_n,
    input wire mrptal_n,
    input wire mwatch_n,
    input wire mvfail_n,
    input wire mctral_n,
    input wire mscafl_n,
    input wire mscdbl_n,

    output wire mnhsbf,
    output wire [16:1] mdt,
    output wire monpar,

    output wire mstrt,
    output wire mstp,

    output wire mnhrpt,
    output wire mnhnc,
    output wire nhalga,

    output wire mread,
    output wire mload,
    output wire mrdch,
    output wire mldch,
    output wire mtcsai,
    output wire monwbk,
    input wire mreqin,
    input wire mtcsa_n,
    
    // Zynq PS I/O
    inout wire [14:0] DDR_addr,
    inout wire [2:0] DDR_ba,
    inout wire DDR_cas_n,
    inout wire DDR_ck_n,
    inout wire DDR_ck_p,
    inout wire DDR_cke,
    inout wire DDR_cs_n,
    inout wire [3:0] DDR_dm,
    inout wire [31:0] DDR_dq,
    inout wire [3:0] DDR_dqs_n,
    inout wire [3:0] DDR_dqs_p,
    inout wire DDR_odt,
    inout wire DDR_ras_n,
    inout wire DDR_reset_n,
    inout wire DDR_we_n,
    inout wire FIXED_IO_ddr_vrn,
    inout wire FIXED_IO_ddr_vrp,
    inout wire [53:0] FIXED_IO_mio,
    inout wire FIXED_IO_ps_clk,
    inout wire FIXED_IO_ps_porb,
    inout wire FIXED_IO_ps_srstb
);

/*******************************************************************************.
* USB Interface                                                                 *
'*******************************************************************************/
// Incoming command from USB, associated validity flag, and read signal
wire [39:0] cmd;
wire cmd_ready;
wire cmd_read_en;

// Read response message for sending back over USB, and its validity flag
wire [39:0] read_msg;
wire read_msg_ready;

// USB interface
usb_interface usb_if(
    .clk(clk),
    .rst_n(rst_n),
    .clkout(clkout),
    .data(data),
    .rxf_n(rxf_n),
    .txe_n(txe_n),
    .rd_n(rd_n),
    .wr_n(wr_n),
    .oe_n(oe_n),
    .siwu(siwu),
    .cmd(cmd),
    .cmd_ready(cmd_ready),
    .cmd_read_en(cmd_read_en),
    .read_msg(read_msg),
    .read_msg_ready(read_msg_ready)
);

/*******************************************************************************.
* Command Controller                                                            *
'*******************************************************************************/
// Address and (if applicable) data associated with the command currently
// being processed
wire [15:0] cmd_addr;
wire [15:0] cmd_data;

// Control Registers control signals
wire ctrl_read_en;
wire ctrl_write_en;
wire ctrl_write_done;
wire [15:0] ctrl_data;

wire mon_reg_read_en;
wire [15:0] mon_reg_data;

wire mon_chan_read_en;
wire [15:0] mon_chan_data;

wire mon_dsky_read_en;
wire mon_dsky_write_en;
wire [15:0] mon_dsky_data;

// Resulting data from the active read command
wire [15:0] read_data;
assign read_data = ctrl_data | mon_reg_data | mon_chan_data | mon_dsky_data;

// Command controller 
cmd_controller cmd_ctrl(
    .clk(clk),
    .rst_n(rst_n),
    .cmd(cmd),
    .cmd_ready(cmd_ready),
    .cmd_read_en(cmd_read_en),
    .cmd_addr(cmd_addr),
    .cmd_data(cmd_data),
    .read_data(read_data),
    .read_msg(read_msg),
    .read_msg_ready(read_msg_ready),
    .ctrl_read_en(ctrl_read_en),
    .ctrl_write_en(ctrl_write_en),
    .ctrl_write_done(ctrl_write_done),
    .mon_reg_read_en(mon_reg_read_en),
    .mon_chan_read_en(mon_chan_read_en),
    .mon_dsky_read_en(mon_dsky_read_en),
    .mon_dsky_write_en(mon_dsky_write_en)
);

/*******************************************************************************.
* Control Registers                                                             *
'*******************************************************************************/
wire start_req;
wire proceed_req;
wire [10:0] stop_conds;
wire stop_s1_s2;
wire [10:0] stop_cause;

wire [12:1] s;
wire [11:9] eb;
wire [15:11] fb;
wire [7:5] fext;

wire s1_match;
wire s2_match;
wire w_match;
wire i_match;

wire [2:0] w_mode;
wire w_s1_s2;
wire [12:1] w_times;
wire [11:0] w_pulses;

wire [16:1] w;
wire [1:0] wp;

wire [12:1] i;

wire s_only;
wire adv_s;
wire ctrl_periph_load;
wire ctrl_periph_read;
wire ctrl_periph_loadch;
wire ctrl_periph_readch;
wire ctrl_periph_tcsaj;
wire [12:1] ctrl_periph_s;
wire [15:1] ctrl_periph_bb;
wire [16:1] ctrl_periph_data;
wire periph_complete;

control_regs ctrl_regs(
    .clk(clk),
    .rst_n(rst_n),

    .bplssw_p(bplssw_p),
    .bplssw_n(bplssw_n),
    .mtemp_p(mtemp_p),
    .mtemp_n(mtemp_n),
    .p4sw_p(p4sw_p),
    .p4sw_n(p4sw_n),

    .addr(cmd_addr),
    .data_in(cmd_data),
    .read_en(ctrl_read_en),
    .write_en(ctrl_write_en),
    .write_done(ctrl_write_done),
    .data_out(ctrl_data),
    .start_req(start_req),
    .proceed_req(proceed_req),
    .stop_conds(stop_conds),
    .stop_s1_s2(stop_s1_s2),
    .stop_cause(stop_cause),
    .mnhrpt(mnhrpt),
    .mnhnc(mnhnc),
    .nhalga(nhalga),

    .s(s),
    .eb(eb),
    .fb(fb),
    .fext(fext),
    .minkl(minkl),
    .minhl(minhl),
    .miip(miip),

    .w(w),
    .wp(wp),
    .i(i),

    .s1_match(s1_match),
    .s2_match(s2_match),
    .w_match(w_match),
    .i_match(i_match),

    .w_mode(w_mode),
    .w_s1_s2(w_s1_s2),
    .w_times(w_times),
    .w_pulses(w_pulses),

    .s_only(s_only),
    .adv_s(adv_s),
    .periph_load(ctrl_periph_load),
    .periph_read(ctrl_periph_read),
    .periph_loadch(ctrl_periph_loadch),
    .periph_readch(ctrl_periph_readch),
    .periph_tcsaj(ctrl_periph_tcsaj),
    .periph_s(ctrl_periph_s),
    .periph_bb(ctrl_periph_bb),
    .periph_data(ctrl_periph_data),
    .periph_complete(periph_complete)
);

/*******************************************************************************.
* Start/Stop Logic                                                              *
'*******************************************************************************/
wire mrchg;
wire mwchg;
wire ss_mstp;
wire inhibit_mstp;
assign mstp = ss_mstp & ~inhibit_mstp;
start_stop strt_stp(
    .clk(clk),
    .rst_n(rst_n),
    .start_req(start_req),
    .proceed_req(proceed_req),
    .stop_conds(stop_conds),
    .stop_s1_s2(stop_s1_s2),
    .stop_cause(stop_cause),
    .mt01(mt[1]),
    .mt12(mt[12]),
    .mgojam(mgojam),
    .mnisq(mnisq),
    .mpal_n(mpal_n),
    .mrchg(mrchg),
    .mwchg(mwchg),

    .s1_match(s1_match),
    .s2_match(s2_match),
    .w_match(w_match),
    .i_match(i_match),

    .mstrt(mstrt),
    .mstp(ss_mstp)
);

/*******************************************************************************.
* Clear Timer                                                                   *
'*******************************************************************************/
wire ct;
clear_timer ctmr(
    .clk(clk),
    .rst_n(rst_n),
    .monwt(monwt),
    .ct(ct)
);

/*******************************************************************************.
* Monitor Registers                                                             *
'*******************************************************************************/
wire [15:10] sq;
wire [16:1] l;
wire [16:1] q;
wire inhibit_ws;
wire rbbk;
monitor_regs mon_regs(
    .clk(clk),
    .rst_n(rst_n),

    .mt(mt),
    .monwt(monwt),
    .ct(ct),
    .mwl(mwl),
    .mwag(mwag),
    .mwlg(mwlg),
    .mwqg(mwqg),
    .mwebg(mwebg),
    .mwfbg(mwfbg),
    .mwbbeg(mwbbeg),
    .mwzg(mwzg),
    .mwbg(mwbg),
    .mwsg(mwsg),
    .mwg(mwg),
    .mwyg(mwyg),
    .mrulog(mrulog),
    .mrgg(mrgg),
    .mwchg(mwchg),
    .mrchg(mrchg),

    .inhibit_ws(inhibit_ws),
    .rbbk(rbbk),
    .s_only(s_only),
    .adv_s(adv_s),

    .msqext(msqext),
    .msq(msq),
    .mst(mst),
    .mbr(mbr),

    .mgojam(mgojam),
    .mstpit_n(mstpit_n),
    .miip(miip),
    .minhl(minhl),
    .minkl(minkl),
    .mnisq(mnisq),
    .msp(msp),
    .mgp_n(mgp_n),

    .mstp(mstp),

    .s1_match(s1_match),
    .s2_match(s2_match),
    .i_match(i_match),

    .w_mode(w_mode),
    .w_s1_s2(w_s1_s2),
    .w_times(w_times),
    .w_pulses(w_pulses),

    .sq(sq),
    .l(l),
    .q(q),
    .s(s),
    .eb(eb),
    .fb(fb),

    .w(w),
    .wp(wp),
    .i(i),

    .read_en(mon_reg_read_en),
    .addr(cmd_addr),
    .data_out(mon_reg_data)
);

/*******************************************************************************.
* Monitor AGC Channel Mirrors                                                   *
'*******************************************************************************/
wire [9:1] chan77;
wire [15:1] out0;
wire [15:1] dsalmout;
wire [15:1] chan13;
monitor_channels mon_chans(
    .clk(clk),
    .rst_n(rst_n),

    .monwt(monwt),
    .ct(ct),

    .mrch(mrch),
    .mwch(mwch),
    .ch(s[9:1]),
    .mwl({mwl[16], mwl[14:1]}),
    .l({l[16], l[14:1]}),
    .q({q[16], q[14:1]}),
    .chan77(chan77),

    .mrchg(mrchg),
    .mwchg(mwchg),
    .fext(fext),
    .out0(out0),
    .dsalmout(dsalmout),
    .chan13(chan13),

    .read_en(mon_chan_read_en),
    .addr(cmd_addr),
    .data_out(mon_chan_data)
);

/*******************************************************************************.
* Restart Monitor                                                               *
'*******************************************************************************/
wire [16:1] mdt_chan77;
restart_monitor restart_mon(
    .clk(clk),
    .rst_n(rst_n),

    .mt05(mt[5]),
    .mrchg(mrchg),
    .mwchg(mwchg),
    .ch(s[9:1]),
    .mpal_n(mpal_n),
    .mtcal_n(mtcal_n),
    .mrptal_n(mrptal_n),
    .mwatch_n(mwatch_n),
    .mvfail_n(mvfail_n),
    .mctral_n(mctral_n),
    .mscafl_n(mscafl_n),
    .mscdbl_n(mscdbl_n),

    .chan77(chan77),
    .mdt(mdt_chan77)
);

/*******************************************************************************.
* Peripheral Instructions                                                       *
'*******************************************************************************/
wire periph_load;
assign periph_load = ctrl_periph_load;
wire periph_read;
assign periph_read = ctrl_periph_read;
wire periph_loadch;
assign periph_loadch = ctrl_periph_loadch;
wire periph_readch;
assign periph_readch = ctrl_periph_readch;
wire periph_tcsaj;
assign periph_tcsaj = ctrl_periph_tcsaj;
wire [15:1] periph_bb;
assign periph_bb = ctrl_periph_bb;
wire [12:1] periph_s;
assign periph_s = ctrl_periph_s;
wire [16:1] periph_data;
assign periph_data = ctrl_periph_data;
wire [16:1] mdt_periph;
wire [16:1] periph_read_data;
peripheral_instructions periph_insts(
    .clk(clk),
    .rst_n(rst_n),

    .monwt(monwt),
    .mt(mt),
    .mst(mst),
    .mwl(mwl),

    .inhibit_mstp(inhibit_mstp),
    .inhibit_ws(inhibit_ws),
    .rbbk(rbbk),

    .mreqin(mreqin),
    .mtcsa_n(mtcsa_n),

    .load(periph_load),
    .read(periph_read),
    .loadch(periph_loadch),
    .readch(periph_readch),
    .tcsaj(periph_tcsaj),

    .bb(periph_bb),
    .s(periph_s),
    .data(periph_data),

    .read_data(periph_read_data),
    .complete(periph_complete),

    .mtcsai(mtcsai),
    .mread(mread),
    .mload(mload),
    .mrdch(mrdch),
    .mldch(mldch),
    .monwbk(monwbk),

    .mdt(mdt_periph)
);

/*******************************************************************************.
* DSKY                                                                          *
'*******************************************************************************/
wire [16:1] mdt_dsky;

monitor_dsky mon_dsky(
    .clk(clk),
    .rst_n(rst_n),

    .read_en(mon_dsky_read_en),
    .write_en(mon_dsky_write_en),
    .addr(cmd_addr),
    .data_in(cmd_data),
    .data_out(mon_dsky_data),

    .mgojam(mgojam),
    .mt(mt),
    .mst(mst),
    .msqext(msqext),
    .sq(sq),
    .miip(miip),
    .mrgg(mrgg),
    .mrchg(mrchg),
    .mwbg(mwbg),
    .mwsg(mwsg),
    .ch(s[9:1]),
    .mwl(mwl),

    .out0(out0),
    .dsalmout(dsalmout),
    .chan13(chan13),

    .mnhsbf(mnhsbf),
    .mdt(mdt_dsky),
    .monpar(monpar)
);

assign mdt = mdt_chan77 | mdt_periph | mdt_dsky;

/*******************************************************************************.
* Zync Processor Subsystem                                                      *
'*******************************************************************************/
// Zynq PS instantiation (currently just used for booting)
`ifndef XILINX_SIMULATOR
monitor_ps_wrapper monitor_ps(
    .DDR_addr(DDR_addr),
    .DDR_ba(DDR_ba),
    .DDR_cas_n(DDR_cas_n),
    .DDR_ck_n(DDR_ck_n),
    .DDR_ck_p(DDR_ck_p),
    .DDR_cke(DDR_cke),
    .DDR_cs_n(DDR_cs_n),
    .DDR_dm(DDR_dm),
    .DDR_dq(DDR_dq),
    .DDR_dqs_n(DDR_dqs_n),
    .DDR_dqs_p(DDR_dqs_p),
    .DDR_odt(DDR_odt),
    .DDR_ras_n(DDR_ras_n),
    .DDR_reset_n(DDR_reset_n),
    .DDR_we_n(DDR_we_n),
    .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
    .FIXED_IO_mio(FIXED_IO_mio),
    .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
    .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)
);
`endif

endmodule
`default_nettype wire
