`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 12:35:40
// Design Name: 
// Module Name: ASYNC_FIFO
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


module ASYNC_FIFO #(
    parameter DEPTH = 8,
    parameter DATA_WIDTH = 8
)(
    input wire W_CLK,
    input wire W_RST,
    input wire W_INC,

    input wire R_CLK,
    input wire R_RST,
    input wire R_INC,

    input wire [DATA_WIDTH-1:0] WR_DATA,
    output wire [DATA_WIDTH-1:0] RD_DATA,

    output wire FULL,
    output wire EMPTY
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    // ------------------------------------------------
    // Internal signals
    // ------------------------------------------------

    // Write side
    wire [ADDR_WIDTH-1:0] W_ADDR;
    wire [ADDR_WIDTH:0] W_PTR_BIN;
    wire [ADDR_WIDTH:0] W_PTR_GRAY;

    // Read side
    wire [ADDR_WIDTH-1:0] R_ADDR;
    wire [ADDR_WIDTH:0] R_PTR_BIN;
    wire [ADDR_WIDTH:0] R_PTR_GRAY;

    // Synchronized pointers
    wire [ADDR_WIDTH:0] R_PTR_GRAY_SYNC;
    wire [ADDR_WIDTH:0] W_PTR_GRAY_SYNC;


    // ------------------------------------------------
    // FIFO WRITE CONTROL
    // ------------------------------------------------

    FIFO_WR #(
        .DEPTH(DEPTH)
    ) write_control (
        .W_CLK(W_CLK),.W_RST(W_RST),.W_INC(W_INC),.R_PTR_GRAY_SYNC(R_PTR_GRAY_SYNC),.W_ADDR(W_ADDR),.W_PTR_BIN(W_PTR_BIN),.W_PTR_GRAY(W_PTR_GRAY),.FULL(FULL)
    );


    // ------------------------------------------------
    // FIFO READ CONTROL
    // ------------------------------------------------

    FIFO_RD #(
        .DEPTH(DEPTH)
    ) read_control (
        .R_CLK(R_CLK),.R_RST(R_RST),.R_INC(R_INC),.W_PTR_GRAY_SYNC(W_PTR_GRAY_SYNC),.R_ADDR(R_ADDR),.R_PTR_BIN(R_PTR_BIN),.R_PTR_GRAY(R_PTR_GRAY),.EMPTY(EMPTY)
    );


    // ------------------------------------------------
    // Synchronize READ pointer into WRITE domain
    // ------------------------------------------------

    DATA_SYNC_1 #(
    .BUS_WIDTH(ADDR_WIDTH + 1)
) SYNC_RPTR (
    .Unsync_bus(R_PTR_GRAY),
    .CLK(W_CLK),
    .RST(W_RST),
    .Sync_bus(R_PTR_GRAY_SYNC)
);

        // ------------------------------------------------
    // Synchronize WRITE pointer into READ domain
    // ------------------------------------------------

   DATA_SYNC_1 #(
    .BUS_WIDTH(ADDR_WIDTH + 1)
) SYNC_WPTR (
    .Unsync_bus(W_PTR_GRAY),
    .CLK(R_CLK),
    .RST(R_RST),
    .Sync_bus(W_PTR_GRAY_SYNC)
);
    

    // ------------------------------------------------
    // FIFO MEMORY
    // ------------------------------------------------

    FIFO_MEM_CNTRL #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo_memory (
      .W_CLK(W_CLK),.R_CLK(R_CLK),.R_RST(R_RST),.W_EN(W_INC && !FULL),
    . W_ADDR(W_ADDR),
    .WR_DATA(WR_DATA),
    .R_EN(R_INC && !EMPTY),
    .R_ADDR(R_ADDR),
    .RD_DATA(RD_DATA)
    );

endmodule
