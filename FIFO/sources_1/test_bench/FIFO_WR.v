`timescale 1ns / 1ps

module FIFO_WR #(
    parameter DEPTH = 8
)(
    input  wire                         W_CLK,
    input  wire                         W_RST,
    input  wire                         W_INC,

    // Read pointer synchronized into write clock domain
    input  wire [$clog2(DEPTH):0]       R_PTR_GRAY_SYNC,

    output wire [$clog2(DEPTH)-1:0]     W_ADDR,

    output reg  [$clog2(DEPTH):0]       W_PTR_BIN,
    output reg  [$clog2(DEPTH):0]       W_PTR_GRAY,

    output reg                          FULL
);

    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam PTR_WIDTH  = ADDR_WIDTH + 1;

    // Next-state values
    reg [PTR_WIDTH-1:0] W_PTR_BIN_NEXT;
    reg [PTR_WIDTH-1:0] W_PTR_GRAY_NEXT;
    reg [PTR_WIDTH-1:0] R_PTR_BIN;

    integer i;
    always@(*)begin
            R_PTR_BIN[$clog2(DEPTH)] = R_PTR_GRAY_SYNC[$clog2(DEPTH)];

            for (i = $clog2(DEPTH)-1; i >= 0; i = i - 1) begin
                R_PTR_BIN[i] = R_PTR_BIN[i+1] ^ R_PTR_GRAY_SYNC[i];
end
    end
    // ============================================================
    // 1. Calculate NEXT binary write pointer
    // ============================================================

    always @(*) begin

        if (W_INC && !FULL)
            W_PTR_BIN_NEXT = W_PTR_BIN + 1'b1;
        else
            W_PTR_BIN_NEXT = W_PTR_BIN;

    end


    // ============================================================
    // 2. Convert NEXT binary pointer to NEXT Gray pointer
    // ============================================================

    always @(*) begin

        W_PTR_GRAY_NEXT = W_PTR_BIN_NEXT ^
                          (W_PTR_BIN_NEXT >> 1);

    end


    // ============================================================
    // 3. Sequentially update the CURRENT pointers
    // ============================================================

    always @(posedge W_CLK or negedge W_RST) begin

        if (!W_RST) begin
            W_PTR_BIN  <= 0;
            W_PTR_GRAY <= 0;
        end

        else begin
            W_PTR_BIN  <= W_PTR_BIN_NEXT;
            W_PTR_GRAY <= W_PTR_GRAY_NEXT;
        end

    end


    // ============================================================
    // 4. Generate memory write address
    // ============================================================

    assign W_ADDR = W_PTR_BIN[ADDR_WIDTH-1:0];


    // ============================================================
    // 5. FULL logic
    // ============================================================
    // We will implement this after understanding
    // the Gray-code FULL condition.

    always @(posedge W_CLK or negedge W_RST) begin
    if (!W_RST)
        FULL <= 1'b0;
    else
        FULL <= (W_PTR_GRAY_NEXT ==
                 {~R_PTR_GRAY_SYNC[PTR_WIDTH-1:PTR_WIDTH-2],
                   R_PTR_GRAY_SYNC[PTR_WIDTH-3:0]});
end

endmodule