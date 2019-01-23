`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module monitor_regs(
    input wire clk,
    input wire rst_n,

    input wire mt02,
    input wire monwt,
    input wire ct,

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

    input wire msqext,
    input wire [15:10] msq,
    input wire [3:1] mst,
    input wire [2:1] mbr,

    input wire mgojam,
    input wire mstpit_n,
    input wire miip,
    input wire minhl,
    input wire minkl,

    input wire mstp,

    output wire [16:1] l,
    output wire [16:1] q,
    output wire [12:1] s,

    input wire read_en,
    input wire [15:0] addr,
    output reg [15:0] data_out
);

// Register A
wire [16:1] a;
register reg_a(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwag),
    .mwl(mwl),
    .val(a)
);

// Register L
register reg_l(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwlg),
    .mwl(mwl),
    .val(l)
);

// Register Q
register reg_q(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwqg),
    .mwl(mwl),
    .val(q)
);

// Register EB
wire [3:1] eb;
register2 #(3) reg_eb(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg1(mwebg),
    .mwl1(mwl[11:9]),
    .mwg2(mwbbeg),
    .mwl2(mwl[3:1]),
    .val(eb)
);

// Register FB
wire [5:1] fb;
register #(5) reg_fb(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwfbg),
    .mwl({mwl[16], mwl[14:11]}),
    .val(fb)
);

// Register Z
wire [16:1] z;
register reg_z(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwzg),
    .mwl(mwl),
    .val(z)
);

// Register B
wire [16:1] b;
register reg_b(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwbg),
    .mwl(mwl),
    .val(b)
);

// Register S
register #(12) reg_s(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwsg),
    .mwl(mwl[12:1]),
    .val(s)
);

// Register G
wire [16:1] mwl_edited;
edit editing(
    .clk(clk),
    .rst_n(rst_n),
    .mt02(mt02),
    .s(s),
    .mwl(mwl),
    .mwl_edited(mwl_edited)
);

wire [16:1] g;
register2 reg_g(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg1(mwg),
    .mwl1(mwl_edited),
    .mwg2(mrgg),
    .mwl2(mwl),
    .val(g)
);

// Register Y
wire [16:1] y;
register reg_y(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwyg),
    .mwl(mwl),
    .val(y)
);

// Register SQ
reg [15:10] sq;
always @(posedge clk) begin
    if (~rst_n) begin
        sq <= 6'o0;
    end else if (~(mstp & monwt)) begin
        // Filter out transient 0's caused by CSQG during MSTP
        sq <= msq;
    end
end

reg read_en_q;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_en_q <= 1'b0;
    end else begin
        read_en_q <= read_en;
    end
end

always @(*) begin
    if (read_en_q) begin
        case (addr)
        `MON_REG_A:      data_out = a;
        `MON_REG_L:      data_out = l;
        `MON_REG_Q:      data_out = q;
        `MON_REG_Z:      data_out = z;
        `MON_REG_BB:     data_out = {1'b0, fb, 7'b0, eb};
        `MON_REG_B:      data_out = b;
        `MON_REG_S:      data_out = {4'b0, s};
        `MON_REG_G:      data_out = g;
        `MON_REG_Y:      data_out = y;
        `MON_REG_I:      data_out = {5'b0, mbr, mst, msqext, sq};
        `MON_REG_STATUS: data_out = {11'b0, minkl, minhl, miip, mstpit_n, mgojam}; // FIXME: add OUTCOM
        default:         data_out = 16'b0;
        endcase
    end else begin
        data_out = 16'b0;
    end
end

endmodule
`default_nettype wire
