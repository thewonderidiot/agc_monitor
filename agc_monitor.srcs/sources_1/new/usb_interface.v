`timescale 1ns / 1ps

module usb_interface(
    input wire clk,
    input wire rst_n,
    input wire clkout,
    inout wire [7:0] data,
    input wire rxf_n,
    input wire txe_n,
    output reg rd_n,
    output reg wr_n,
    output reg oe_n,
    output wire siwu
);

localparam IDLE  = 0,
           READ1 = 1,
           READ2 = 2,
           WRITE = 3;

assign siwu = 1'b1;

reg [1:0] state;

cmd_receiver cmd_rx(
    .clk(clkout),
    .rst_n(rst_n),
    .data(data),
    .data_ready(state == READ2)
);

reg [1:0] next_state;

reg oe_n_q;
reg rd_n_q;
reg wr_n_q;

always @(posedge clkout or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
        oe_n <= 1'b1;
        rd_n <= 1'b1;
        wr_n <= 1'b1;
    end else begin
        state <= next_state;
        oe_n <= oe_n_q;
        rd_n <= rd_n_q;
        wr_n <= wr_n_q;
    end
end

always @(state, rxf_n, txe_n) begin
    oe_n_q = 1'b1;
    rd_n_q = 1'b1;
    wr_n_q = 1'b1;

    case (state)
    IDLE: begin
        if (~rxf_n) begin
            next_state = READ1;
            oe_n_q = 1'b0;
        end else if (~txe_n) begin
            next_state = WRITE;
            wr_n_q = 1'b0;
        end else begin
            next_state = IDLE;
        end
    end

    READ1: begin
        if (rxf_n) begin
            next_state = IDLE;
        end else begin
            next_state = READ2;
            oe_n_q = 1'b0;
            rd_n_q = 1'b0;
        end
    end

    READ2: begin
        if (rxf_n) begin
            next_state = IDLE;
        end else begin
            next_state = READ2;
            oe_n_q = 1'b0;
            rd_n_q = 1'b0;
        end
    end

    WRITE: begin
        next_state = IDLE;
    end
    endcase
end

endmodule
