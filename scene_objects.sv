`include "graphics_type.sv"

module scene_objects (
    output vertex_3d_t cube_vertices[0:7],
    output triangle_t cube_triangles[0:11]
);

    localparam CUBE_SIZE = 10'sd80;
    
    always_comb begin
        // Cube vertices
        cube_vertices[0] = '{x:  CUBE_SIZE, y:  CUBE_SIZE, z:  CUBE_SIZE};
        cube_vertices[1] = '{x: -CUBE_SIZE, y:  CUBE_SIZE, z:  CUBE_SIZE};
        cube_vertices[2] = '{x: -CUBE_SIZE, y: -CUBE_SIZE, z:  CUBE_SIZE};
        cube_vertices[3] = '{x:  CUBE_SIZE, y: -CUBE_SIZE, z:  CUBE_SIZE};
        cube_vertices[4] = '{x:  CUBE_SIZE, y:  CUBE_SIZE, z: -CUBE_SIZE};
        cube_vertices[5] = '{x: -CUBE_SIZE, y:  CUBE_SIZE, z: -CUBE_SIZE};
        cube_vertices[6] = '{x: -CUBE_SIZE, y: -CUBE_SIZE, z: -CUBE_SIZE};
        cube_vertices[7] = '{x:  CUBE_SIZE, y: -CUBE_SIZE, z: -CUBE_SIZE};
        
        // Cube triangles (front = red, back = green, etc)
        cube_triangles[0]  = '{v0: 0, v1: 1, v2: 2, color: '{r: 4'hF, g: 4'h0, b: 4'h0}};
        cube_triangles[1]  = '{v0: 0, v1: 2, v2: 3, color: '{r: 4'hF, g: 4'h0, b: 4'h0}};
        cube_triangles[2]  = '{v0: 4, v1: 6, v2: 5, color: '{r: 4'h0, g: 4'hF, b: 4'h0}};
        cube_triangles[3]  = '{v0: 4, v1: 7, v2: 6, color: '{r: 4'h0, g: 4'hF, b: 4'h0}};
        cube_triangles[4]  = '{v0: 0, v1: 4, v2: 5, color: '{r: 4'h0, g: 4'h0, b: 4'hF}};
        cube_triangles[5]  = '{v0: 0, v1: 5, v2: 1, color: '{r: 4'h0, g: 4'h0, b: 4'hF}};
        cube_triangles[6]  = '{v0: 3, v1: 7, v2: 4, color: '{r: 4'hF, g: 4'hF, b: 4'h0}};
        cube_triangles[7]  = '{v0: 3, v1: 4, v2: 0, color: '{r: 4'hF, g: 4'hF, b: 4'h0}};
        cube_triangles[8]  = '{v0: 1, v1: 5, v2: 6, color: '{r: 4'h0, g: 4'hF, b: 4'hF}};
        cube_triangles[9]  = '{v0: 1, v1: 6, v2: 2, color: '{r: 4'h0, g: 4'hF, b: 4'hF}};
        cube_triangles[10] = '{v0: 2, v1: 6, v2: 7, color: '{r: 4'hF, g: 4'h0, b: 4'hF}};
        cube_triangles[11] = '{v0: 2, v1: 7, v2: 3, color: '{r: 4'hF, g: 4'h0, b: 4'hF}};
    end

endmodule