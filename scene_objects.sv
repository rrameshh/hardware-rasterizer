`include "graphics_type.sv"

module scene_objects (
    input  logic [1:0] model_select,
    output vertex_3d_t cube_vertices[0:7],
    output triangle_t cube_triangles[0:11],
    output logic [3:0] num_triangles
);

    localparam CUBE_SIZE = 10'sd80;
    
    always_comb begin
        case (model_select)
            2'd0: begin  // CUBE
                cube_vertices[0] = '{x:  CUBE_SIZE, y:  CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[1] = '{x: -CUBE_SIZE, y:  CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[2] = '{x: -CUBE_SIZE, y: -CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[3] = '{x:  CUBE_SIZE, y: -CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[4] = '{x:  CUBE_SIZE, y:  CUBE_SIZE, z: -CUBE_SIZE};
                cube_vertices[5] = '{x: -CUBE_SIZE, y:  CUBE_SIZE, z: -CUBE_SIZE};
                cube_vertices[6] = '{x: -CUBE_SIZE, y: -CUBE_SIZE, z: -CUBE_SIZE};
                cube_vertices[7] = '{x:  CUBE_SIZE, y: -CUBE_SIZE, z: -CUBE_SIZE};
                
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
                num_triangles = 4'd12;
            end
            
            2'd1: begin  // PYRAMID
                cube_vertices[0] = '{x: 10'sd0, y: -CUBE_SIZE, z: 10'sd0};  // Apex
                cube_vertices[1] = '{x:  CUBE_SIZE, y:  CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[2] = '{x: -CUBE_SIZE, y:  CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[3] = '{x: -CUBE_SIZE, y:  CUBE_SIZE, z: -CUBE_SIZE};
                cube_vertices[4] = '{x:  CUBE_SIZE, y:  CUBE_SIZE, z: -CUBE_SIZE};
                cube_vertices[5] = '{x: 10'sd0, y: 10'sd0, z: 10'sd0};  // Unused
                cube_vertices[6] = '{x: 10'sd0, y: 10'sd0, z: 10'sd0};
                cube_vertices[7] = '{x: 10'sd0, y: 10'sd0, z: 10'sd0};
                
                // Side faces
                cube_triangles[0] = '{v0: 0, v1: 1, v2: 2, color: '{r: 4'hF, g: 4'h0, b: 4'h0}};
                cube_triangles[1] = '{v0: 0, v1: 2, v2: 3, color: '{r: 4'h0, g: 4'hF, b: 4'h0}};
                cube_triangles[2] = '{v0: 0, v1: 3, v2: 4, color: '{r: 4'h0, g: 4'h0, b: 4'hF}};
                cube_triangles[3] = '{v0: 0, v1: 4, v2: 1, color: '{r: 4'hF, g: 4'hF, b: 4'h0}};
                // Base
                cube_triangles[4] = '{v0: 1, v1: 3, v2: 2, color: '{r: 4'hF, g: 4'h0, b: 4'hF}};
                cube_triangles[5] = '{v0: 1, v1: 4, v2: 3, color: '{r: 4'hF, g: 4'h0, b: 4'hF}};
                num_triangles = 4'd6;
            end
            
            2'd2: begin  // OCTAHEDRON
                cube_vertices[0] = '{x: 10'sd0, y: -CUBE_SIZE, z: 10'sd0};  // Top
                cube_vertices[1] = '{x:  CUBE_SIZE, y: 10'sd0, z: 10'sd0};
                cube_vertices[2] = '{x: 10'sd0, y: 10'sd0, z:  CUBE_SIZE};
                cube_vertices[3] = '{x: -CUBE_SIZE, y: 10'sd0, z: 10'sd0};
                cube_vertices[4] = '{x: 10'sd0, y: 10'sd0, z: -CUBE_SIZE};
                cube_vertices[5] = '{x: 10'sd0, y:  CUBE_SIZE, z: 10'sd0};  // Bottom
                cube_vertices[6] = '{x: 10'sd0, y: 10'sd0, z: 10'sd0};
                cube_vertices[7] = '{x: 10'sd0, y: 10'sd0, z: 10'sd0};
                
                // Top 4 faces
                cube_triangles[0] = '{v0: 0, v1: 1, v2: 2, color: '{r: 4'hF, g: 4'h0, b: 4'h0}};
                cube_triangles[1] = '{v0: 0, v1: 2, v2: 3, color: '{r: 4'h0, g: 4'hF, b: 4'h0}};
                cube_triangles[2] = '{v0: 0, v1: 3, v2: 4, color: '{r: 4'h0, g: 4'h0, b: 4'hF}};
                cube_triangles[3] = '{v0: 0, v1: 4, v2: 1, color: '{r: 4'hF, g: 4'hF, b: 4'h0}};
                // Bottom 4 faces
                cube_triangles[4] = '{v0: 5, v1: 2, v2: 1, color: '{r: 4'hF, g: 4'h0, b: 4'hF}};
                cube_triangles[5] = '{v0: 5, v1: 3, v2: 2, color: '{r: 4'h0, g: 4'hF, b: 4'hF}};
                cube_triangles[6] = '{v0: 5, v1: 4, v2: 3, color: '{r: 4'hF, g: 4'hF, b: 4'hF}};
                cube_triangles[7] = '{v0: 5, v1: 1, v2: 4, color: '{r: 4'h8, g: 4'h8, b: 4'h8}};
                num_triangles = 4'd8;
            end
            
            default: begin
                // Default to cube
                cube_vertices[0] = '{x:  CUBE_SIZE, y:  CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[1] = '{x: -CUBE_SIZE, y:  CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[2] = '{x: -CUBE_SIZE, y: -CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[3] = '{x:  CUBE_SIZE, y: -CUBE_SIZE, z:  CUBE_SIZE};
                cube_vertices[4] = '{x:  CUBE_SIZE, y:  CUBE_SIZE, z: -CUBE_SIZE};
                cube_vertices[5] = '{x: -CUBE_SIZE, y:  CUBE_SIZE, z: -CUBE_SIZE};
                cube_vertices[6] = '{x: -CUBE_SIZE, y: -CUBE_SIZE, z: -CUBE_SIZE};
                cube_vertices[7] = '{x:  CUBE_SIZE, y: -CUBE_SIZE, z: -CUBE_SIZE};
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
                num_triangles = 4'd12;
            end
        endcase
    end

endmodule