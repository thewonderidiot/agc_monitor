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
    input wire p3v3io_p,
    input wire p3v3io_n,
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

    input wire mrsc,
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

    input wire mvfail_n,
    input wire moscal_n,
    input wire mscafl_n,
    input wire mscdbl_n,
    input wire mctral_n,
    input wire mtcal_n,
    input wire mrptal_n,
    input wire mpal_n,
    input wire mwatch_n,
    input wire mpipal_n,
    input wire mwarnf_n,

    output wire mnhsbf,
    output wire mamu,
    output wire [16:1] mdt,
    output wire monpar,

    output wire mstrt,
    output wire mstp,

    output wire mnhrpt,
    output wire mnhnc,
    output wire nhalga,
    output wire nhstrt1,
    output wire nhstrt2,
    output wire doscal,
    output wire dbltst,

    output wire mread,
    output wire mload,
    output wire mrdch,
    output wire mldch,
    output wire mtcsai,
    output wire monwbk,
    input wire mreqin,
    input wire mtcsa_n,

    output wire [6:1] leds,
    output wire [6:1] dbg,
    
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
* Interface Circuits                                                            *
'*******************************************************************************/
// Debounced input wires
wire mstpit_n_db;
wire monwt_db;
wire [12:1] mt_db;
wire [16:1] mwl_db;
wire miip_db;
wire minhl_db;
wire minkl_db;
wire msqext_db;
wire [15:10] msq_db;
wire [3:1] mst_db;
wire [2:1] mbr_db;
wire mrsc_db;
wire mwag_db;
wire mwlg_db;
wire mwqg_db;
wire mwebg_db;
wire mwfbg_db;
wire mwbbeg_db;
wire mwzg_db;
wire mwbg_db;
wire mwsg_db;
wire mwg_db;
wire mwyg_db;
wire mrulog_db;
wire mrgg_db;
wire mrch_db;
wire mwch_db;
wire mnisq_db;
wire msp_db;
wire mgp_n_db;
wire mreqin_db;
wire mtcsa_n_db;

// Push-pull output wires
wire mnhsbf_pp;
wire mamu_pp;
wire [16:1] mdt_pp;
wire monpar_pp;
wire mstrt_pp;
wire mstp_pp;
wire mnhrpt_pp;
wire mnhnc_pp;
wire nhalga_pp;
wire doscal_pp;
wire dbltst_pp;
wire mread_pp;
wire mload_pp;
wire mrdch_pp;
wire mldch_pp;
wire mtcsai_pp;
wire monwbk_pp;

io_circuits io(
    .clk(clk),
    .rst_n(rst_n),

    // Raw inputs
    .mstpit_n(mstpit_n),
    .monwt(monwt),
    .mt(mt),
    .mwl(mwl),
    .miip(miip),
    .minhl(minhl),
    .minkl(minkl),
    .msqext(msqext),
    .msq(msq),
    .mst(mst),
    .mbr(mbr),
    .mrsc(mrsc),
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
    .mrch(mrch),
    .mwch(mwch),
    .mnisq(mnisq),
    .msp(msp),
    .mgp_n(mgp_n),
    .mreqin(mreqin),
    .mtcsa_n(mtcsa_n),

    // Debounced inputs
    .mstpit_n_db(mstpit_n_db),
    .monwt_db(monwt_db),
    .mt_db(mt_db),
    .mwl_db(mwl_db),
    .miip_db(miip_db),
    .minhl_db(minhl_db),
    .minkl_db(minkl_db),
    .msqext_db(msqext_db),
    .msq_db(msq_db),
    .mst_db(mst_db),
    .mbr_db(mbr_db),
    .mrsc_db(mrsc_db),
    .mwag_db(mwag_db),
    .mwlg_db(mwlg_db),
    .mwqg_db(mwqg_db),
    .mwebg_db(mwebg_db),
    .mwfbg_db(mwfbg_db),
    .mwbbeg_db(mwbbeg_db),
    .mwzg_db(mwzg_db),
    .mwbg_db(mwbg_db),
    .mwsg_db(mwsg_db),
    .mwg_db(mwg_db),
    .mwyg_db(mwyg_db),
    .mrulog_db(mrulog_db),
    .mrgg_db(mrgg_db),
    .mrch_db(mrch_db),
    .mwch_db(mwch_db),
    .mnisq_db(mnisq_db),
    .msp_db(msp_db),
    .mgp_n_db(mgp_n_db),
    .mreqin_db(mreqin_db),
    .mtcsa_n_db(mtcsa_n_db),

    // Raw outputs
    .mnhsbf(mnhsbf),
    .mamu(mamu),
    .mdt(mdt),
    .monpar(monpar),
    .mstrt(mstrt),
    .mstp(mstp),
    .mnhrpt(mnhrpt),
    .mnhnc(mnhnc),
    .nhalga(nhalga),
    .doscal(doscal),
    .dbltst(dbltst),
    .mread(mread),
    .mload(mload),
    .mrdch(mrdch),
    .mldch(mldch),
    .mtcsai(mtcsai),
    .monwbk(monwbk),

    // OD outputs
    .mnhsbf_pp(mnhsbf_pp),
    .mamu_pp(mamu_pp),
    .mdt_pp(mdt_pp),
    .monpar_pp(monpar_pp),
    .mstrt_pp(mstrt_pp),
    .mstp_pp(mstp_pp),
    .mnhrpt_pp(mnhrpt_pp),
    .mnhnc_pp(mnhnc_pp),
    .nhalga_pp(nhalga_pp),
    .doscal_pp(doscal_pp),
    .dbltst_pp(dbltst_pp),
    .mread_pp(mread_pp),
    .mload_pp(mload_pp),
    .mrdch_pp(mrdch_pp),
    .mldch_pp(mldch_pp),
    .mtcsai_pp(mtcsai_pp),
    .monwbk_pp(monwbk_pp)
);

