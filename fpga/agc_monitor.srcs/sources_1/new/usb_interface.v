`timescale 1ns / 1ps

module usb_interface(
    input wire clk,
    input wire rst_n,
    input wire clkout,
    inout wire [7:0] data,
    input wire rxf_n,
    input wire txe_n,
    output reg rd_n,
    output wire wr_n,
    output reg oe_n,
    output wire siwu,
    output wire [39:0] cmd,
    output wire cmd_ready,
    input wire cmd_read_en,
    input wire [39:0] read_msg,
    input wire read_msg_ready
);

localparam IDLE  = 0,
           READ1 = 1,
           READ2 = 2,
           WRITE = 3;

assign siwu = 1'b1;

wire rx_data_ready;
wire [39:0] cmd_in;
wire [39:0] send_msg;
wire sender_ready;
wire read_fifo_ready;
wire read_fifo_empty;
wire [7:0] send_byte;
wire send_byte_ready;
wire read_byte_fifo_full;

assign read_fifo_ready = ~read_fifo_empty;

cmd_receiver cmd_rx(
    .clk(clkout),
    .rst_n(rst_n),
    .data(data),
    .data_ready(rx_data_ready),
    .cmd_valid(cmd_valid),
    .cmd_msg(cmd_in)
);

msg_sender msg_sndr(
    .clk(clk),
    .rst_n(rst_n),
    .msg(send_msg),
    .msg_ready(read_fifo_ready),
    .sender_ready(sender_ready),
    .out_byte(send_byte),
    .out_byte_ready(send_byte_ready),
    .byte_fifo_full(read_byte_fifo_full)
);

wire cmd_fifo_empty;
wire read_fifo_full;
assign cmd_ready = (~cmd_fifo_empty) & (~read_fifo_full);

wire cmd_fifo_full;
wire read_byte_fifo_empty;
wire read_byte_fifo_almost_empty;

wire [7:0] tx_byte;
wire tx_byte_read_en;

assign tx_byte_read_en = ((~wr_n) & (~txe_n));
assign data = (tx_byte_read_en) ? tx_byte : 8'bZ;

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

read_fifo read_msg_queue(
  .clk(clk),
  .srst(~rst_n),
  .din(read_msg),
  .wr_en(read_msg_ready),
  .rd_en(sender_ready),
  .dout(send_msg),
  .full(read_fifo_full),
  .empty(read_fifo_empty)
);

read_byte_fifo read_byte_queue(
    .rst(~rst_n),
    .wr_clk(clk),
    .rd_clk(clkout),
    .din(send_byte),
    .wr_en(send_byte_ready),
    .rd_en(tx_byte_read_en),
    .dout(tx_byte),
    .full(read_byte_fifo_full),
    .empty(read_byte_fifo_empty),
    .almost_empty(read_byte_fifo_almost_empty),
    .wr_rst_busy(),
    .rd_rst_busy()
);

reg [1:0] state;
reg [1:0] next_state;

assign wr_n = (state != WRITE);
assign rx_data_ready = (state == READ2);

reg oe_n_q;
reg rd_n_q;

always @(posedge clkout or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
        oe_n <= 1'b1;
        rd_n <= 1'b1;
    end else begin
        state <= next_state;
        oe_n <= oe_n_q;
        rd_n <= rd_n_q;
    end
end

always @(*) begin
    oe_n_q = 1'b1;
    rd_n_q = 1'b1;

    case (state)
    IDLE: begin
        if ((~cmd_fifo_full) & (~rxf_n)) begin
            next_state = READ1;
            oe_n_q = 1'b0;
        end else if ((~read_byte_fifo_empty) & (~txe_n)) begin
            next_state = WRITE;
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
        if (txe_n | (~rxf_n) | (read_byte_fifo_almost_empty)) begin
            next_state = IDLE;
        end else begin
            next_state = WRITE;
        end
    end
    endcase
end

endmodule
