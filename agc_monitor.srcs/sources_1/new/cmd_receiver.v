`timescale 1ns / 1ps

`include "usb_interface_defines.v"

module cmd_receiver(
    input wire clk,
    input wire rst_n,
    input wire [7:0] data,
    input wire data_ready
);

localparam IDLE = 0,
           ACTIVE = 1,
           ESCAPED = 2;

reg [1:0] state;
reg [1:0] next_state;
reg [7:0] msg_bytes[4:0];
reg [7:0] data_q;
reg [2:0] write_index_q;
reg [2:0] write_index;
reg msg_valid;
reg data_valid;

wire [39:0] msg;
assign msg = {msg_bytes[0], msg_bytes[1], msg_bytes[2], msg_bytes[3], msg_bytes[4]};

wire [2:0] msg_length;
assign msg_length = (msg_bytes[0][7]) ? `MSG_WRITE_LENGTH : `MSG_READ_LENGTH;

integer i;

always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
        for (i = 0; i < `MSG_WRITE_LENGTH; i = i+1) msg_bytes[i] <= 8'b0;
        write_index <= 3'd0;
    end else begin
        state <= next_state;
        write_index <= write_index_q;
        if (data_valid) begin
            msg_bytes[write_index] <= data_q;
        end

        if (msg_valid) begin
            for (i = 0; i < `MSG_WRITE_LENGTH; i = i+1) msg_bytes[i] <= 8'b0;
        end
    end
end

always @(*) begin
    next_state = state;
    write_index_q = write_index;
    data_q = 8'h0;
    data_valid = 1'b0;
    msg_valid = 1'b0;

    if (data_ready) begin
        case (state)
        IDLE: begin
            if (data == `SLIP_END) begin
                next_state = ACTIVE;
                write_index_q = 3'd0;
            end
        end

        ACTIVE: begin
            if (data == `SLIP_END) begin
                if (write_index != 3'd0) begin
                    next_state = IDLE;
                    if (write_index == msg_length) begin
                        msg_valid = 1'b1;
                    end
                end
            end else if (write_index < msg_length) begin
                if (data == `SLIP_ESC) begin
                    next_state = ESCAPED;
                end else begin
                    data_valid = 1'b1;
                    data_q = data;
                    write_index_q = write_index + 1;
                end
            end else begin
                next_state = IDLE;
            end
        end

        ESCAPED: begin
            next_state = ACTIVE;
            write_index_q = write_index + 1;
            if (data == `SLIP_ESC_END) begin
                data_valid = 1'b1;
                data_q = `SLIP_END;
            end else if (data == `SLIP_ESC_ESC) begin
                data_valid = 1'b1;
                data_q = `SLIP_ESC;
            end else begin
                next_state = IDLE;
            end
        end

        endcase
    end
end

endmodule
