`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2026 12:12:44
// Design Name: 
// Module Name: FIFO_MEM_CNTRL
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

module FIFO_MEM_CNTRL #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8
)(
    input  wire                     W_CLK,
    input  wire                     R_CLK,
    
    input  wire                     R_RST,
    input  wire                     W_EN,
    input  wire [$clog2(DEPTH)-1:0] W_ADDR,
    input  wire [DATA_WIDTH-1:0]    WR_DATA,
    input  wire                     R_EN,
    input  wire [$clog2(DEPTH)-1:0] R_ADDR,
    output reg  [DATA_WIDTH-1:0]    RD_DATA
);

    // Declare your memory array here
    reg [DATA_WIDTH-1:0] MEM [DEPTH-1:0];

    // Write logic here
   always@(posedge W_CLK )begin
          if(W_EN)begin
                MEM[W_ADDR]<=WR_DATA;
          end 
   end 

    // Read logic here
    always @(posedge R_CLK or negedge R_RST) begin
    if (!R_RST)
        RD_DATA <= 0;
    else if (R_EN)
        RD_DATA <= MEM[R_ADDR];
end

endmodule
