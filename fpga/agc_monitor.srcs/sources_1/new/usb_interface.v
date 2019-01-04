`timescale 1ns / 1ps
`default_nettype none

module usb_interface(
    input wire clk,
    input wire rst_n,
    
    // FT2232H signals
    input wire clkout,
    inout wire [7:0] data,
    input wire rxf_n,
    input wire txe_n,
    output wire rd_n,
    output wire wr_n,
    output wire oe_n,
    output wire siwu,

    // Incoming command outputs
    output wire [39:0] cmd,
    output wire cmd_ready,
    input wire cmd_read_en,

    // Outgoing message inputs
    input wire [39:0] read_msg,
    input wire read_msg_ready
);

/*******************************************************************************.
* FSM States                                                                    *
'*******************************************************************************/
localparam IDLE  = 0,
           READ1 = 1,
           READ2 = 2,
           WRITE = 3;

reg [1:0] state;
reg [1:0] next_state;

/*******************************************************************************.
* FT2232H Control Signals                                                       *
'*******************************************************************************/
// SIWU is unused, so just hold it high
assign siwu = 1'b1;
assign wr_n = (state != WRITE);
assign oe_n = ~((state == READ1) | (state == READ2));
assign rd_n = (state != READ2);

/*******************************************************************************.
* Command Receiver                                                              *
'*******************************************************************************/
// As long as we are in READ2, new RX data is available from the chip
wire rx_data_ready;
assign rx_data_ready = (state == READ2);

// Upon completion of a valid command, the receiver will assert cmd_valid and
// output the command on cmd_in. This will place the command onto the incoming
// command FIFO.
wire cmd_valid;
wire [39:0] cmd_in;

// Command FIFO state flags 
wire cmd_fifo_full;
wire cmd_fifo_empty;

// Command readiness flag for the user of this interface. This is also
// predicated on the read message FIFO not being full, since accepting
// a command could potentially trigger generation of a new read response
// message before that queue can be emptied.
wire read_fifo_full;
assign cmd_ready = (~cmd_fifo_empty) & (~read_fifo_full);

// Command receiver
cmd_receiver cmd_rx(
    .clk(clkout),
    .rst_n(rst_n),
    .data(data),
    .data_ready(rx_data_ready),
    .cmd_valid(cmd_valid),
    .cmd_msg(cmd_in)
);

// Queue of completed incoming commands
cmd_fifo cmd_queue(
    .rst(~rst_n),
    .wr_clk(clkout),
    .rd_clk(clk),
    .din(cmd_in),
    .wr_en(cmd_valid),
    .rd_en(cmd_read_en),
    .dout(cmd),
    .full(cmd_fifo_full), 
    .empty(cmd_fifo_empty)
);

/*******************************************************************************.
* Read Message Sender                                                           *
'*******************************************************************************/
// Read message sending takes place in three stages:
//  1. Read message FIFO -- queue of complete messages that are ready to be
//     sent out, as constructed by the user of this interface.
//  2. Message sender -- a state machine that pops messages off of the read
//     message FIFO as available and SLIPs them into a stream of bytes
//  3. Read byte FIFO -- a byte-by-byte queue of SLIP-encoded messages that is
//     read by the USB interface state machine to transmit bytes

// Signal to read message FIFO that the message sender is ready for data
wire sender_ready;
// Data from read message FIFO to the message sender
wire [39:0] send_msg;

// Read message FIFO status flags
wire read_fifo_empty;
wire read_fifo_ready;
assign read_fifo_ready = ~read_fifo_empty;

// SLIP-encoded byte output from message sender and its validity flag
wire send_byte_ready;
wire [7:0] send_byte;

// Read byte FIFO status flags
wire read_byte_fifo_full;
wire read_byte_fifo_empty;
wire read_byte_fifo_almost_empty;

// Output byte from the read byte FIFO to the USB interface
wire [7:0] tx_byte;
wire tx_byte_read_en;
assign tx_byte_read_en = ((~wr_n) & (~txe_n));
assign data = (tx_byte_read_en) ? tx_byte : 8'bZ;

// Read message FIFO
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

// Message sender
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

// Read byte FIFO
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
    .almost_empty(read_byte_fifo_almost_empty)
);

/*******************************************************************************.
* USB Interface State Machine                                                   *
'*******************************************************************************/
always @(posedge clkout or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;

    case (state)
    IDLE: begin
        if ((~cmd_fifo_full) & (~rxf_n)) begin
            // If we have room for command bytes and there is some available,
            // kick off a read. READ1 will assert OE#, and READ2 will assert
            // RD# and actually clock out the data.
            next_state = READ1;
        end else if ((~read_byte_fifo_empty) & (~txe_n)) begin
            // If we have data to send and the chip has room to accept it,
            // kick off a write
            next_state = WRITE;
        end
    end

    READ1: begin
        if (rxf_n) begin
            // Somehow the data was lost before we had a chance to read it. Go
            // back to IDLE.
            next_state = IDLE;
        end else begin
            next_state = READ2;
        end
    end

    READ2: begin
        if (rxf_n | cmd_fifo_full) begin
            // Continue reading bytes until we've either got it all, or our
            // command FIFO is full
            next_state = IDLE;
        end
    end

    WRITE: begin
        if (txe_n | (~rxf_n) | (read_byte_fifo_almost_empty)) begin
            // Continue writing until 
            next_state = IDLE;
        end
    end
    endcase
end

endmodule
`default_nettype wire
