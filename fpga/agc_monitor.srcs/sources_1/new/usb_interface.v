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
    output wire siwu,
    output wire [39:0] cmd,
    output wire cmd_ready,
    input wire cmd_read_en
);

localparam IDLE  = 0,
           READ1 = 1,
           READ2 = 2,
           WRITE = 3;

assign siwu = 1'b1;

wire rx_data_ready;
wire [39:0] cmd_in;

cmd_receiver cmd_rx(
    .clk(clkout),
    .rst_n(rst_n),
    .data(data),
    .data_ready(rx_data_ready),
    .cmd_valid(cmd_valid),
    .cmd_msg(cmd_in)
);

wire cmd_fifo_empty;
assign cmd_ready = ~cmd_fifo_empty;

wire cmd_fifo_full;

cmd_fifo cmd_queue(
    .rst(~rst_n),
    .wr_clk(clkout),
    .rd_clk(clk),
    .din(cmd_in),
    .wr_en(cmd_valid),
    .rd_en(cmd_read_en),
    .dout(cmd),
    .full(cmd_fifo_full), 
    .empty(cmd_fifo_empty),
    .wr_rst_busy(),
    .rd_rst_busy()
);

reg [1:0] state;
reg [1:0] next_state;

assign rx_data_ready = (state == READ2);

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

always @(*) begin
    oe_n_q = 1'b1;
    rd_n_q = 1'b1;
    wr_n_q = 1'b1;

    case (state)
    IDLE: begin
        if ((~cmd_fifo_full) & (~rxf_n)) begin
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
