`timescale 1ns / 1ps

module agc_monitor_tb();

reg clk;
reg rst_n;

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
reg mnisq;
reg [12:1] mt;
always #976.5625 mt = {mt[11:1], mt[12]};
wire mnhnc;
wire mstp;
reg [3:1] mst;
reg mreqin;
wire mload;

agc_monitor agc_mon(
    .clk(clk),
    .rst_n(rst_n),

    .clkout(clkout),
    .data(data),
    .rxf_n(rxf_n),
    .txe_n(txe_n),
    .rd_n(rd_n),
    .wr_n(wr_n),
    .oe_n(oe_n),
    .siwu(siwu),
    
    .monwt(monwt),
    .mt(mt),
    .mwl(mwl),
    .mst(mst),
    .mwag(mwag),
    .mnisq(mnisq),
    .mstp(mstp),
    .mnhnc(mnhnc),
    .mreqin(mreqin),
    .mload(mload)
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
    mt = 12'b1;
    mwl = 16'o0;
    mwag = 1'b0;
    mnisq = 1'b0;
    mreqin = 1'b0;
    mst = 3'b0;
    
    #20 rst_n = 1'b1;
    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h20;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h05;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h05;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h01;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h20;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h05;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h05;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'h20;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h05;
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
    
    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h01;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h02;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;
    
    #100 mnisq = 1'b1;
    #100 mnisq = 1'b0;
    
    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h03;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;
    
    #400 mnisq = 1'b1;
    #100 mnisq = 1'b0;
    
    #100 mt[1] = 1'b1;
    #100 mt[1] = 1'b0;
    
    #100 mnisq = 1'b1;
    #100 mnisq = 1'b0;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h06;
    @(posedge clkout) data_in = 8'h01;
    @(posedge clkout) data_in = 8'h23;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h11;
    @(posedge clkout) data_in = 8'h56;
    @(posedge clkout) data_in = 8'h78;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h71;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    @(posedge mload);

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h06;
    @(posedge clkout) data_in = 8'h02;
    @(posedge clkout) data_in = 8'h46;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    @(posedge mt[12]) mreqin = 1'b1;
    @(posedge mt[12]) mst = 3'b1;
    @(posedge mt[12]);// mreqin = 1'b0;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h75;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    #100 rxf_n = 1'b0;
    @(negedge oe_n) data_in = 8'hC0;
    @(negedge rd_n);
    @(posedge clkout) data_in = 8'hA0;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h75;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'h00;
    @(posedge clkout) data_in = 8'hC0;
    rxf_n = 1'b1;

    @(posedge mt[12]) mreqin = 1'b1;
    @(posedge mt[12]) mreqin = 1'b1;
    @(posedge mt[12]) mreqin = 1'b0;

    #10000 $finish;
end


endmodule
