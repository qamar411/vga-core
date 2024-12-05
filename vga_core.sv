module vga_core #(
    parameter MEM_INIT_FILE = "default.mem" // Default memory initialization file
)(
    input wire clk,                        // Clock input
    input wire resetn,                      // resetn signal
    input wire [7:0] x,                    // X-coordinate (8 bits for 160)
    input wire [6:0] y,                    // Y-coordinate (7 bits for 120)
    input wire [2:0] color,                // Pixel color input (3 bits)
    input wire plot,                       // Write enable
    output wire [3:0] VGA_R,               // VGA red channel
    output wire [3:0] VGA_G,               // VGA green channel
    output wire [3:0] VGA_B,               // VGA blue channel
    output wire VGA_HS,                    // Horizontal sync
    output wire VGA_VS                     // Vertical sync
);

    // VGA timing signals
    wire video_on;
    wire [7:0] current_x;                  // Current X-coordinate (8 bits)
    wire [6:0] current_y;                  // Current Y-coordinate (7 bits)
    vga_controller vga_timing (
        .clk_100MHz(clk),
        .reset(~resetn),
        .video_on(video_on),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .x(current_x),
        .y(current_y)
    );

    // Video memory instance
    wire [2:0] pixel_data;                 // Data read from memory
    video_memory #(
        .MEM_INIT_FILE(MEM_INIT_FILE)
    ) video_mem (
        .clk_write(clk),
        .resetn(resetn),
        .write_enable(plot),    // Write enable
        .write_address(y * 160 + x),       // Compute address for writing
        .read_address(current_y * 160 + current_x), // Compute address for reading
        .data_in(color),                // Input color
        .data_out(pixel_data)              // Output color
    );

    // Map 3-bit pixel data to VGA signals
    assign VGA_R = {pixel_data[2], pixel_data[2], pixel_data[2], pixel_data[2]};
    assign VGA_G = {pixel_data[1], pixel_data[1], pixel_data[1], pixel_data[1]};
    assign VGA_B = {pixel_data[0], pixel_data[0], pixel_data[0], pixel_data[0]};

endmodule
