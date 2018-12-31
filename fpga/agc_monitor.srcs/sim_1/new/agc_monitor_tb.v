`timescale 1ns / 1ps

module agc_monitor_tb();

reg clk;
reg rst_n;
wire led;

reg clkout;
wire [7:0] data;
reg rxf_n;
reg txe_n;
wire rd_n;
wire wr_n;
wire oe_n;
wire siwu;
reg [7:0] data_in;
wire [39:0] cmd_out;
wire cmd_ready;

always #16.667 clkout = ~clkout;
always #10 clk = ~clk;

assign data = (~rd_n) ? data_in : 8'bZ;

agc_monitor agc_mon(
    .clk(clk),
    .rst_n(rst_n),
    .led(led),

    .clkout(clkout),
    .data(data),
    .rxf_n(rxf_n),
    .txe_n(txe_n),
    .rd_n(rd_n),
    .wr_n(wr_n),
    .oe_n(oe_n),
    .siwu(siwu)
);

initial begin
    $display($time, "<< Starting simulation >>");
    clk = 1'b0;
    rst_n = 1'b0;
    clkout = 1'b0;
    rxf_n = 1'b1;
    txe_n = 1'b1;
    data_in = 8'h00;
    
    #20 rst_n = 1'b1;
    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h80;
    @(posedge clkout) data_in = 8'h12;
    @(posedge clkout) data_in = 8'h34;
    @(posedge clkout) data_in = 8'h56;
    @(posedge clkout) data_in = 8'h78;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h02;
    @(posedge clkout) data_in = 8'hDB;
    @(posedge clkout) data_in = 8'hDC;
    @(posedge clkout) data_in = 8'hDB;
    @(posedge clkout) data_in = 8'hDD;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h05;
    @(posedge clkout) data_in = 8'hDB;
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'hDB;
    @(posedge clkout) data_in = 8'hDD;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h06;
    @(posedge clkout) data_in = 8'h2A;
    @(posedge clkout) data_in = 8'h3B;
    @(posedge clkout) data_in = 8'h4C;
    @(posedge clkout) data_in = 8'h5D;
    @(posedge clkout) data_in = 8'h6E;
    @(posedge clkout) data_in = 8'h7F;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #1000 $finish;
end


endmodule
