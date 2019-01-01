`timescale 1ns / 1ps

module msg_sender(
    input wire clk,
    input wire rst_n,
    input wire [39:0] msg,
    input wire msg_ready,
    output wire sender_ready,
    output reg [7:0] out_byte,
    output wire out_byte_ready
);

localparam IDLE = 0,
           ACTIVE = 1,
           ESCAPE = 2;

reg [39:0] active_msg;

reg [1:0] state;
reg [1:0] next_state;

reg [2:0] byte_index;
reg [2:0] byte_index_q;

wire [7:0] msg_bytes[4:0];
wire [7:0] cur_byte;

assign msg_bytes[0] = active_msg[39:32];
assign msg_bytes[1] = active_msg[31:24];
assign msg_bytes[2] = active_msg[23:16];
assign msg_bytes[3] = active_msg[15:8];
assign msg_bytes[4] = active_msg[7:0];

assign cur_byte = (byte_index < `MSG_WRITE_LENGTH) ? msg_bytes[byte_index] : 8'b0;

assign sender_ready = (state == IDLE);
assign out_byte_ready = (msg_ready) || (state != IDLE);

always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
        active_msg <= 40'b0;
        byte_index <= 3'b0;
    end else begin
        state <= next_state;
        byte_index <= byte_index_q;
        if (msg_ready) begin
            active_msg <= msg;
            byte_index <= 3'b0;
        end
    end
end

always @(*) begin
    next_state = state;
    byte_index_q = byte_index;
    out_byte = cur_byte;

    case (state)
    IDLE: begin
        if (msg_ready) begin
            next_state = ACTIVE;
            byte_index_q = 3'b0;
            out_byte = `SLIP_END;
        end
    end

    ACTIVE: begin
        if (byte_index == `MSG_WRITE_LENGTH) begin
            next_state = IDLE;
            out_byte = `SLIP_END;
        end else if ((cur_byte == `SLIP_END) || (cur_byte == `SLIP_ESC)) begin
            next_state = ESCAPE;
            out_byte = `SLIP_ESC;
        end else begin
            byte_index_q = byte_index + 1;
        end
    end

    ESCAPE: begin
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

endmodule
