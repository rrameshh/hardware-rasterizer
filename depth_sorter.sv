`include "graphics_type.sv"

module depth_sorter (
    input  vertex_2d_t vertices_2d[0:17],
    input  triangle_t triangles_in[0:23],
    input  logic [4:0] num_triangles,
    
    output triangle_t triangles_sorted[0:23],
    output logic [4:0] sorted_indices[0:23]
);

    // Calculate average Z depth for a triangle
    function automatic logic signed [11:0] avg_depth(
        vertex_2d_t A, vertex_2d_t B, vertex_2d_t C
    );
        automatic logic signed [11:0] sum;
        sum = ({2'b0, A.z}) + ({2'b0, B.z}) + ({2'b0, C.z});
        return sum / 3;
    endfunction

    always_comb begin
        automatic logic signed [11:0] depths[0:23];
        automatic int order[0:23];
        
        // Calculate depths
        for (int t = 0; t < num_triangles; t++) begin
            automatic vertex_2d_t A, B, C;
            A = vertices_2d[triangles_in[t].v0];
            B = vertices_2d[triangles_in[t].v1];
            C = vertices_2d[triangles_in[t].v2];
            depths[t] = avg_depth(A, B, C);
            order[t] = t;
        end
        
        // Bubble sort by depth (back to front)
    for (int i = 0; i < int'(num_triangles) - 1; i++) begin
        for (int j = 0; j < int'(num_triangles) - i - 1; j++) begin
            if (depths[order[j]] < depths[order[j+1]]) begin
                automatic int temp;
                temp = order[j];
                order[j] = order[j+1];
                order[j+1] = temp;
            end
        end
    end
        
        // Output sorted triangles
        for (int t = 0; t < 24; t++) begin
            if (t < num_triangles) begin
                triangles_sorted[t] = triangles_in[order[t]];
                sorted_indices[t] = order[t][4:0];
            end else begin
                triangles_sorted[t] = triangles_in[0];  // Padding
                sorted_indices[t] = 5'd0;
            end
        end
    end

endmodule