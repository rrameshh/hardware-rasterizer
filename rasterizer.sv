`include "graphics_type.sv"

module rasterizer (
    input  logic clk,
    input  logic rst,
    input  logic [9:0] px, py,
    input  logic frame,
    
    // Scene input (from scene controller)
    input  vertex_2d_t vertices_2d[0:7],
    input  triangle_t triangles[0:11],
    input  logic [3:0] num_triangles,
    
    output logic [3:0] r, g, b
);

    // Edge function
    function automatic logic signed [21:0] edge_function(
        vertex_2d_t a, vertex_2d_t b, vertex_2d_t c
    );
        automatic logic signed [10:0] bx_minus_ax, cy_minus_ay;
        automatic logic signed [10:0] by_minus_ay, cx_minus_ax;
        
        bx_minus_ax = ({1'b0, b.x}) - ({1'b0, a.x});
        cy_minus_ay = ({1'b0, c.y}) - ({1'b0, a.y});
        by_minus_ay = ({1'b0, b.y}) - ({1'b0, a.y});
        cx_minus_ax = ({1'b0, c.x}) - ({1'b0, a.x});
        
        return (bx_minus_ax * cy_minus_ay) - (by_minus_ay * cx_minus_ax);
    endfunction
    
    // Rasterize triangles
    always_comb begin
        automatic color_t pixel_color;
        automatic vertex_2d_t P;
        
        pixel_color = '{r: 4'h1, g: 4'h3, b: 4'h7}; // Background
        P = '{x: px, y: py, z: 10'sd0};
        
        // Check each triangle
        for (int t = 0; t < num_triangles; t++) begin
            automatic vertex_2d_t A, B, C;
            automatic logic signed [21:0] edge_abp, edge_bcp, edge_cap, edge_abc;
            automatic logic [9:0] min_x, max_x, min_y, max_y;
            
            A = vertices_2d[triangles[t].v0];
            B = vertices_2d[triangles[t].v1];
            C = vertices_2d[triangles[t].v2];
            
            // Bounding box
            min_x = (A.x < B.x) ? ((A.x < C.x) ? A.x : C.x) : ((B.x < C.x) ? B.x : C.x);
            max_x = (A.x > B.x) ? ((A.x > C.x) ? A.x : C.x) : ((B.x > C.x) ? B.x : C.x);
            min_y = (A.y < B.y) ? ((A.y < C.y) ? A.y : C.y) : ((B.y < C.y) ? B.y : C.y);
            max_y = (A.y > B.y) ? ((A.y > C.y) ? A.y : C.y) : ((B.y > C.y) ? B.y : C.y);
            
            if (px >= min_x && px <= max_x && py >= min_y && py <= max_y) begin
                edge_abp = edge_function(A, B, P);
                edge_bcp = edge_function(B, C, P);
                edge_cap = edge_function(C, A, P);
                edge_abc = edge_function(A, B, C);
                
                if ((edge_abp <= 0) && (edge_bcp <= 0) && (edge_cap <= 0) && (edge_abc != 0)) begin
                    pixel_color = triangles[t].color;
                end
            end
        end
        
        r = pixel_color.r;
        g = pixel_color.g;
        b = pixel_color.b;
    end

endmodule