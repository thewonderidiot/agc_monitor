`timescale 1ns / 1ps

module agc_monitor(
    input wire clk,
    input wire rstn,
    output wire led
);

reg [31:0] counter;
assign led = counter[16];

always @(posedge clk) begin
    if (~rstn) begin
        counter <= 32'b0;
    end else begin
        counter <= counter + 1;
    end
end

endmodule
