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
    input wire mgojam,
    input wire monwt,
    input wire [12:1] mt,
    input wire [16:1] mwl,

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
    input wire mrgg,
    input wire mrch,
    input wire mwch,
    input wire mnisq,

    input wire mpal_n,
    input wire mtcal_n,
    input wire mrptal_n,
    input wire mwatch_n,
    input wire mvfail_n,
    input wire mctral_n,
    input wire mscafl_n,
    input wire mscdbl_n,

    output wire [16:1] mdt,

    output wire mstrt,
    output wire mstp,

    output wire mnhrpt,
    output wire mnhnc,
    
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
wire [15:0] ctrl_data;

wire mon_reg_read_en;
wire [15:0] mon_reg_data;

wire mon_chan_read_en;
wire [15:0] mon_chan_data;

// Resulting data from the active read command
wire [15:0] read_data;
assign read_data = ctrl_data | mon_reg_data | mon_chan_data;

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
    .mon_reg_read_en(mon_reg_read_en),
    .mon_chan_read_en(mon_chan_read_en)
);

/*******************************************************************************.
* Control Registers                                                             *
'*******************************************************************************/
wire start_req;
wire proceed_req;
wire [10:0] stop_conds;
wire [10:0] stop_cause;

control_regs ctrl_regs(
    .clk(clk),
    .rst_n(rst_n),
    .addr(cmd_addr),
    .data_in(cmd_data),
    .read_en(ctrl_read_en),
    .write_en(ctrl_write_en),
    .data_out(ctrl_data),
    .start_req(start_req),
    .proceed_req(proceed_req),
    .stop_conds(stop_conds),
    .stop_cause(stop_cause),
    .mnhrpt(mnhrpt),
    .mnhnc(mnhnc)
);

/*******************************************************************************.
* Start/Stop Logic                                                              *
'*******************************************************************************/
start_stop strt_stp(
    .clk(clk),
    .rst_n(rst_n),
    .start_req(start_req),
    .proceed_req(proceed_req),
    .stop_conds(stop_conds),
    .stop_cause(stop_cause),
    .mt01(mt[1]),
    .mt12(mt[12]),
    .mgojam(mgojam),
    .mnisq(mnisq),
    .mstrt(mstrt),
    .mstp(mstp)
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
* Monitor AGC Register Mirrors                                                  *
'*******************************************************************************/
wire [16:1] l;
wire [16:1] q;
wire [12:1] s;
monitor_regs mon_regs(
    .clk(clk),
    .rst_n(rst_n),

    .mt02(mt[2]),
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
    .mrgg(mrgg),

    .l(l),
    .q(q),
    .s(s),

    .read_en(mon_reg_read_en),
    .addr(cmd_addr),
    .data_out(mon_reg_data)
);

/*******************************************************************************.
* Monitor AGC Channel Mirrors                                                   *
'*******************************************************************************/
wire [9:1] chan77;
monitor_channels mon_chans(
    .clk(clk),
    .rst_n(rst_n),

    .ct(ct),

    .mrch(mrch),
    .mwch(mwch),
    .ch(s[9:1]),
    .mwl({mwl[16], mwl[14:1]}),
    .l({l[16], l[14:1]}),
    .q({q[16], q[14:1]}),
    .chan77(chan77),

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
    .mrch(mrch),
    .mwch(mwch),
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

assign mdt = mdt_chan77;

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
