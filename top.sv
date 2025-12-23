`include "graphics_type.sv"

module top (
    input  logic clk,
    input  logic rst,
    input logic [7:0] ui_in,
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

    logic [7:0] ui_in_reg;
    
    always_ff @(posedge clk) begin
        ui_in_reg <= ui_in;
    end

    logic signed [9:0] cam_x, cam_z;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            angle_x <= 0;
            angle_y <= 0;
            angle_z <= 0;
        end else if (frame) begin
            angle_x <= angle_x + 16'd7;
            angle_y <= angle_y + 16'd7;
            angle_z <= angle_z + 16'd7;
        end
    end

    logic [1:0] model_select;
    logic [25:0] model_timer;
    logic [4:0] active_num_triangles;

    always_ff @(posedge clk) begin
        if (rst) begin
            model_select <= 2'd2;
            model_timer <= 0;
        end 
        // else if (frame) begin
        //     if (model_timer >= 26'd180) begin  // 180 frames = 3 seconds at 60fps
        //         model_timer <= 0;
        //         model_select <= model_select + 1;
        //     end else begin
        //         model_timer <= model_timer + 1;
        //     end
        // end
    end


    // Scene objects
    vertex_3d_t cube_verts_3d[0:17];
    triangle_t cube_triangles[0:23];
    
    scene_objects scene (
        .model_select(model_select),
        .cube_vertices(cube_verts_3d),
        .cube_triangles(cube_triangles),
        .cam_x(cam_x),
        .cam_z(cam_z),
        .num_triangles(active_num_triangles)
    );
    // Rotated and projected vertices
    vertex_3d_t cube_verts_rotated[0:17];
    vertex_2d_t cube_verts_2d[0:17];
    
    // Rotate all vertices
    genvar i;
    generate
        for (i = 0; i < 18; i++) begin : rotate_vertices
            rotation_engine rot (
                .v_in(cube_verts_3d[i]),
                .angle_x(angle_x),
                .angle_y(angle_y),
                .angle_z(angle_z),
                // .angle_x(16'd0), 
                // .angle_y(16'd0), 
                // .angle_z(16'd0),
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
        .num_triangles(active_num_triangles),  // Use dynamic count
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