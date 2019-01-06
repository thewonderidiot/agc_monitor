`timescale 1ns / 1ps
`default_nettype none

module monitor_channels(
    input wire clk,
    input wire rst_n,

    input wire ct,

    input wire mrch,
    input wire mwch,
    input wire [9:1] ch,
    input wire [15:1] mwl,

    input wire [15:1] l,
    input wire [15:1] q,
    input wire [9:1] chan77,

    input wire read_en,
    input wire [15:0] addr,
    output reg [15:0] data_out
);

wire [15:1] hiscalar;
channel #(3,15) chan_3(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(hiscalar)
);

wire [15:1] loscalar;
channel #(4,15) chan_4(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(loscalar)
);

wire [8:1] pyjets;
channel #(5,8) chan_5(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl[8:1]),
    .val(pyjets)
);

wire [8:1] rolljets;
channel #(6,8) chan_6(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl[8:1]),
    .val(rolljets)
);

wire [7:5] fext;
channel #(7,3) chan_7(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl[7:5]),
    .val(fext)
);

wire [15:1] out0;
channel #(10,15) chan_10(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(out0)
);

wire [15:1] dsalmout;
channel #(11,15) chan_11(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(dsalmout)
);

wire [15:1] chan12;
channel #(12,15) chan_12(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(chan12)
);

wire [15:1] chan13;
channel #(13,15) chan_13(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(chan13)
);

wire [15:1] chan14;
channel #(14,15) chan_14(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(chan14)
);

wire [5:1] mkeyin;
channel #(15,5) chan_15(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl[5:1]),
    .val(mkeyin)
);

wire [7:1] navkeyin;
channel #(16,7) chan_16(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl[7:1]),
    .val(navkeyin)
);

wire [15:1] chan30;
channel #(30,15) chan_30(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(chan30)
);

wire [15:1] chan31;
channel #(31,15) chan_31(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(chan31)
);

wire [15:1] chan32;
channel #(32,15) chan_32(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(chan32)
);

wire [15:1] chan33;
channel #(33,15) chan_33(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(chan33)
);

wire [15:1] dntm1;
channel #(34,15) chan_34(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(dntm1)
);

wire [15:1] dntm2;
channel #(35,15) chan_35(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mrch(mrch),
    .mwch(mwch),
    .ch(ch),
    .mwl(mwl),
    .val(dntm2)
);

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
        9'o001:  data_out = {1'b0, l};
        9'o002:  data_out = {1'b0, q};
        9'o003:  data_out = {1'b0, hiscalar};
        9'o004:  data_out = {1'b0, loscalar};
        9'o005:  data_out = {7'b0, pyjets};
        9'o006:  data_out = {7'b0, rolljets};
        9'o007:  data_out = {8'b0, fext, 4'b0};
        9'o010:  data_out = {1'b0, out0};
        9'o011:  data_out = {1'b0, dsalmout};
        9'o012:  data_out = {1'b0, chan12};
        9'o013:  data_out = {1'b0, chan13};
        9'o014:  data_out = {1'b0, chan14};
        9'o015:  data_out = {10'b0, mkeyin};
        9'o016:  data_out = {8'b0, navkeyin};
        9'o030:  data_out = {1'b0, chan30};
        9'o031:  data_out = {1'b0, chan31};
        9'o032:  data_out = {1'b0, chan32};
        9'o033:  data_out = {1'b0, chan33};
        9'o034:  data_out = {1'b0, dntm1};
        9'o035:  data_out = {1'b0, dntm2};
        9'o077:  data_out = {1'b0, chan77};
        default: data_out = 16'b0;
        endcase
    end else begin
        data_out = 16'b0;
    end
end

endmodule
`default_nettype wire
