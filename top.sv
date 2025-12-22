module top (
    input  logic clk,
    input  logic rst,
    
    output logic [9:0] sx,
    output logic [9:0] sy,
    output logic de,
    output logic [7:0] sdl_r,
    output logic [7:0] sdl_g,
    output logic [7:0] sdl_b, 
    output logic signed [21:0] edge_abp, edge_bcp, edge_cap
);

    // Signals between modules
    logic [9:0] px, py;
    logic hsync, vsync;
    logic frame;
    logic [3:0] r4, g4, b4;
    
    // VGA timing generator
    vga_timing vga (
        .clk(clk),
        .rst(rst),
        .px(px),
        .py(py),
        .hsync(hsync),
        .vsync(vsync),
        .de(de),
        .frame(frame)
    );
    
    rasterizer raster (
        .clk(clk),
        .rst(rst),
        .px(px),
        .py(py),
        .frame(frame),
        .r(r4),
        .g(g4),
        .b(b4), 
        .*
    );
    

    logic [3:0] r_blank, g_blank, b_blank;
    assign r_blank = de ? r4 : 4'h0;
    assign g_blank = de ? g4 : 4'h0;
    assign b_blank = de ? b4 : 4'h0;
    
    assign sdl_r = {r_blank, r_blank};
    assign sdl_g = {g_blank, g_blank};
    assign sdl_b = {b_blank, b_blank};
    
    assign sx = px;
    assign sy = py;

endmodule