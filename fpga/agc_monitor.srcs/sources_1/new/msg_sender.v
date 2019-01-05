`timescale 1ns / 1ps
`default_nettype none

module msg_sender(
    input wire clk,
    input wire rst_n,

    // Input message
    input wire [39:0] msg,
    input wire msg_ready,
    output wire sender_ready,

    // Output data
    output reg [7:0] out_byte,
    output wire out_byte_ready,

    // Destination FIFO full flag
    input wire byte_fifo_full
);

/*******************************************************************************.
* FSM States                                                                    *
'*******************************************************************************/
localparam IDLE = 0,
           ACTIVE = 1,
           ESCAPE = 2;

reg [1:0] state;
reg [1:0] next_state;

/*******************************************************************************.
* Status Flags                                                                  *
'*******************************************************************************/
// Sender is idle and ready to begin SLIPping the next message
assign sender_ready = (state == IDLE);
// A newly SLIPped byte is ready to be put into the read byte FIFO
assign out_byte_ready = ((msg_ready) || (state != IDLE)) && (~byte_fifo_full);

/*******************************************************************************.
* Active Message                                                                *
'*******************************************************************************/
// The message actively being processed
reg [39:0] active_msg;
reg [39:0] active_msg_q;

// View into the active message at the byte level
reg [2:0] byte_index;
reg [2:0] byte_index_q;

reg [7:0] cur_byte;
always @(*) begin
    case (byte_index)
    3'd0: cur_byte = active_msg[39:32];
    3'd1: cur_byte = active_msg[31:24];
    3'd2: cur_byte = active_msg[23:16];
    3'd3: cur_byte = active_msg[15:8];
    3'd4: cur_byte = active_msg[7:0];
    default: cur_byte = 8'b0;
    endcase
end

/*******************************************************************************.
* Message Sender State Machine                                                  *
'*******************************************************************************/
always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
        byte_index <= 3'b0;
        active_msg <= 40'b0;
    end else begin
        state <= next_state;
        byte_index <= byte_index_q;
        active_msg <= active_msg_q;
    end
end

always @(*) begin
    next_state = state;
    byte_index_q = byte_index;
    out_byte = cur_byte;
    active_msg_q = active_msg;

    if (~byte_fifo_full) begin
        case (state)
        IDLE: begin
            if (msg_ready) begin
                // A new message is ready. Latch it, emit the leading END
                // byte, and proceed to ACTIVE.
                next_state = ACTIVE;
                out_byte = `SLIP_END;
                byte_index_q = 3'b0;
                active_msg_q = msg;
            end
        end

        ACTIVE: begin
            if (byte_index == `MSG_WRITE_LENGTH) begin
                // We've run out of bytes in the current message. Emit the
                // trailing END and go back to IDLE.
                next_state = IDLE;
                out_byte = `SLIP_END;
            end else if ((cur_byte == `SLIP_END) || (cur_byte == `SLIP_ESC)) begin
                // This next byte needs to be escaped. Without incrementing
                // the byte index, emit an ESCAPE byte and go to ESCAPE.
                next_state = ESCAPE;
                out_byte = `SLIP_ESC;
            end else begin
                // Regular byte -- simply pass it through and go to the next
                byte_index_q = byte_index + 1;
            end
        end

        ESCAPE: begin
            // Emit the escaped version of the current byte, increment the
            // byte index, and go back to ACTIVE for the next
            if (cur_byte == `SLIP_END) begin
                out_byte = `SLIP_ESC_END;
            end else begin
                out_byte = `SLIP_ESC_ESC;
            end
            next_state = ACTIVE;
            byte_index_q = byte_index + 1;
        end

        endcase
    end
end

endmodule
`default_nettype wire
