`include "graphics_type.sv"

module projector (
    input  vertex_3d_t v_3d,
    output vertex_2d_t v_2d
);

    localparam signed [31:0] FOCAL_LENGTH = 32'sd800;
    localparam signed [31:0] Z_OFFSET = 32'sd400;
    
    always_comb begin
        automatic logic signed [31:0] signed_x, signed_y, signed_z;
        automatic logic signed [31:0] z_dist;
        automatic logic signed [31:0] temp_x, temp_y;
        
        // Extend 10-bit signed values to 32-bit signed
        signed_x = $signed({{22{v_3d.x[9]}}, v_3d.x});  // Sign extend
        signed_y = $signed({{22{v_3d.y[9]}}, v_3d.y});
        signed_z = $signed({{22{v_3d.z[9]}}, v_3d.z});
        
        // Add Z_OFFSET to prevent division by zero/negative
        z_dist = signed_z + Z_OFFSET;
        
        // Perspective divide: x_screen = (x * focal) / z + center
        temp_x = ((signed_x * FOCAL_LENGTH) / z_dist) + 32'sd320;
        temp_y = ((signed_y * FOCAL_LENGTH) / z_dist) + 32'sd240;
        
        // Clamp to screen bounds
        if (temp_x > 32'sd639) v_2d.x = 10'd639;
        else if (temp_x < 32'sd0) v_2d.x = 10'd0;
        else v_2d.x = temp_x[9:0];
        
        if (temp_y > 32'sd479) v_2d.y = 10'd479;
        else if (temp_y < 32'sd0) v_2d.y = 10'd0;
        else v_2d.y = temp_y[9:0];
        
        v_2d.z = v_3d.z;
    end

endmodule