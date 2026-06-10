`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.02.2026 10:22:46
// Design Name: 
// Module Name: tb_axis_hmm_classifier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_axis_hmm_classifier;

reg clk;
reg rst;

// AXI INPUT
reg s_axis_tvalid;
wire s_axis_tready;
reg [7:0] s_axis_tdata;

// AXI OUTPUT
wire m_axis_tvalid;
reg m_axis_tready;
wire [1:0] m_axis_tdata;

//////////////////////////////////////////////////
// Instantiate DUT
//////////////////////////////////////////////////

axis_hmm_classifier DUT (
    .clk(clk),
    .rst(rst),

    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tdata(s_axis_tdata),

    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tdata(m_axis_tdata)
);

//////////////////////////////////////////////////
// Clock
//////////////////////////////////////////////////

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//////////////////////////////////////////////////
// Monitor Output
//////////////////////////////////////////////////

always @(posedge clk)
begin
    if(m_axis_tvalid && m_axis_tready)
        $display("Time=%0t Feature=%d Output=%b", $time, s_axis_tdata, m_axis_tdata);
end

//////////////////////////////////////////////////
// Send AXI data task
//////////////////////////////////////////////////

task send_feature;
input [7:0] feature;
begin

    @(posedge clk);
    s_axis_tdata  <= feature;
    s_axis_tvalid <= 1;

    wait(s_axis_tready == 1);

    @(posedge clk);
    s_axis_tvalid <= 0;

    wait(m_axis_tvalid == 1);

    @(posedge clk);

end
endtask

//////////////////////////////////////////////////
// Test Sequence
//////////////////////////////////////////////////

initial begin

    rst = 1;
    s_axis_tvalid = 0;
    s_axis_tdata = 0;

    // VERY IMPORTANT
    m_axis_tready = 1;

    #20;
    rst = 0;

    #20;

    send_feature(20);   // BPSK ? 00
    send_feature(90);   // QPSK ? 01
    send_feature(150);  // QAM  ? 10
    send_feature(220);  // FSK  ? 11

    #100;

    $finish;

end

endmodule
