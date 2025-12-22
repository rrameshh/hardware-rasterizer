`ifndef GRAPHICS_TYPES_SV
`define GRAPHICS_TYPES_SV

// 3D vertex (signed for rotation)
typedef struct packed {
    logic signed [9:0] x, y, z;
} vertex_3d_t;

// 2D vertex (unsigned X/Y for screen, signed Z for depth)
typedef struct packed {
    logic [9:0] x, y;
    logic signed [9:0] z;
} vertex_2d_t;

// RGB color
typedef struct packed {
    logic [3:0] r, g, b;
} color_t;

// Triangle definition (indices + color)
typedef struct packed {
    logic [2:0] v0, v1, v2;  // Vertex indices
    color_t color;
} triangle_t;

`endif