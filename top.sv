`include "graphics_type.sv"

module top (
    input  logic clk,
    input  logic rst,
    output logic [9:0] sx, sy,
    output logic de,
    output logic [7:0] sdl_r, sdl_g, sdl_b
);

    // VGA signals
    logic [9:0] px, py;
    logic hsync, vsync, frame;
    logic [3:0] r4, g4, b4;
    
    // Rotation angles
    logic signed [15:0] angle_x, angle_y, angle_z;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            angle_x <= 0;
            angle_y <= 0;
            angle_z <= 0;
        end else if (frame) begin
            angle_x <= angle_x + 16'd5;
            angle_y <= angle_y + 16'd5;
            angle_z <= angle_z + 16'd5;
        end
    end
    
    // Scene objects
    vertex_3d_t cube_verts_3d[0:7];
    triangle_t cube_triangles[0:11];
    
    scene_objects scene (
        .cube_vertices(cube_verts_3d),
        .cube_triangles(cube_triangles)
    );
    
    // Rotated and projected vertices
    vertex_3d_t cube_verts_rotated[0:7];
    vertex_2d_t cube_verts_2d[0:7];
    
    // Rotate all vertices
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : rotate_vertices
            rotation_engine rot (
                .v_in(cube_verts_3d[i]),
                .angle_x(angle_x),
                .angle_y(angle_y),
                .angle_z(angle_z),
                .v_out(cube_verts_rotated[i])
            );
            
            projector proj (
                .v_3d(cube_verts_rotated[i]),
                .v_2d(cube_verts_2d[i])
            );
        end
    endgenerate
    
    // VGA timing
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
    
    // Rasterizer
    rasterizer raster (
        .clk(clk),
        .rst(rst),
        .px(px),
        .py(py),
        .frame(frame),
        .vertices_2d(cube_verts_2d),
        .triangles(cube_triangles),
        .num_triangles(4'd12),
        .r(r4),
        .g(g4),
        .b(b4)
    );
    
    // Output
    assign sx = px;
    assign sy = py;
    assign sdl_r = de ? {r4, r4} : 8'h00;
    assign sdl_g = de ? {g4, g4} : 8'h00;
    assign sdl_b = de ? {b4, b4} : 8'h00;

endmodule