wire [6:1] leds_n;
assign leds = ~leds_n;

/*******************************************************************************.
* Monitor                                                                       *
'*******************************************************************************/
monitor mon(
    .clk(clk),
    .rst_n(rst_n),

    // FT232 FIFO interface
    .clkout(clkout),
    .data(data),
    .rxf_n(rxf_n),
    .txe_n(txe_n),
    .rd_n(rd_n),
    .wr_n(wr_n),
    .oe_n(oe_n),
    .siwu(siwu),

    // AGC signals
    .bplssw_p(bplssw_p),
    .bplssw_n(bplssw_n),
    .p4sw_p(p4sw_p),
    .p4sw_n(p4sw_n),
    .p3v3io_p(p3v3io_p),
    .p3v3io_n(p3v3io_n),
    .mtemp_p(mtemp_p),
    .mtemp_n(mtemp_n),

    .mgojam(mgojam),
    .mstpit_n(mstpit_n_db),
    .monwt(monwt_db),
    .mt(mt_db),
    .mwl(mwl_db),

    .miip(miip_db),
    .minhl(minhl_db),
    .minkl(minkl_db),

    .msqext(msqext_db),
    .msq(msq_db),
    .mst(mst_db),
    .mbr(mbr_db),

    .mrsc(mrsc_db),
    .mwag(mwag_db),
    .mwlg(mwlg_db),
    .mwqg(mwqg_db),
    .mwebg(mwebg_db),
    .mwfbg(mwfbg_db),
    .mwbbeg(mwbbeg_db),
    .mwzg(mwzg_db),
    .mwbg(mwbg_db),
    .mwsg(mwsg_db),
    .mwg(mwg_db),
    .mwyg(mwyg_db),
    .mrulog(mrulog_db),
    .mrgg(mrgg_db),
    .mrch(mrch_db),
    .mwch(mwch_db),
    .mnisq(mnisq_db),
    .msp(msp_db),
    .mgp_n(mgp_n_db),

    .mvfail_n(mvfail_n),
    .moscal_n(moscal_n),
    .mscafl_n(mscafl_n),
    .mscdbl_n(mscdbl_n),
    .mctral_n(mctral_n),
    .mtcal_n(mtcal_n),
    .mrptal_n(mrptal_n),
    .mpal_n(mpal_n),
    .mwatch_n(mwatch_n),
    .mpipal_n(mpipal_n),
    .mwarnf_n(mwarnf_n),

    .mnhsbf(mnhsbf_pp),
    .mamu(mamu_pp),
    .mdt(mdt_pp),
    .monpar(monpar_pp),

    .mstrt(mstrt_pp),
    .mstp(mstp_pp),

    .mnhrpt(mnhrpt_pp),
    .mnhnc(mnhnc_pp),
    .nhalga(nhalga_pp),
    .nhstrt1(nhstrt1),
    .nhstrt2(nhstrt2),
    .doscal(doscal_pp),
    .dbltst(dbltst_pp),

    .mread(mread_pp),
    .mload(mload_pp),
    .mrdch(mrdch_pp),
    .mldch(mldch_pp),
    .mtcsai(mtcsai_pp),
    .monwbk(monwbk_pp),
    .mreqin(mreqin_db),
    .mtcsa_n(mtcsa_n_db),

    .leds(leds_n),
    .dbg(dbg)
);

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
