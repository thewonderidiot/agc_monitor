`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module monitor_regs(
    input wire clk,
    input wire rst_n,

    input wire [12:1] mt,
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
    input wire mrulog,
    input wire mrgg,
    input wire mwch,
    input wire mrch,

    input wire inhibit_ws,
    input wire rbbk,
    input wire s_only,
    input wire adv_s,

    input wire msqext,
    input wire [15:10] msq,
    input wire [3:1] mst,
    input wire [2:1] mbr,

    input wire mgojam,
    input wire mstpit_n,
    input wire miip,
    input wire minhl,
    input wire minkl,
    input wire mnisq,
    input wire msp,
    input wire mgp_n,

    input wire mstp,

    input wire s1_match,
    input wire s2_match,
    input wire i_match,

    input wire [2:0] w_mode,
    input wire w_s1_s2,
    input wire [12:1] w_times,
    input wire [11:0] w_pulses,

    output wire [16:1] l,
    output wire [16:1] q,
    output wire [12:1] s,
    output wire [11:9] eb,
    output wire [15:11] fb,

    output wire [16:1] w,
    output reg [1:0] wp,
    output wire [12:1] i,

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
register2 #(3) reg_eb(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg1(mwebg),
    .mwl1(mwl[11:9]),
    .mwg2(mwbbeg | (rbbk & s_only)),
    .mwl2(mwl[3:1]),
    .val(eb)
);

// Register FB
register #(5) reg_fb(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwfbg | (rbbk & s_only)),
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

reg s_adv_pending;
reg [1:0] monwt_sr;
reg mws_adv;
reg [12:1] next_s;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        s_adv_pending <= 1'b0;
        monwt_sr <= 2'b0;
        mws_adv <= 1'b0;
        next_s <= 12'b0;
    end else begin
        monwt_sr <= {monwt_sr[0], monwt};
        if (adv_s) begin
            s_adv_pending <= 1'b1;
            next_s <= s + 1;
        end else if (s_adv_pending) begin
            if (monwt_sr == 1'b01) begin
                mws_adv <= 1'b1;
            end else if ((monwt_sr == 1'b10) & mws_adv) begin
                mws_adv <= 1'b0;
                s_adv_pending <= 1'b0;
            end
        end
    end
end

// Register S
register2 #(12) reg_s(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg1(mwsg & ~inhibit_ws),
    .mwl1(mwl[12:1]),
    .mwg2(mws_adv),
    .mwl2(next_s),
    .val(s)
);

// Register G
wire [16:1] mwl_edited;
edit editing(
    .clk(clk),
    .rst_n(rst_n),
    .mt02(mt[2]),
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

reg [1:0] gp;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        gp <= 2'b0;
    end else if (mrgg) begin
        gp <= {msp, ~mgp_n};
    end
end

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
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sq <= 6'o0;
    end else if (~(mstp & monwt)) begin
        // Filter out transient 0's caused by CSQG during MSTP
        sq <= msq;
    end
end

reg [2:1] br;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        br <= 2'b0;
    end else begin
        if (mt & w_times) begin
            br <= mbr;
        end
    end
end

reg [3:1] st;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        st <= 3'b0;
    end else begin
        if (~mt[12]) begin
            st <= mst;
        end
    end
end

assign i = {br, st, msqext, sq};

// Register W
wire [23:0] w_conds;
wire [23:0] agc_pulses;

assign w_conds = {w_times, w_pulses};
assign agc_pulses = {mt, 1'b0, 1'b0, mrulog, mwyg, mwbg, (mwg | mrgg), mwch, mrch, mwzg, mwqg, mwlg, mwag};

wire pulse_or_match;
wire pulse_and_match;

assign pulse_or_match = (w_conds & agc_pulses) != 24'b0;
assign pulse_and_match = (~w_conds | agc_pulses) == 24'hFFFFFF;

wire s_match;
assign s_match = (w_s1_s2 ? s2_match : s1_match);

reg p_match;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        p_match <= 1'b0;
    end else begin
        if ((w_mode == `W_MODE_P) & s1_match) begin
            p_match <= 1'b1;
        end else if (mnisq) begin
            p_match <= 1'b0;
        end
    end
end


reg mwwg;
always @(*) begin
    case (w_mode)
    `W_MODE_ALL: mwwg = pulse_or_match;
    `W_MODE_S:   mwwg = s_match & pulse_and_match;
    `W_MODE_I:   mwwg = i_match & pulse_and_match;
    `W_MODE_S_I: mwwg = s_match & i_match & pulse_and_match;
    `W_MODE_P:   mwwg = p_match & pulse_and_match;
    `W_MODE_P_I: mwwg = p_match & i_match & pulse_and_match;
    `W_MODE_P_S: mwwg = p_match & s_match & pulse_and_match;
    default:     mwwg = 1'b0;
    endcase
end

register reg_w(
    .clk(clk),
    .rst_n(rst_n),
    .ct(ct),
    .mwg(mwwg),
    .mwl(mwl),
    .val(w)
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        wp <= 2'b0;
    end else if (mrgg & w_pulses[`W_PULSE_G]) begin
        wp <= {msp, ~mgp_n};
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
        `MON_REG_W:      data_out = w;
        `MON_REG_I:      data_out = {4'b0, i};
        `MON_REG_STATUS: data_out = {11'b0, minkl, minhl, miip, mstpit_n, mgojam}; // FIXME: add OUTCOM
        `MON_REG_PAR:    data_out = {12'b0, wp, gp};
        default:         data_out = 16'b0;
        endcase
    end else begin
        data_out = 16'b0;
    end
end

endmodule
`default_nettype wire
