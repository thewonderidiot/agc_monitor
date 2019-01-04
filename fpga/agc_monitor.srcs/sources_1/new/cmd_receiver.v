`timescale 1ns / 1ps
`default_nettype none

`include "usb_interface_defines.v"

module cmd_receiver(
    input wire clk,
    input wire rst_n,

    // Input bytes
    input wire [7:0] data,
    input wire data_ready,

    // Output commands
    output reg cmd_valid,
    output reg [39:0] cmd_msg
);

/*******************************************************************************.
* FSM States                                                                    *
'*******************************************************************************/
localparam IDLE = 0,
           ACTIVE = 1,
           ESCAPED = 2;

reg [1:0] state;
reg [1:0] next_state;

/*******************************************************************************.
* FSM States                                                                    *
'*******************************************************************************/
// Un-SLIPped data ready for writing to the command being processed, and
// associated validity flag
reg data_valid;
reg [7:0] data_q;

// Current byte index into the command being processed
reg [2:0] write_index;
reg [2:0] write_index_q;

// Expected message length based on the first byte (write commands will have
// the MSB of the first byte set)
wire [2:0] msg_length;
assign msg_length = (cmd_msg[39]) ? `MSG_WRITE_LENGTH : `MSG_READ_LENGTH;

/*******************************************************************************.
* Command Receiver State Machine                                                *
'*******************************************************************************/
always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
        write_index <= 3'd0;
        cmd_msg <= 40'b0;
    end else begin
        state <= next_state;
        write_index <= write_index_q;

        if (state == IDLE) begin
            cmd_msg <= 40'b0;
        end else if (data_valid) begin
            // A byte has been un-SLIPped and is ready for writing
            case (write_index)
            3'd0: cmd_msg[39:32] <= data_q;
            3'd1: cmd_msg[31:24] <= data_q;
            3'd2: cmd_msg[23:16] <= data_q;
            3'd3: cmd_msg[15:8]  <= data_q;
            3'd4: cmd_msg[7:0]   <= data_q;
            endcase
        end
    end
end

always @(*) begin
    next_state = state;
    write_index_q = write_index;
    data_q = 8'h0;
    data_valid = 1'b0;
    cmd_valid = 1'b0;

    if (data_ready) begin
        case (state)
        IDLE: begin
            // Wait in IDLE until we see an END character
            if (data == `SLIP_END) begin
                next_state = ACTIVE;
                write_index_q = 3'd0;
            end
        end

        ACTIVE: begin
            if (data == `SLIP_END) begin
                // We got an END. If we're still at index 0 (i.e., repeated
                // END), ignore it.
                if (write_index != 3'd0) begin
                    next_state = IDLE;
                    // Check to see if the message is the expected length. If
                    // so, declare it valid.
                    if (write_index == msg_length) begin
                        cmd_valid = 1'b1;
                    end
                end
            end else if (write_index < msg_length) begin
                // We've gotten some other byte, and still have room left for
                // it in the current message. Check to see if it's an ESCAPE.
                if (data == `SLIP_ESC) begin
                    // It is; ignore this byte, but move on to the ESCAPE
                    // state so we properly handle the next.
                    next_state = ESCAPED;
                end else begin
                    // This is just a regular byte. Write it into the current
                    // command.
                    data_valid = 1'b1;
                    data_q = data;
                    write_index_q = write_index + 1;
                end
            end else begin
                // We've gotten more bytes than expected for the current
                // command type. Abort this command and wait for the next.
                next_state = IDLE;
            end
        end

        ESCAPED: begin
            next_state = ACTIVE;
            write_index_q = write_index + 1;

            // Unescape whatever byte we've gotten
            if (data == `SLIP_ESC_END) begin
                data_valid = 1'b1;
                data_q = `SLIP_END;
            end else if (data == `SLIP_ESC_ESC) begin
                data_valid = 1'b1;
                data_q = `SLIP_ESC;
            end else begin
                // This isn't a valid escaped byte... abort this command and
                // go wait for the next.
                next_state = IDLE;
            end
        end

        endcase
    end
end

endmodule
`default_nettype wire
