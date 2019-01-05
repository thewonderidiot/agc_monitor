`timescale 1ns / 1ps
`default_nettype none

module agc_monitor(
    input wire clk,
    input wire rst_n,
    output wire led,
    output wire led2,

    // FT232 FIFO interface
    input wire clkout,
    inout wire [7:0] data,
    input wire rxf_n,
    input wire txe_n,
    output wire rd_n,
    output wire wr_n,
    output wire oe_n,
    output wire siwu,
    
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

// Resulting data from the active read command
wire [15:0] read_data;
assign read_data = ctrl_data;

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
    .ctrl_write_en(ctrl_write_en)
);

/*******************************************************************************.
* Monitor Control Registers                                                     *
'*******************************************************************************/
control_regs ctrl_regs(
    .clk(clk),
    .rst_n(rst_n),
    .addr(cmd_addr),
    .data_in(cmd_data),
    .read_en(ctrl_read_en),
    .write_en(ctrl_write_en),
    .data_out(ctrl_data),
    .nhalga(led2)
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
