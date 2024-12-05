`timescale 1ns / 1ps

module vga_controller(
    input clk_100MHz,   // from Basys 3
    input reset,        // system reset
    output video_on,    // ON while pixel counts for x and y and within display area
    output hsync,       // horizontal sync
    output vsync,       // vertical sync
    output p_tick,      // the 25MHz pixel/second rate signal, pixel tick
    output [9:0] x,     // logical pixel x (0-159)
    output [9:0] y      // logical pixel y (0-119)
);

    // Standard VGA 640x480 timings
    parameter HD = 640;             // horizontal display area width in pixels
    parameter HF = 48;              // horizontal front porch width in pixels
    parameter HB = 16;              // horizontal back porch width in pixels
    parameter HR = 96;              // horizontal retrace width in pixels
    parameter HMAX = HD+HF+HB+HR-1; // max value of horizontal counter = 799

    parameter VD = 480;             // vertical display area length in pixels
    parameter VF = 10;              // vertical front porch length in pixels  
    parameter VB = 33;              // vertical back porch length in pixels   
    parameter VR = 2;               // vertical retrace length in pixels  
    parameter VMAX = VD+VF+VB+VR-1; // max value of vertical counter = 524

    // Scaling factors for 160x120 resolution
    parameter X_SCALE = 4;          // Horizontal scaling (640 / 160)
    parameter Y_SCALE = 4;          // Vertical scaling (480 / 120)

    // Generate 25MHz clock from 100MHz
    reg [1:0] clk_div;
    wire w_25MHz;
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end
    assign w_25MHz = (clk_div == 0); // Divide by 4
    assign p_tick = w_25MHz;

    // Pixel counters
    reg [9:0] h_count;
    reg [9:0] v_count;

    // Horizontal and vertical counters
    always @(posedge w_25MHz or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else if (h_count == HMAX) begin
            h_count <= 0;
            if (v_count == VMAX)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end

    // Generate sync signals
    assign hsync = ~((h_count >= (HD + HB)) && (h_count < (HD + HB + HR)));
    assign vsync = ~((v_count >= (VD + VB)) && (v_count < (VD + VB + VR)));

    // Video ON signal
    assign video_on = (h_count < HD) && (v_count < VD);

    // Logical pixel coordinates (scaled down)
    assign x = h_count / X_SCALE; // Map 640 to 160
    assign y = v_count / Y_SCALE; // Map 480 to 120

endmodule
