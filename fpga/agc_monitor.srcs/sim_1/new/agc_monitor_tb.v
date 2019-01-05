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

always #8.333 clkout = ~clkout;
always #5 clk = ~clk;

assign data = (~rd_n) ? data_in : 8'bZ;

reg monwt;
always #488.28125 monwt = ~monwt;

reg [16:1] mwl;
reg mwag;

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
    .siwu(siwu),
    
    .monwt(monwt),
    .mwl(mwl),
    .mwag(mwag)
);

initial begin
    $display($time, "<< Starting simulation >>");
    clk = 1'b0;
    rst_n = 1'b0;
    clkout = 1'b0;
    rxf_n = 1'b1;
    txe_n = 1'b0;
    data_in = 8'h00;
    
    monwt = 1'b0;
    mwl = 16'o0;
    mwag = 1'b0;
    
    #20 rst_n = 1'b1;
    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h20;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h01;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h20;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h20;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;
    
    #200 txe_n = 1'b1;
    #200 txe_n = 1'b0;
    
    mwl = 16'o123456;
    @(posedge monwt);
    #18 mwag = 1'b1;
    #360 mwag = 1'b0;
    
    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h21;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;   

    #1000 $finish;
end


endmodule
