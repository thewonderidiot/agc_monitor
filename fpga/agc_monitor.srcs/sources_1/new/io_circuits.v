`timescale 1ns / 1ps
`default_nettype none

module io_circuits(
    input wire clk,
    input wire rst_n,

    // Debounced inputs
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
    input wire mreqin,
    input wire mtcsa_n,

    output wire mstpit_n_db,
    output wire monwt_db,
    output wire [12:1] mt_db,
    output wire [16:1] mwl_db,
    output wire miip_db,
    output wire minhl_db,
    output wire minkl_db,
    output wire msqext_db,
    output wire [15:10] msq_db,
    output wire [3:1] mst_db,
    output wire [2:1] mbr_db,
    output wire mwag_db,
    output wire mwlg_db,
    output wire mwqg_db,
    output wire mwebg_db,
    output wire mwfbg_db,
    output wire mwbbeg_db,
    output wire mwzg_db,
    output wire mwbg_db,
    output wire mwsg_db,
    output wire mwg_db,
    output wire mwyg_db,
    output wire mrulog_db,
    output wire mrgg_db,
    output wire mrch_db,
    output wire mwch_db,
    output wire mnisq_db,
    output wire msp_db,
    output wire mgp_n_db,
    output wire mreqin_db,
    output wire mtcsa_n_db,

    // Open-drain outputs
    input wire mnhsbf_pp,
    input wire [16:1] mdt_pp,
    input wire monpar_pp,
    input wire mstrt_pp,
    input wire mstp_pp,
    input wire mnhrpt_pp,
    input wire mnhnc_pp,
    input wire nhalga_pp,
    input wire doscal_pp,
    input wire dbltst_pp,
    input wire mread_pp,
    input wire mload_pp,
    input wire mrdch_pp,
    input wire mldch_pp,
    input wire mtcsai_pp,
    input wire monwbk_pp,

    output wire mnhsbf,
    output wire [16:1] mdt,
    output wire monpar,
    output wire mstrt,
    output wire mstp,
    output wire mnhrpt,
    output wire mnhnc,
    output wire nhalga,
    output wire doscal,
    output wire dbltst,
    output wire mread,
    output wire mload,
    output wire mrdch,
    output wire mldch,
    output wire mtcsai,
    output wire monwbk
);

debounce #(1,3)  db1(clk, rst_n, mstpit_n, mstpit_n_db);
debounce #(1,3)  db2(clk, rst_n, monwt, monwt_db);
debounce #(12,3) db3(clk, rst_n, mt, mt_db);
debounce #(16,3) db4(clk, rst_n, mwl, mwl_db);
debounce #(1,3)  db5(clk, rst_n, miip, miip_db);
debounce #(1,3)  db6(clk, rst_n, minhl, minhl_db);
debounce #(1,3)  db7(clk, rst_n, minkl, minkl_db);
debounce #(1,3)  db8(clk, rst_n, msqext, msqext_db);
debounce #(6,3)  db9(clk, rst_n, msq, msq_db);
debounce #(3,3) db10(clk, rst_n, mst, mst_db);
debounce #(2,3) db11(clk, rst_n, mbr, mbr_db);
debounce #(1,3) db12(clk, rst_n, mwag, mwag_db);
debounce #(1,3) db13(clk, rst_n, mwlg, mwlg_db);
debounce #(1,3) db14(clk, rst_n, mwqg, mwqg_db);
debounce #(1,3) db15(clk, rst_n, mwebg, mwebg_db);
debounce #(1,3) db16(clk, rst_n, mwfbg, mwfbg_db);
debounce #(1,3) db17(clk, rst_n, mwbbeg, mwbbeg_db);
debounce #(1,3) db18(clk, rst_n, mwzg, mwzg_db);
debounce #(1,3) db19(clk, rst_n, mwbg, mwbg_db);
debounce #(1,3) db20(clk, rst_n, mwsg, mwsg_db);
debounce #(1,3) db21(clk, rst_n, mwg, mwg_db);
debounce #(1,3) db22(clk, rst_n, mwyg, mwyg_db);
debounce #(1,3) db23(clk, rst_n, mrulog, mrulog_db);
debounce #(1,3) db24(clk, rst_n, mrgg, mrgg_db);
debounce #(1,3) db25(clk, rst_n, mrch, mrch_db);
debounce #(1,3) db26(clk, rst_n, mwch, mwch_db);
debounce #(1,3) db27(clk, rst_n, mnisq, mnisq_db);
debounce #(1,3) db28(clk, rst_n, msp, msp_db);
debounce #(1,3) db29(clk, rst_n, mgp_n, mgp_n_db);
debounce #(1,3) db30(clk, rst_n, mreqin, mreqin_db);
debounce #(1,3) db31(clk, rst_n, mtcsa_n, mtcsa_n_db);

od_buf #(1)  od1(mnhsbf_pp, mnhsbf);
od_buf #(16) od2(mdt_pp, mdt);
od_buf #(1)  od3(monpar_pp, monpar);
od_buf #(1)  od4(mstrt_pp, mstrt);
od_buf #(1)  od5(mstp_pp, mstp);
od_buf #(1)  od6(mnhrpt_pp, mnhrpt);
od_buf #(1)  od7(mnhnc_pp, mnhnc);
od_buf #(1)  od8(nhalga_pp, nhalga);
od_buf #(1)  od9(doscal_pp, doscal);
od_buf #(1) od10(dbltst_pp, dbltst);
od_buf #(1) od11(mread_pp, mread);
od_buf #(1) od12(mload_pp, mload);
od_buf #(1) od13(mrdch_pp, mrdch);
od_buf #(1) od14(mldch_pp, mldch);
od_buf #(1) od15(mtcsai_pp, mtcsai);
od_buf #(1) od16(monwbk_pp, monwbk);

endmodule
`default_nettype wire
