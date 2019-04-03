`timescale 1ns/1ps
`default_nettype none

module crs(
    input wire clk,
    input wire rst_n,

    input wire [12:1] mt,
    input wire msqext,
    input wire [15:10] sq,
    input wire [3:1] mst,
    input wire [15:11] fb,
    input wire [7:5] fext,
    input wire [16:1] z,

    output reg [16:1] t3rupt_rsm_faddr,
    output reg [16:1] t4rupt_rsm_faddr
);

localparam IDLE = 2'd0,
           T3RUPT = 2'd1,
           T4RUPT = 2'd2;

reg [1:0] state;
reg [1:0] next_state;

wire [16:1] current_faddr;
fixed_addr_decoder current_ddr_decoder(
    .s(z-1),
    .fb(fb),
    .fext(fext),
    .faddr(current_faddr)
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
        t3rupt_rsm_faddr <= 16'b0;
        t4rupt_rsm_faddr <= 16'b0;
    end else begin
        state <= next_state;
        t3rupt_rsm_faddr <= t3rupt_rsm_faddr_q;
        t4rupt_rsm_faddr <= t4rupt_rsm_faddr_q;
    end
end

always @(*)
    next_state = state;
    t3rupt_rsm_faddr_q = t3rupt_rsm_faddr;
    t4rupt_rsm_faddr_q = t4rupt_rsm_faddr;
    case (state)
    IDLE: begin
        if (mt[5] & sqext & (sq == `SQ_RUPT) & (mst == 3'd1)) begin
            if (z == `T3RUPT_ADDR) begin
                next_state = T3RUPT;
            end else if (z == `T4RUPT_ADDR) begin
                next_state = T4RUPT;
            end
        end
    end

    T3RUPT: begin
        if (mt[2] & ~sqext & (sq == `SQ_RESUME) & (s == `BRUPT)) begin
            next_state = IDLE;
            t3rupt_rsm_faddr_q = current_faddr;
        end
    end

    T4RUPT: begin
        if (mt[2] & ~sqext & (sq == `SQ_RESUME) & (s == `BRUPT)) begin
            next_state = IDLE;
            t4rupt_rsm_faddr_q = current_faddr;
        end
    end

    endcase
end

endmodule
`default_nettype wire
