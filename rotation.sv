`include "graphics_type.sv"

module rotation_engine (
    input  vertex_3d_t v_in,
    input  logic signed [15:0] angle_x,
    input  logic signed [15:0] angle_y,
    input  logic signed [15:0] angle_z,
    output vertex_3d_t v_out
);

    function automatic logic signed [15:0] cos_lut(logic [7:0] angle_idx);
        case (angle_idx[7:4])
            4'd0:  return 16'sd256;
            4'd1:  return 16'sd236;
            4'd2:  return 16'sd181;
            4'd3:  return 16'sd98;
            4'd4:  return 16'sd0;
            4'd5:  return -16'sd98;
            4'd6:  return -16'sd181;
            4'd7:  return -16'sd236;
            4'd8:  return -16'sd256;
            4'd9:  return -16'sd236;
            4'd10: return -16'sd181;
            4'd11: return -16'sd98;
            4'd12: return 16'sd0;
            4'd13: return 16'sd98;
            4'd14: return 16'sd181;
            4'd15: return 16'sd236;
            default: return 16'sd256;
        endcase
    endfunction
    
    function automatic logic signed [15:0] sin_lut(logic [7:0] angle_idx);
        return cos_lut(angle_idx - 8'd64);
    endfunction
    
    // Rotate single axis
    function automatic vertex_3d_t rotate_axis(
        vertex_3d_t v,
        logic signed [15:0] theta,
        logic [1:0] axis
    );
        automatic vertex_3d_t result;
        automatic logic signed [31:0] cos_theta, sin_theta;
        automatic logic signed [31:0] temp_a, temp_b;
        
        cos_theta = 32'($signed(cos_lut(theta[7:0])));
        sin_theta = 32'($signed(sin_lut(theta[7:0])));
        
        case (axis)
            2'd0: begin // X-axis
                temp_a = ((v.y * cos_theta) - (v.z * sin_theta)) >>> 8;
                temp_b = ((v.y * sin_theta) + (v.z * cos_theta)) >>> 8;
                result.x = v.x;
                result.y = temp_a[9:0];
                result.z = temp_b[9:0];
            end
            2'd1: begin // Y-axis
                temp_a = ((v.x * cos_theta) + (v.z * sin_theta)) >>> 8;
                temp_b = ((-32'($signed(v.x)) * sin_theta) + (v.z * cos_theta)) >>> 8;
                result.x = temp_a[9:0];
                result.y = v.y;
                result.z = temp_b[9:0];
            end
            2'd2: begin // Z-axis
                temp_a = ((v.x * cos_theta) - (v.y * sin_theta)) >>> 8;
                temp_b = ((v.x * sin_theta) + (v.y * cos_theta)) >>> 8;
                result.x = temp_a[9:0];
                result.y = temp_b[9:0];
                result.z = v.z;
            end
            default: result = v;
        endcase
        
        return result;
    endfunction
    
    // Rotate all 3 axes
    always_comb begin
        automatic vertex_3d_t temp_x, temp_y;
        temp_x = rotate_axis(v_in, angle_x, 2'd0);
        temp_y = rotate_axis(temp_x, angle_y, 2'd1);
        v_out = rotate_axis(temp_y, angle_z, 2'd2);
    end

endmodule