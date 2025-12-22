module vga_timing (
    input  logic clk,           // 25.175 MHz pixel clock
    input  logic rst,           // Reset
    output logic [9:0] px,      // Pixel X coordinate
    output logic [9:0] py,      // Pixel Y coordinate  
    output logic hsync,         // Horizontal sync
    output logic vsync,         // Vertical sync
    output logic de,            // Display enable (visible area)
    output logic frame          // Pulse at frame start
);

    // VGA 640x480 @ 60Hz timing
    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK; // 800
    
    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK; // 525

    // Pixel counters
    always_ff @(posedge clk) begin
        if (rst) begin
            px <= 0;
            py <= 0;
        end else begin
            if (px == H_TOTAL - 1) begin
                px <= 0;
                py <= (py == V_TOTAL - 1) ? 0 : py + 1;
            end else begin
                px <= px + 1;
            end
        end
    end
    
    // Sync pulses (negative polarity)
    assign hsync = ~((px >= H_VISIBLE + H_FRONT) && 
                     (px < H_VISIBLE + H_FRONT + H_SYNC));
    assign vsync = ~((py >= V_VISIBLE + V_FRONT) && 
                     (py < V_VISIBLE + V_FRONT + V_SYNC));
    
    // Display enable (active during visible area)
    assign de = (px < H_VISIBLE) && (py < V_VISIBLE);
    
    // Frame pulse at start
    assign frame = (px == 0) && (py == 0);

endmodule