typedef struct packed {
    logic signed [9:0] x, y, z;
} vertex_3d_t;

typedef struct packed {
    logic [9:0] x, y; 
    logic signed [9:0] z;
} vertex_2d_t;

typedef struct packed {
    logic [3:0] r;
    logic [3:0] g;
    logic [3:0] b;
} color_t;


module rasterizer (
    input  logic clk,
    input  logic rst,
    input  logic [9:0] px,      // Current pixel X (from VGA timing)
    input  logic [9:0] py,      // Current pixel Y (from VGA timing)
    input  logic frame,         // New frame pulse
    output logic [3:0] r,       // Red output
    output logic [3:0] g,       // Green output
    output logic [3:0] b,        // Blue output
    output logic signed [21:0] edge_abp, edge_bcp, edge_cap
);
    /* 
        things are represented as 
        100 units in every direction? 
    */

    localparam VERTEX_ONE_X = 10'sd100;
    localparam VERTEX_ONE_Y = 10'sd100;
    localparam VERTEX_ONE_Z = 10'd0;

    localparam VERTEX_TWO_X = 10'd0;
    localparam VERTEX_TWO_Y = -10'sd100;
    localparam VERTEX_TWO_Z = 10'd0;

    localparam VERTEX_THREE_X = -10'sd100;
    localparam VERTEX_THREE_Y = 10'sd100;
    localparam VERTEX_THREE_Z = 10'd0;

    vertex_2d_t A, B, C, P;
    vertex_3d_t A_3d, B_3d, C_3d;
    vertex_3d_t A_rotated, B_rotated, C_rotated;
    vertex_3d_t camera;

    logic signed [15:0] angle_x, angle_y, angle_z;

    always_ff @(posedge clk) begin
        if (rst) begin
            angle_x <= 16'd0;
            angle_y <= 16'd0;
            angle_z <= 16'd0;
        end else if (frame) begin
            angle_x <= angle_x + 16'd5; 
            angle_y <= angle_y + 16'd5;
            angle_z <= angle_z + 16'd5; 
        end
    end

    function logic signed [15:0] cos_lut(logic [7:0] angle_idx);
        case (angle_idx[7:4])  // 16 entries for 0-360 degrees
            4'd0:  return 16'sd256;   // 0
            4'd1:  return 16'sd236;   // 22.5
            4'd2:  return 16'sd181;   // 45
            4'd3:  return 16'sd98;    // 67.5
            4'd4:  return 16'sd0;     // 90
            4'd5:  return -16'sd98;   // 112.5
            4'd6:  return -16'sd181;  // 135
            4'd7:  return -16'sd236;  // 157.5
            4'd8:  return -16'sd256;  // 180
            4'd9:  return -16'sd236;  // 202.5
            4'd10: return -16'sd181;  // 225
            4'd11: return -16'sd98;   // 247.5
            4'd12: return 16'sd0;     // 270
            4'd13: return 16'sd98;    // 292.5
            4'd14: return 16'sd181;   // 315
            4'd15: return 16'sd236;   // 337.5
            default: return 16'sd256;
        endcase
    endfunction

    function logic signed [15:0] sin_lut(logic [7:0] angle_idx);
        // sin(x) = cos(x - 90 deg) which is cos(angle - 64)
        return cos_lut(angle_idx - 8'd64);
    endfunction


    // 3d assignments
    always_comb begin
        A_3d.x = VERTEX_ONE_X;
        B_3d.x = VERTEX_TWO_X;
        C_3d.x = VERTEX_THREE_X;

        A_3d.y = VERTEX_ONE_Y;
        B_3d.y = VERTEX_TWO_Y;
        C_3d.y = VERTEX_THREE_Y;

        A_3d.z = 10'd1;
        B_3d.z = 10'd1;
        C_3d.z = 10'd1;

        P.x = px;
        P.y = py;
    end


    function vertex_2d_t project_vertex(vertex_3d_t v);
        automatic vertex_2d_t result;
        automatic logic signed [31:0] scale = 128;
        automatic logic signed [31:0] temp_x, temp_y;
        
        temp_x = ((v.x * scale) >>> 8) + 320;
        temp_y = ((v.y * scale) >>> 8) + 240;
        
        if (temp_x > 1023) result.x = 10'd1023;
        else if (temp_x < 0) result.x = 10'd0;
        else result.x = temp_x[9:0];
        
        if (temp_y > 1023) result.y = 10'd1023;
        else if (temp_y < 0) result.y = 10'd0;
        else result.y = temp_y[9:0];
        
        result.z = v.z;
        
        return result;
    endfunction

    function vertex_3d_t rotate_3d(
        vertex_3d_t v,
        logic signed [15:0] theta,
        logic [1:0] axis  // 0: x-axis, 1: y-axis, 2: z-axis
    );
        automatic vertex_3d_t result;
        automatic logic signed [31:0] cos_theta, sin_theta;
        automatic logic signed [31:0] temp_a, temp_b;
        
        // Cast to 32-bit signed
        cos_theta = 32'($signed(cos_lut(theta[7:0])));
        sin_theta = 32'($signed(sin_lut(theta[7:0])));
        
        case (axis)
            2'd0: begin // Rotate around X-axis
                // y' = y*cos(θ) - z*sin(θ)
                // z' = y*sin(θ) + z*cos(θ)
                temp_a = ((v.y * cos_theta) - (v.z * sin_theta)) >>> 8;
                temp_b = ((v.y * sin_theta) + (v.z * cos_theta)) >>> 8;
                
                result.x = v.x;
                result.y = temp_a[9:0];
                result.z = temp_b[9:0];
            end
            
            2'd1: begin // Rotate around Y-axis
                // x' = x*cos(θ) + z*sin(θ)
                // z' = -x*sin(θ) + z*cos(θ)
                temp_a = ((v.x * cos_theta) + (v.z * sin_theta)) >>> 8;
                temp_b = ((-32'($signed(v.x)) * sin_theta) + (v.z * cos_theta)) >>> 8;
                
                result.x = temp_a[9:0];
                result.y = v.y;
                result.z = temp_b[9:0];
            end
            
            2'd2: begin // Rotate around Z-axis
                // x' = x*cos(θ) - y*sin(θ)
                // y' = x*sin(θ) + y*cos(θ)
                temp_a = ((v.x * cos_theta) - (v.y * sin_theta)) >>> 8;
                temp_b = ((v.x * sin_theta) + (v.y * cos_theta)) >>> 8;
                
                result.x = temp_a[9:0];
                result.y = temp_b[9:0];
                result.z = v.z;
            end
            
            default: begin
                result = v; // No rotation if invalid axis
            end
        endcase
        
        return result;
    endfunction


    vertex_3d_t A_rot_x, A_rot_y, B_rot_x, B_rot_y, C_rot_x, C_rot_y;
    always_comb begin
        
        A_rot_x = rotate_3d(A_3d, angle_x, 0);
        A_rot_y = rotate_3d(A_rot_x, angle_y, 1);
        A_rotated = rotate_3d(A_rot_y, angle_z, 2);
        
        B_rot_x = rotate_3d(B_3d, angle_x, 0);
        B_rot_y = rotate_3d(B_rot_x, angle_y, 1);
        B_rotated = rotate_3d(B_rot_y, angle_z, 2);
        
        C_rot_x = rotate_3d(C_3d, angle_x, 0);
        C_rot_y = rotate_3d(C_rot_x, angle_y, 1);
        C_rotated = rotate_3d(C_rot_y, angle_z, 2);
        
        A = project_vertex(A_rotated);
        B = project_vertex(B_rotated);
        C = project_vertex(C_rotated);
    end


    always_comb begin
        camera.x = 0;
        camera.y = 0;
        camera.z = 10'd100;
    end

    // color assignments
    color_t red;
    color_t green;
    color_t blue;
    always_comb begin
        red.r = 4'hF;
        red.g = 4'h0;
        red.b = 4'h0;

        green.r = 4'h0;
        green.g = 4'hF;
        green.b = 4'h0;
        
        blue.r = 4'h0;
        blue.g = 4'h0;
        blue.b = 4'hF;

    end
    
   logic inside_triangle;

   function logic signed [21:0] edge_function(vertex_2d_t a, vertex_2d_t b, vertex_2d_t c);
        automatic logic signed [10:0] bx_minus_ax; 
        automatic logic signed [10:0] cy_minus_ay;
        automatic logic signed [10:0] by_minus_ay;
        automatic logic signed [10:0] cx_minus_ax;
        automatic logic signed [21:0] term1, term2;
        
        bx_minus_ax = ({1'b0, b.x}) - ({1'b0, a.x});
        cy_minus_ay = ({1'b0, c.y}) - ({1'b0, a.y});
        by_minus_ay = ({1'b0, b.y}) - ({1'b0, a.y});
        cx_minus_ax = ({1'b0, c.x}) - ({1'b0, a.x});
        
        term1 = bx_minus_ax * cy_minus_ay;
        term2 = by_minus_ay * cx_minus_ax;
        
        return term1 - term2;
    endfunction


    logic [9:0] min_x, max_x, min_y, max_y;
    logic signed [21:0] weightA, weightB, weightC;
    logic signed [21:0] edge_abc;

    always_comb begin

        inside_triangle = 1'b0;
        min_x = (A.x < B.x) ? ((A.x < C.x) ? A.x : C.x) : ((B.x < C.x) ? B.x : C.x);
        max_x = (A.x > B.x) ? ((A.x > C.x) ? A.x : C.x) : ((B.x > C.x) ? B.x : C.x);
        min_y = (A.y < B.y) ? ((A.y < C.y) ? A.y : C.y) : ((B.y < C.y) ? B.y : C.y);
        max_y = (A.y > B.y) ? ((A.y > C.y) ? A.y : C.y) : ((B.y > C.y) ? B.y : C.y);

        edge_abp = 22'd0;
        edge_bcp = 22'd0;
        edge_cap = 22'd0;
        edge_abc = 22'd0;

        weightA = 22'd0;
        weightB = 22'd0;
        weightC = 22'd0;

        
        // bounding box check
        if (px >= min_x && px <= max_x && py >= min_y && py <= max_y) begin
            edge_abp = edge_function(A, B, P);
            edge_bcp = edge_function(B, C, P);
            edge_cap = edge_function(C, A, P);
            edge_abc = edge_function(A, B, C);

            weightA = (edge_bcp << 8) / edge_abc;
            weightB = (edge_cap << 8) / edge_abc;
            weightC = (edge_abp << 8) / edge_abc;

            inside_triangle = (edge_abp <= 0) && (edge_bcp <= 0) && (edge_cap <= 0);

        end 
    end

    always_comb begin
        if (inside_triangle) begin
            automatic logic [21:0] r_temp, g_temp, b_temp;
            
            r_temp = ((red.r * weightA) + (blue.r * weightB) + (green.r * weightC)) >> 8;
            g_temp = ((red.g * weightA) + (blue.g * weightB) + (green.g * weightC)) >> 8;
            b_temp = ((red.b * weightA) + (blue.b * weightB) + (green.b * weightC)) >> 8;
            
            r = r_temp[3:0];
            g = g_temp[3:0];
            b = b_temp[3:0];

        end else begin
            r = 4'h1;
            g = 4'h3;
            b = 4'h7;
        end
    end
    
endmodule