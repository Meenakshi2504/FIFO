`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2026 15:31:46
// Design Name: 
// Module Name: FIFO_RD
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


module FIFO_RD #(
    parameter DEPTH = 8
)(
    input wire R_CLK,
    input wire R_RST,
    input wire R_INC,

    input wire [$clog2(DEPTH):0] W_PTR_GRAY_SYNC,

    output wire [$clog2(DEPTH)-1:0] R_ADDR,
    output reg  [$clog2(DEPTH):0] R_PTR_BIN,
    output reg [$clog2(DEPTH):0] R_PTR_GRAY,
    output reg EMPTY
);
    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam PTR_WIDTH  = ADDR_WIDTH + 1;
    
    reg [PTR_WIDTH-1:0] R_PTR_BIN_NEXT;
    reg [PTR_WIDTH-1:0] R_PTR_GRAY_NEXT;
    reg [PTR_WIDTH-1:0] W_PTR_BIN;

    integer i;
    always@(*)begin
            W_PTR_BIN[$clog2(DEPTH)] = W_PTR_GRAY_SYNC[$clog2(DEPTH)];

            for (i = $clog2(DEPTH)-1; i >= 0; i = i - 1) begin
                W_PTR_BIN[i] = W_PTR_BIN[i+1] ^ W_PTR_GRAY_SYNC[i];
end
    end
    
    always @(*) begin

        if (R_INC && !EMPTY)
            R_PTR_BIN_NEXT = R_PTR_BIN + 1'b1;
        else
            R_PTR_BIN_NEXT = R_PTR_BIN;

    end
 always @(*) begin

        R_PTR_GRAY_NEXT = R_PTR_BIN_NEXT ^
                          (R_PTR_BIN_NEXT >> 1);

    end
    
     always @(posedge R_CLK or negedge R_RST) begin

        if (!R_RST) begin
            R_PTR_BIN  <= 0;
            R_PTR_GRAY <= 0;
        end

        else begin
            R_PTR_BIN  <= R_PTR_BIN_NEXT;
            R_PTR_GRAY <= R_PTR_GRAY_NEXT;
        end

    end
    
    assign R_ADDR = R_PTR_BIN[ADDR_WIDTH-1:0];
    
    always @(posedge R_CLK or negedge R_RST) begin

        if (!R_RST)
            EMPTY <= 1'b1;

        else
            EMPTY <= (R_PTR_BIN_NEXT[PTR_WIDTH-1:0] == W_PTR_BIN[PTR_WIDTH-1:0]);       
end
    
endmodule