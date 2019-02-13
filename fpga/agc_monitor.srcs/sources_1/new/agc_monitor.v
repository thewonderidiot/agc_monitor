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
* Interface Circuits                                                            *
'*******************************************************************************/
wire mstpit_n_db;
debounce #(1,3) db1(clk, rst_n, mstpit_n, mstpit_n_db);
wire monwt_db;
debounce #(1,3) db2(clk, rst_n, monwt, monwt_db);
wire [12:1] mt_db;
debounce #(12,3) db3(clk, rst_n, mt, mt_db);
wire [16:1] mwl_db;
debounce #(16,3) db4(clk, rst_n, mwl, mwl_db);
wire miip_db;
debounce #(1,3) db5(clk, rst_n, miip, miip_db);
wire minhl_db;
debounce #(1,3) db6(clk, rst_n, minhl, minhl_db);
wire minkl_db;
debounce #(1,3) db7(clk, rst_n, minkl, minkl_db);
wire msqext_db;
debounce #(1,3) db8(clk, rst_n, msqext, msqext_db);
wire [15:10] msq_db;
debounce #(6,3) db9(clk, rst_n, msq, msq_db);
wire [3:1] mst_db;
debounce #(3,3) db10(clk, rst_n, mst, mst_db);
wire [2:1] mbr_db;
debounce #(2,3) db11(clk, rst_n, mbr, mbr_db);
wire mwag_db;
debounce #(1,3) db12(clk, rst_n, mwag, mwag_db);
wire mwlg_db;
debounce #(1,3) db13(clk, rst_n, mwlg, mwlg_db);
wire mwqg_db;
debounce #(1,3) db14(clk, rst_n, mwqg, mwqg_db);
wire mwebg_db;
debounce #(1,3) db15(clk, rst_n, mwebg, mwebg_db);
wire mwfbg_db;
debounce #(1,3) db16(clk, rst_n, mwfbg, mwfbg_db);
wire mwbbeg_db;
debounce #(1,3) db17(clk, rst_n, mwbbeg, mwbbeg_db);
wire mwzg_db;
debounce #(1,3) db18(clk, rst_n, mwzg, mwzg_db);
wire mwbg_db;
debounce #(1,3) db19(clk, rst_n, mwbg, mwbg_db);
wire mwsg_db;
debounce #(1,3) db20(clk, rst_n, mwsg, mwsg_db);
wire mwg_db;
debounce #(1,3) db21(clk, rst_n, mwg, mwg_db);
wire mwyg_db;
debounce #(1,3) db22(clk, rst_n, mwyg, mwyg_db);
wire mrulog_db;
debounce #(1,3) db23(clk, rst_n, mrulog, mrulog_db);
wire mrgg_db;
debounce #(1,3) db24(clk, rst_n, mrgg, mrgg_db);
wire mrch_db;
debounce #(1,3) db25(clk, rst_n, mrch, mrch_db);
wire mwch_db;
debounce #(1,3) db26(clk, rst_n, mwch, mwch_db);
wire mnisq_db;
debounce #(1,3) db27(clk, rst_n, mnisq, mnisq_db);
wire msp_db;
debounce #(1,3) db28(clk, rst_n, msp, msp_db);
wire mgp_n_db;
debounce #(1,3) db29(clk, rst_n, mgp_n, mgp_n_db);
wire mreqin_db;
debounce #(1,3) db30(clk, rst_n, mreqin, mreqin_db);
wire mtcsa_n_db;
debounce #(1,3) db31(clk, rst_n, mtcsa_n, mtcsa_n_db);

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

    .mpal_n(mpal_n),
    .mtcal_n(mtcal_n),
    .mrptal_n(mrptal_n),
    .mwatch_n(mwatch_n),
    .mvfail_n(mvfail_n),
    .mctral_n(mctral_n),
    .mscafl_n(mscafl_n),
    .mscdbl_n(mscdbl_n),

    .mnhsbf(mnhsbf),
    .mdt(mdt),
    .monpar(monpar),

    .mstrt(mstrt),
    .mstp(mstp),

    .mnhrpt(mnhrpt),
    .mnhnc(mnhnc),
    .nhalga(nhalga),

    .mread(mread),
    .mload(mload),
    .mrdch(mrdch),
    .mldch(mldch),
    .mtcsai(mtcsai),
    .monwbk(monwbk),
    .mreqin(mreqin_db),
    .mtcsa_n(mtcsa_n_db)
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
