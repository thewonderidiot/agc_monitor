`timescale 1ns / 1ps

`define CTRL_REG_NHALGA 16'h0

module control_regs(
    input wire clk,
    input wire rst_n,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    input wire read_en,
    input wire write_en,
    output wire [15:0] data_out,
    output reg nhalga
);

reg [15:0] read_data;

assign data_out = read_en ? read_data : 16'b0;

always @(posedge clk) begin
    if (~rst_n) begin
        nhalga <= 1'b0;
    end else if (write_en) begin
        case (addr)
        `CTRL_REG_NHALGA: begin
            nhalga <= data_in[0];
        end
        endcase
    end
end

endmodule
