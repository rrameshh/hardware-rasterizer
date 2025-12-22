`include "graphics_type.sv"

module projector (
    input  vertex_3d_t v_3d,
    output vertex_2d_t v_2d
);

    localparam SCALE = 128;
    
    always_comb begin
        automatic logic signed [31:0] temp_x, temp_y;
        
        temp_x = ((v_3d.x * SCALE) >>> 8) + 320;
        temp_y = ((v_3d.y * SCALE) >>> 8) + 240;
        
        // Clamp to screen bounds
        if (temp_x > 639) v_2d.x = 10'd639;
        else if (temp_x < 0) v_2d.x = 10'd0;
        else v_2d.x = temp_x[9:0];
        
        if (temp_y > 479) v_2d.y = 10'd479;
        else if (temp_y < 0) v_2d.y = 10'd0;
        else v_2d.y = temp_y[9:0];
        
        v_2d.z = v_3d.z;
    end

endmodule