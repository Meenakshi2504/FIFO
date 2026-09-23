`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2026 14:50:06
// Design Name: 
// Module Name: ASYNC_FIFO_TB
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


module ASYNC_FIFO_TB ();

parameter DEPTH_TB     = 8;
parameter DATA_WIDTH_TB = 8;


//====================================================
// TESTBENCH SIGNALS
//====================================================

reg W_CLK_TB;
reg W_RST_TB;
reg W_INC_TB;

reg R_CLK_TB;
reg R_RST_TB;
reg R_INC_TB;

reg [DATA_WIDTH_TB-1:0] WR_DATA_TB;

wire [DATA_WIDTH_TB-1:0] RD_DATA_TB;

wire FULL_TB;
wire EMPTY_TB;


//====================================================
// DUT
//====================================================

ASYNC_FIFO #(
    .DEPTH(DEPTH_TB),
    .DATA_WIDTH(DATA_WIDTH_TB)
)
DUT (
    .W_CLK(W_CLK_TB),
    .W_RST(W_RST_TB),
    .W_INC(W_INC_TB),

    .R_CLK(R_CLK_TB),
    .R_RST(R_RST_TB),
    .R_INC(R_INC_TB),

    .WR_DATA(WR_DATA_TB),
    .RD_DATA(RD_DATA_TB),

    .FULL(FULL_TB),
    .EMPTY(EMPTY_TB)
);


//====================================================
// WRITE CLOCK
// 100 MHz → 10 ns period
//====================================================

always #5 W_CLK_TB = ~W_CLK_TB;


//====================================================
// READ CLOCK
// 40 MHz → 25 ns period
//====================================================

always #12.5 R_CLK_TB = ~R_CLK_TB;


//====================================================
// TEST
//====================================================

initial begin

    //------------------------------------------------
    // INITIAL VALUES
    //------------------------------------------------

    W_CLK_TB  = 1'b0;
    R_CLK_TB  = 1'b0;

    W_RST_TB  = 1'b0;
    R_RST_TB  = 1'b0;

    W_INC_TB  = 1'b0;
    R_INC_TB  = 1'b0;

    WR_DATA_TB = 8'h00;


    //------------------------------------------------
    // RESET
    //------------------------------------------------

    #30;

    W_RST_TB = 1'b1;
    R_RST_TB = 1'b1;

    $display("--------------------------------------");
    $display("RESET RELEASED");
    $display("--------------------------------------");


    //================================================
    // TEST 1
    // WRITE 4 DATA VALUES
    //================================================

    $display("");
    $display("TEST 1: WRITE 4 VALUES");

    @(negedge W_CLK_TB);

    W_INC_TB  = 1'b1;
    WR_DATA_TB = 8'hA1;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hA2;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hA3;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hA4;

    @(negedge W_CLK_TB);
    W_INC_TB = 1'b0;

    $display("4 values written: A1 A2 A3 A4");


    //================================================
    // WAIT FOR DATA TO CROSS CLOCK DOMAIN
    //================================================

    #60;


    //================================================
    // TEST 2
    // READ THE 4 VALUES
    //================================================

    $display("");
    $display("TEST 2: READ 4 VALUES");

    @(negedge R_CLK_TB);

    R_INC_TB = 1'b1;

    @(negedge R_CLK_TB);

    @(negedge R_CLK_TB);

    @(negedge R_CLK_TB);

    @(negedge R_CLK_TB);

    R_INC_TB = 1'b0;

    $display("4 read operations completed");


    //================================================
    // WAIT
    //================================================

    #60;


    //================================================
    // TEST 3
    // FILL FIFO COMPLETELY
    //================================================

    $display("");
    $display("TEST 3: FILL FIFO");

    @(negedge W_CLK_TB);

    W_INC_TB   = 1'b1;
    WR_DATA_TB = 8'h01;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'h02;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'h03;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'h04;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'h05;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'h06;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'h07;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'h08;

    @(negedge W_CLK_TB);

    W_INC_TB = 1'b0;

    #5;

    if (FULL_TB)
        $display("PASS: FIFO is FULL");
    else
        $display("ERROR: FIFO did not become FULL");


    //================================================
    // TEST 4
    // TRY TO WRITE WHILE FULL
    //================================================

    $display("");
    $display("TEST 4: WRITE WHILE FULL");

    @(negedge W_CLK_TB);

    W_INC_TB   = 1'b1;
    WR_DATA_TB = 8'hFF;

    @(negedge W_CLK_TB);

    W_INC_TB = 1'b0;

    $display("Attempted write of FF while FULL");

    #20;


    //================================================
    // TEST 5
    // READ EVERYTHING
    //================================================

    $display("");
    $display("TEST 5: EMPTY FIFO");

    @(negedge R_CLK_TB);

    R_INC_TB = 1'b1;

    repeat(8)
        @(negedge R_CLK_TB);

    R_INC_TB = 1'b0;

    #50;

    if (EMPTY_TB)
        $display("PASS: FIFO is EMPTY");
    else
        $display("ERROR: FIFO did not become EMPTY");


    //================================================
    // TEST 6
    // TRY TO READ WHILE EMPTY
    //================================================

    $display("");
    $display("TEST 6: READ WHILE EMPTY");

    @(negedge R_CLK_TB);

    R_INC_TB = 1'b1;

    @(negedge R_CLK_TB);

    R_INC_TB = 1'b0;

    $display("Attempted read while EMPTY");


    //================================================
    // TEST 7
    // WRAP-AROUND TEST
    //================================================

    $display("");
    $display("TEST 7: POINTER WRAP-AROUND");

    @(negedge W_CLK_TB);

    W_INC_TB   = 1'b1;
    WR_DATA_TB = 8'hB1;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hB2;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hB3;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hB4;

    @(negedge W_CLK_TB);
    W_INC_TB = 1'b0;

    #80;


    @(negedge R_CLK_TB);

    R_INC_TB = 1'b1;

    repeat(4)
        @(negedge R_CLK_TB);

    R_INC_TB = 1'b0;


    //================================================
    // TEST 8
    // SIMULTANEOUS READ + WRITE
    //================================================

    $display("");
    $display("TEST 8: SIMULTANEOUS READ/WRITE");

    #50;

    W_INC_TB   = 1'b1;
    R_INC_TB   = 1'b1;

    WR_DATA_TB = 8'hC1;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hC2;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hC3;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hC4;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hC5;

    @(negedge W_CLK_TB);
    WR_DATA_TB = 8'hC6;

    @(negedge W_CLK_TB);

    W_INC_TB = 1'b0;


    repeat(8)
        @(negedge R_CLK_TB);

    R_INC_TB = 1'b0;


    //================================================
    // FINISH
    //================================================

    #100;

    $display("");
    $display("--------------------------------------");
    $display("ALL TESTS COMPLETED");
    $display("--------------------------------------");

    $stop;

end

endmodule
