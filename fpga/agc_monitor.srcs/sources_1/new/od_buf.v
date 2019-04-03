`timescale 1ns / 1ps
`default_nettype none

module od_buf(
    input  wire [WIDTH:1] a,
    output wire [WIDTH:1] y
);

parameter WIDTH = 1;

genvar i;
generate
for (i = 1; i <= WIDTH; i = i + 1) begin
    assign y[i] = a[i] ? 1'bZ : 1'b0;
end
endgenerate

endmodule
`default_nettype wire
