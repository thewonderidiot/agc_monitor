`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module erasable_mem_sim(
    input wire clk,
    input wire rst_n,

    input wire read_en,
    input wire write_en,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    output wire [15:0] data_out,

    input wire [7:0] bank_en,

    input wire minkl,
    input wire [12:1] mt,
    input wire msqext,
    input wire [15:10] msq,
    input wire [3:1] mst,
    input wire [11:9] eb,
    input wire [12:1] s,
    input wire [16:1] g,
    input wire mgp_n,
    input wire mrsc,
    input wire mrgg,
    input wire mwg,
    output wire mamu,
    output wire [16:1] mdt,

    input wire int_write_en,
    input wire [11:1] int_addr,
    input wire [16:1] int_data,

    output wire e_cycle_starting,
    output wire [11:1] e_cycle_addr
);

localparam IDLE = 2'o0,
           ACTIVE = 2'o1,
           COMPLETE = 2'o2;

reg [1:0] state;
assign mamu = (state != IDLE);

wire [2:0] bank;
assign bank = e_cycle_addr[11:9];
erasable_addr_decoder(
    .eb(eb),
    .s(s),
    .eaddr(e_cycle_addr)
);

wire dv13764;
assign dv13764 = (~minkl & msqext & (msq[15:11] == `SQ_DV) & (mst > 3'o0) & (mst != 3'o2));

wire io_inst;
assign io_inst = (~minkl & msqext & (msq[15:13] == `SQ_IO) && (msq[12:10] < `IO_RUPT) & (mst != 3'o2));

reg [11:1] writeback_eaddr;

wire erasable_mem_en;
assign erasable_mem_en = read_en | write_en | int_write_en;
wire [15:0] erasable_mem_data;

wire agc_write_en;
assign agc_write_en = mamu & mt[11];

wire [11:1] agc_addr;
assign agc_addr = mamu ? writeback_eaddr : e_cycle_addr;

wire [16:1] agc_data_in;
assign agc_data_in = {g[16], g[14:1], ~mgp_n};

wire [16:1] agc_data_out;

erasable_sim_mem core_mem(
    .clka(clk),
    .ena(erasable_mem_en),
    .wea(write_en | int_write_en),
    .addra(int_write_en ? int_addr : addr[10:0]),
    .dina(int_write_en ? int_data : data_in),
    .douta(erasable_mem_data),

    .clkb(clk),
    .web(agc_write_en),
    .addrb(agc_addr),
    .dinb(agc_data_in),
    .doutb(agc_data_out)
);

wire [16:1] mdt_wg;
wire [16:1] mdt_rg;
wire [16:1] e_data;

reg [16:1] read_word;
assign e_data = {read_word[16], read_word[16], read_word[15:2]};

wire [16:1] unedited;
unedit unediting(
    .s(s),
    .mwl(e_data),
    .unedited(unedited)
);

assign mdt_wg = ((state == ACTIVE) & mrsc & mwg) ? unedited : 16'o0;
assign mdt_rg = ((state == ACTIVE) & mrgg) ? e_data : 16'o0;

assign mdt = mdt_wg | mdt_rg;

reg mrgg_p;

assign e_cycle_starting = mt[2] && (~dv13764) && (~io_inst) && (s >= `ERASABLE_BASE_ADDR) && (s < `FIXED_BASE_ADDR);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
        read_word <= 16'o0;
        writeback_eaddr <= 11'o0;
        mrgg_p <= 1'b0;
    end else begin
        case (state)
        IDLE: begin
            if (bank_en[bank] && e_cycle_starting) begin
                writeback_eaddr <= e_cycle_addr;
                read_word <= agc_data_out;
                state <= ACTIVE;
            end
        end

        ACTIVE: begin
            if (mrgg_p & (~mrgg)) begin
                state <= COMPLETE;
            end else if (mt[12]) begin
                state <= IDLE;
            end
        end

        COMPLETE: begin
            if (mt[12]) begin
                state <= IDLE;
            end
        end

        endcase

        mrgg_p <= mrgg;
    end
end

reg read_done;
assign data_out = read_done ? erasable_mem_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_done <= 1'b0;
    end else begin
        read_done <= read_en;
    end
end

endmodule
`default_nettype wire
