module DATA_SYNC_1 #(
    parameter BUS_WIDTH = 8
)(
    input  wire [BUS_WIDTH-1:0] Unsync_bus,
    input  wire                  CLK,
    input  wire                  RST,
    output wire [BUS_WIDTH-1:0]  Sync_bus
);

    reg [BUS_WIDTH-1:0] sync_reg1;
    reg [BUS_WIDTH-1:0] sync_reg2;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            sync_reg1 <= 0;
            sync_reg2 <= 0;
        end
        else begin
            sync_reg1 <= Unsync_bus;
            sync_reg2 <= sync_reg1;
        end
    end

    assign Sync_bus = sync_reg2;

endmodule